
assertType = require "assertType"
Reaction = require "Reaction"
Tracker = require "tracker"
Event = require "Event"
steal = require "steal"
Type = require "Type"

AnimatedWithChildren = require "./AnimatedWithChildren"
AnimationPath = require "../AnimationPath"
Animation = require "../Animation"

injected = require "../injectable"

type = Type "AnimatedValue"

type.inherits AnimatedWithChildren

type.defineValues (value) ->

  didSet: Event {async: no}

  _dep: Tracker.Dependency()

  _value: value

  _animation: null

type.defineBoundMethods

  _updateValue: (value) ->
    @_value = value
    @_flushNodes()
    @_dep.changed()
    @didSet.emit value

type.definePrototype

  value:
    get: -> throw Error "DEPRECATED: Use the 'get' method!"
    set: -> throw Error "DEPRECATED: Use the 'set' method!"

#
# Prototype
#

type.defineGetters

  isAnimating: -> @_animation isnt null

type.defineMethods

  get: ->
    @_dep.depend() if Tracker.isActive
    return @_value

  set: (value) ->
    @stopAnimation()
    @_updateValue value
    return

  react: (get) ->
    assertType get, Function
    reaction = Reaction get
    reactor = reaction.didSet @_updateValue
    reactor._onDetach = -> reaction.stop()
    reactor.start()
    reaction.start()
    return reactor

  animate: (config) ->
    assertType config, Object

    if onUpdate = steal config, "onUpdate"
      isDev and assertType onUpdate, Function
      updater = @didSet(onUpdate).start()

    onFinish = steal config, "onFinish", emptyFunction
    isDev and assertType onFinish, Function

    onEnd = steal config, "onEnd", emptyFunction
    isDev and assertType onEnd, Function

    type = steal config, "type"
    isDev and assertType type, String.or Function.Kind

    if isType type, String

      if isDev and not Animation.types[type]
        throw Error "Invalid animation type: '#{type}'"

      type = Animation.types[type]

    animation = type config
    isDev and assertType animation, Animation.Kind

    prevAnim.stop() if prevAnim = @_animation
    handle = @_createInteraction animation
    @_animation = animation.start
      previousAnimation: prevAnim
      startValue: @_value
      onUpdate: @_updateValue
      onEnd: (finished) =>
        @_animation = null
        @_clearInteraction handle
        updater and updater.detach()
        finished and onFinish()
        onEnd finished

  stopAnimation: ->
    if @_animation
      @_animation.stop()
      @_animation = null
    return

  createPath: (values) ->
    assertType values, Array
    path = AnimationPath()
    path.listener = @didSet (newValue) ->
      index = -1
      maxIndex = values.length - 1
      while newValue >= values[++index]
        break if index is maxIndex
      startValue = values[index - 1]
      if startValue is undefined
        index += 1
        progress = 0
      else
        progress = (newValue - startValue) / (values[index] - startValue)
        progress = clampValue progress, 0, 1
      path._update index - 1, progress
      return
    return path

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
    return @_value

module.exports = type.build()
