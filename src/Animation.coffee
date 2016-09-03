
{Number} = require "Nan"

emptyFunction = require "emptyFunction"
assertTypes = require "assertTypes"
assertType = require "assertType"
isType = require "isType"
Type = require "Type"

requestAnimationFrame = require("./inject/requestAnimationFrame").get()
cancelAnimationFrame = require("./inject/cancelAnimationFrame").get()

type = Type "Animation"

type.trace()

type.defineOptions
  startValue: Number
  isInteraction: Boolean.withDefault yes
  captureFrames: Boolean.withDefault no

type.defineValues (options) ->

  startTime: null

  startValue: options.startValue ? null

  _state: 0

  _isInteraction: options.isInteraction

  _animationFrame: null

  _previousAnimation: null

  _onUpdate: null

  _onEnd: null

  _frames: [] if options.captureFrames

  _captureFrame: emptyFunction if not options.captureFrames

type.defineGetters

  isPending: -> @_state is 0

  isActive: -> @_state is 1

  isDone: -> @_state is 2

type.defineHooks

  __computeValue: null

  __didStart: (config) ->
    @startTime = Date.now()
    @startValue = config.startValue
    @_requestAnimationFrame()

  __didEnd: emptyFunction

  __didUpdate: emptyFunction

  __captureFrame: emptyFunction

type.defineMethods

  start: (config) ->

    return if not @isPending
    @_state += 1

    if config.previousAnimation instanceof Animation
      @_previousAnimation = config.previousAnimation

    # Prefer 'startValue' specified in constructor.
    if @startValue isnt null
      config.startValue = @startValue

    @_onUpdate = config.onUpdate or emptyFunction
    @_onEnd = config.onEnd or emptyFunction

    @__didStart config
    return this

  stop: ->
    @_stop no

  finish: ->
    @_stop yes

  _stop: (finished) ->
    return if @isDone
    @_state += 1
    @_cancelAnimationFrame()
    @__didEnd finished
    @_onEnd finished

  _requestAnimationFrame: ->
    if not @_animationFrame
      @_animationFrame = requestAnimationFrame @_recomputeValue
    return

  _cancelAnimationFrame: ->
    if @_animationFrame
      cancelAnimationFrame @_animationFrame
      @_animationFrame = null
    return

  _captureFrame: ->
    frame = @__captureFrame()
    assertType frame, Object
    @_frames.push frame
    return

  _assertNumber: (value) ->
    assertType value, Number

type.defineBoundMethods

  _recomputeValue: ->

    @_animationFrame = null
    return if @isDone

    value = @__computeValue()
    @_onUpdate value
    @__didUpdate value
    @_captureFrame()

    @isDone or @_requestAnimationFrame()
    return

module.exports = Animation = type.build()
