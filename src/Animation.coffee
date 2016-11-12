
{Number} = require "Nan"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
LazyVar = require "LazyVar"
Type = require "Type"

NativeAnimated = require "./NativeAnimated"
injected = require "./injectable"

# Avoid circular dependency.
AnimatedValue = LazyVar -> require "./nodes/AnimatedValue"

type = Type "Animation"

type.trace()

type.defineStatics
  types: Object.create null

type.defineOptions
  fromValue: Number
  isInteraction: Boolean.withDefault yes
  useNativeDriver: Boolean.withDefault no
  captureFrames: Boolean.withDefault no

type.initArgs do ->
  hasWarned = no
  return (args) ->
    return unless args[0].useNativeDriver
    return if NativeAnimated.isAvailable or hasWarned
    args[0].useNativeDriver = no
    log.warn "Failed to load NativeAnimatedModule! Falling back to JS-driven animations."
    hasWarned = yes

type.defineValues (options) ->

  startTime: null

  fromValue: options.fromValue ? null

  _state: 0

  _isInteraction: options.isInteraction

  _useNativeDriver: options.useNativeDriver

  _nativeTag: null

  _animationFrame: null

  _previousAnimation: null

  _onUpdate: null

  _onEnd: null

  _frames: [] if options.captureFrames

  _captureFrame: emptyFunction unless options.captureFrames

type.defineBoundMethods

  _recomputeValue: ->

    @_animationFrame = null
    return if @isDone

    value = @__computeValue()
    @__onAnimationUpdate value
    @_captureFrame()

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

  start: (animated, onEnd) ->
    assertType animated, AnimatedValue.get()
    assertType onEnd, Function

    return this unless @isPending
    @_state += 1

    @_previousAnimation = animated._animation
    @_previousAnimation?.stop()

    if @_isInteraction
      id = @_createInteraction()

    @_onEnd = (finished) =>
      @_onEnd = emptyFunction
      @_clearInteraction id

      if @_useNativeDriver
        NativeAnimated.removeUpdateListener animated

      @__onAnimationEnd finished
      onEnd finished

    @_startAnimation animated
    return this

  stop: ->
    @_stopAnimation no

  finish: ->
    @_stopAnimation yes

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
    then animated._updateValue @fromValue
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
