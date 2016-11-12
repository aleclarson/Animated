
assertType = require "assertType"
clampValue = require "clampValue"
Reaction = require "Reaction"
Tracker = require "tracker"
Event = require "Event"
isDev = require "isDev"
steal = require "steal"
Type = require "Type"

AnimatedWithChildren = require "./AnimatedWithChildren"
NativeAnimated = require "../NativeAnimated"
AnimationPath = require "../AnimationPath"
Animation = require "../Animation"

injected = require "../injectable"

type = Type "AnimatedValue"

type.inherits AnimatedWithChildren

type.initInstance (_, options) ->
  if options and options.isNative
    @__markNative()

type.defineValues (value) ->

  didSet: Event {async: no}

  _dep: Tracker.Dependency()

  _value: value

type.defineReactiveValues

  _animation: null

type.defineBoundMethods

  _updateValue: (value, isNative) ->
    return if value is @_value
    @_value = value
    @__updateChildren value unless isNative
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

type.overrideMethods

  __detach: ->
    @stopAnimation()
    @__super arguments

  __getValue: ->
    return @_value

  __updateChildren: ->
    @__super [@__getValue()]

  __getNativeConfig: ->
    {type: "value", value: @_value}

type.defineMethods

  get: ->
    @_dep.depend() if Tracker.isActive
    return @_value

  set: (value) ->
    @stopAnimation()
    @_updateValue value, @__isNative
    if @__isNative
      NativeAnimated.setAnimatedNodeValue @__getNativeTag(), value
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

    unless @_children.length
      throw Error "Cannot 'animate' unless attached to a mounted view!"

    type = steal config, "type"
    isDev and assertType type, String.or Function.Kind

    if isType type, String

      if isDev and not Animation.types[type]
        throw Error "Invalid animation type: '#{type}'"

      type = Animation.types[type]

    onUpdate = steal config, "onUpdate"
    onFinish = steal config, "onFinish", emptyFunction
    onEnd = steal config, "onEnd", emptyFunction

    if isDev
      assertType onUpdate, Function.Maybe
      assertType onFinish, Function
      assertType onEnd, Function

    config.useNativeDriver ?= @__isNative

    animation = type config
    isDev and assertType animation, Animation.Kind

    if onUpdate
      isDev and assertType onUpdate, Function
      updater = @didSet(onUpdate).start()

    @_animation = animation.start this, (finished) =>
      @_animation = null
      updater?.detach()
      onFinish() if finished
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
      fromValue = values[index - 1]
      if fromValue is undefined
        index += 1
        progress = 0
      else
        progress = (newValue - fromValue) / (values[index] - fromValue)
        progress = clampValue progress, 0, 1
      path._update index - 1, progress
      return
    return path

module.exports = type.build()
