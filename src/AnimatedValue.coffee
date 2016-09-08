
assertType = require "assertType"
Event = require "Event"
Type = require "Type"

AnimatedWithChildren = require "./AnimatedWithChildren"
Animation = require "./Animation"

injected = require "./injectable"

type = Type "AnimatedValue"

type.inherits AnimatedWithChildren

type.defineValues (value) ->

  didSet: Event()

  _value: value

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

    assertType animation, Animation.Kind

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
    @_flushNodes()
    @didSet.emit @__getValue()

  _createInteraction: (animation) ->
    return null unless animation.__isInteraction
    injected.get("InteractionManager").createInteractionHandle()

  _clearInteraction: (handle) ->
    return unless handle
    injected.get("InteractionManager").clearInteractionHandle handle

  # Updates every 'Animated' instance
  # that has an 'update' function.
  _flushNodes: ->
    nodes = new Set()
    @_gatherNodes this, nodes
    node.update() for node in nodes
    return

  # Gathers every 'Animated' instance
  # that has an 'update' function.
  _gatherNodes: (node, cache) ->

    if node.update
      cache.add node
      return

    for node in node.__getChildren()
      @_gatherNodes node, cache
    return

type.overrideMethods

  __detach: ->
    @stopAnimation()

  __getValue: ->
    @_value

module.exports = type.build()
