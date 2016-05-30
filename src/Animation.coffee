
require "isDev"

emptyFunction = require "emptyFunction"
assertTypes = require "assertTypes"
assertType = require "assertType"
getArgProp = require "getArgProp"
Type = require "Type"

requestAnimationFrame = require("./inject/requestAnimationFrame").get()
cancelAnimationFrame = require("./inject/cancelAnimationFrame").get()

if isDev

  configTypes = {}

  configTypes.start =
    startValue: Number
    onUpdate: Function
    onEnd: Function

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

    assertTypes config, configTypes.start if isDev

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
    return if @_animationFrame
    @_animationFrame = requestAnimationFrame @_recomputeValue

  _cancelAnimationFrame: ->
    return if not @_animationFrame
    cancelAnimationFrame @_animationFrame
    @_animationFrame = null

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
