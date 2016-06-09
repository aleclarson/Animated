
require "isDev"

emptyFunction = require "emptyFunction"
assertTypes = require "assertTypes"
assertType = require "assertType"
getArgProp = require "getArgProp"
Type = require "Type"

requestAnimationFrame = require("./inject/requestAnimationFrame").get()
cancelAnimationFrame = require("./inject/cancelAnimationFrame").get()

type = Type "Animation"

type.optionTypes =
  isInteraction: Boolean
  captureFrames: Boolean

type.optionDefaults =
  isInteraction: yes
  captureFrames: no

type.bindMethods [
  "_recomputeValue"
]

type.exposeGetters [
  "hasStarted"
  "hasEnded"
]

type.defineValues

  startTime: null

  startValue: null

  _hasStarted: no

  _hasEnded: no

  _isInteraction: getArgProp "isInteraction"

  _animationFrame: null

  _previousAnimation: null

  _onUpdate: null

  _onEnd: null

  _frames: (options) -> [] if options.captureFrames

type.defineMethods

  start: (config) ->

    return if @_hasStarted
    @_hasStarted = yes

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

    @__onStart()
    @_captureFrame()
    return

  stop: ->
    @_stop no

  finish: ->
    @_stop yes

  _stop: (finished) ->
    return if @_hasEnded
    @_hasEnded = yes
    @_cancelAnimationFrame()
    @__onEnd finished

  _recomputeValue: ->

    return if @_hasEnded
    value = @__computeValue()
    assertType value, Number

    @_onUpdate value
    @__didComputeValue value

    return if @_hasEnded
    @_requestAnimationFrame()
    @_captureFrame()

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
    return if not @_frames
    frame = @__captureFrame()
    @_frames.push frame if frame

  __onStart: -> @_requestAnimationFrame()

  __onEnd: emptyFunction

  __captureFrame: emptyFunction

  __didComputeValue: emptyFunction

type.mustOverride [
  "__computeValue"
]

module.exports = Animation = type.build()
