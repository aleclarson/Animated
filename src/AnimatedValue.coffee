
{ assertType } = require "type-utils"

Event = require "event"
Set = require "es6-set"

AnimatedWithChildren = require "./AnimatedWithChildren"
InteractionManager = require "./InteractionManager"
Animation = require "./Animation"

type = Type "AnimatedValue"

type.inherits AnimatedWithChildren

type.defineValues

  didSet: -> Event()

  _value: (value) -> value

  _animation: null

  _tracking: null

type.defineMethods

  setValue: (value) ->
    if @_animation
      @_animation.stop()
      @_animation = null
    @_updateValue value
    return

  track: (animated) ->
    @stopTracking()
    @_tracking = animated
    return

  stopTracking: ->
    if @_tracking
      @_tracking.__detach()
      @_tracking = null
    return

  animate: (animation, onEnd) ->

    assertType animation, Animation

    handle = @_createInteraction animation

    previousAnimation = @_animation
    previousAnimation.stop() if previousAnimation
    @_animation = animation

    animation.start {
      previousAnimation
      startValue: @_value
      onUpdate: (value) => @_updateValue value
      onEnd: (result) =>
        @_animation = null
        @_clearInteraction handle
        onEnd result if onEnd
    }

  stopAnimation: ->
    @stopTracking()
    if @_animation
      @_animation.stop()
      @_animation = null
    return

  _updateValue: (value) ->
    @_value = value
    @_flush()
    @didSet.emit @__getValue()

  _createInteraction: (animation) ->
    return null unless animation.__isInteraction
    InteractionManager.createHandle()

  _clearInteraction: (handle) ->
    return unless handle
    InteractionManager.clearHandle handle

  _flush: ->
    animatedStyles = new Set
    @_findAnimatedStyles this
    animatedStyles.forEach (animatedStyle) ->
      animatedStyle.update()

  _findAnimatedStyles: (node) ->
    if node.update then animatedStyles.add node
    else node.__getChildren().forEach @_findAnimatedStyles

  __detach: ->
    @stopAnimation()

  __getValue: ->
    @_value

module.exports = type.build()
