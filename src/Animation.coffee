
require "isDev"

emptyFunction = require "emptyFunction"
assertTypes = require "assertTypes"
assertType = require "assertType"
fromArgs = require "fromArgs"
Type = require "Type"

requestAnimationFrame = require("./inject/requestAnimationFrame").get()
cancelAnimationFrame = require("./inject/cancelAnimationFrame").get()

type = Type "Animation"

type.defineOptions
  isInteraction: Boolean.withDefault yes
  captureFrames: Boolean.withDefault no

type.defineValues

  startTime: null

  startValue: null

  _state: 0

  _isInteraction: fromArgs "isInteraction"

  _animationFrame: null

  _previousAnimation: null

  _onUpdate: null

  _onEnd: null

  _frames: (options) ->
    [] if options.captureFrames

  _captureFrame: (options) ->
    emptyFunction if not options.captureFrames

type.defineGetters

  isPending: -> @_state is 0

  isActive: -> @_state is 1

  isDone: -> @_state is 2

type.defineHooks

  __computeValue: null

  __didStart: -> @_requestAnimationFrame()

  __didEnd: emptyFunction

  __didUpdate: emptyFunction

  __captureFrame: emptyFunction

type.defineMethods

  start: (config) ->

    return if not @isPending
    @_state += 1

    assertTypes config,
      startValue: Number
      onUpdate: Function
      onEnd: Function

    @startTime = Date.now()
    @startValue = config.startValue

    @_onUpdate = config.onUpdate
    @_onEnd = config.onEnd

    if config.previousAnimation instanceof Animation
      @_previousAnimation = config.previousAnimation

    @__didStart()
    @_captureFrame()
    return

  stop: ->
    @_stop no

  finish: ->
    @_stop yes

  _stop: (finished) ->
    return if @isDone
    @_state += 1
    @_cancelAnimationFrame()
    @__didEnd finished

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

type.defineBoundMethods

  _recomputeValue: ->

    @_animationFrame = null
    return if @isDone

    value = @__computeValue()
    assertType value, Number

    @_onUpdate value
    @__didUpdate value

    return if @isDone
    @_requestAnimationFrame()
    @_captureFrame()

module.exports = Animation = type.build()
