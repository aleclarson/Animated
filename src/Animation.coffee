
{Number} = require "Nan"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
LazyVar = require "LazyVar"
isDev = require "isDev"
Type = require "Type"

NativeAnimated = require "./NativeAnimated"
injected = require "./injectable"

# Avoid circular dependency.
AnimatedValue = LazyVar -> require "./nodes/AnimatedValue"

type = Type "Animation"

type.trace()

type.defineStatics
  types: Object.create null

type.defineArgs ->

  types:
    fromValue: Number
    isInteraction: Boolean
    useNativeDriver: Boolean
    captureFrames: Boolean

  defaults:
    isInteraction: yes
    useNativeDriver: no
    captureFrames: no

type.initInstance do ->
  hasWarned = no
  return (options) ->
    if options.useNativeDriver
      return if NativeAnimated.isAvailable or hasWarned
      options.useNativeDriver = no
      log.warn "Failed to load NativeAnimatedModule! Falling back to JS-driven animations."
      hasWarned = yes
    return

type.defineValues (options) ->

  startTime: null

  fromValue: options.fromValue ? null

  _state: 0

  _isInteraction: options.isInteraction

  _useNativeDriver: options.useNativeDriver

  _nativeTag: null

  _animationFrame: null

  _previousAnimation: null

  _onUpdate: emptyFunction

  _onEnd: emptyFunction

  _onEndQueue: []

  _frames: [] if options.captureFrames

  _captureFrame: emptyFunction unless options.captureFrames

type.defineBoundMethods

  _recomputeValue: ->

    @_animationFrame = null
    return if @isDone

    value = @__computeValue()
    @__onAnimationUpdate value
    @_captureFrame()

    @_onUpdate value
    @isDone or @_requestAnimationFrame()
    return

#
# Prototype
#

type.defineGetters

  isPending: -> @_state is 0

  isActive: -> @_state is 1

  isDone: -> @_state is 2

type.defineHooks

  __computeValue: null

  __onAnimationStart: (animated) ->
    if @_useNativeDriver
    then @_startNativeAnimation animated
    else @_requestAnimationFrame()

  __onAnimationUpdate: emptyFunction

  __onAnimationEnd: emptyFunction

  __captureFrame: emptyFunction

  __getNativeConfig: ->
    throw Error "This animation type does not support native offloading!"

type.defineMethods

  start: (animated, onUpdate) ->
    assertType animated, AnimatedValue.get()
    assertType onUpdate, Function.Maybe

    return this unless @isPending
    @_state += 1

    if @_isInteraction
      id = @_createInteraction()

    animation = animated._animation
    animation?.stop()
    @_previousAnimation = animation

    if onUpdate
      onUpdate = animated
        .didSet onUpdate
        .start()

    unless @_useNativeDriver
      @_onUpdate = (newValue) ->
        animated._updateValue newValue, no

    @_onEnd = (finished) =>
      @_onEnd = emptyFunction
      @_onUpdate = emptyFunction

      animated._animation = null
      onUpdate?.detach()
      if @_useNativeDriver
        NativeAnimated.removeUpdateListener animated

      @_clearInteraction id
      @__onAnimationEnd finished
      @_flushEndQueue finished
      return

    animated._animation = this
    @_startAnimation animated
    return this

  stop: (finished = no) ->
    isDev and assertType finished, Boolean
    @_stopAnimation finished

  then: (onEnd) ->
    isDev and assertType onEnd, Function
    if queue = @_onEndQueue
      queue.push onEnd
    return this

  _requestAnimationFrame: (callback) ->
    @_animationFrame or @_animationFrame = injected.call "requestAnimationFrame", callback or @_recomputeValue

  _cancelAnimationFrame: ->
    if @_animationFrame
      injected.call "cancelAnimationFrame", @_animationFrame
      @_animationFrame = null
    return

  _startAnimation: (animated) ->
    @startTime = Date.now()
    if @fromValue?
    then animated._updateValue @fromValue, @_useNativeDriver
    else @fromValue = animated._value
    @__onAnimationStart animated

  _startNativeAnimation: (animated) ->
    @_nativeTag = NativeAnimated.createAnimationTag()
    animated.__markNative()
    animatedTag = animated.__getNativeTag()
    animationConfig = @__getNativeConfig()
    NativeAnimated.addUpdateListener animated
    NativeAnimated.startAnimatingNode @_nativeTag, animatedTag, animationConfig, (data) =>
      return if @isDone
      @_state += 1
      @_onEnd data.finished
      return

  _stopAnimation: (finished) ->
    return if @isDone
    @_state += 1
    if @_nativeTag
    then NativeAnimated.stopAnimation @_nativeTag
    else @_cancelAnimationFrame()
    @_onEnd finished
    return

  _flushEndQueue: (finished) ->
    queue = @_onEndQueue
    @_onEndQueue = null
    for onEnd in queue
      onEnd finished
    return

  _captureFrame: ->
    frame = @__captureFrame()
    assertType frame, Object
    @_frames.push frame
    return

  _assertNumber: (value) ->
    assertType value, Number

  _createInteraction: ->
    injected.get("InteractionManager").createInteractionHandle()

  _clearInteraction: (handle) ->
    handle? and injected.get("InteractionManager").clearInteractionHandle handle

module.exports = Animation = type.build()
