
assertType = require "assertType"
clampValue = require "clampValue"
Tracker = require "tracker"
isType = require "isType"
Event = require "eve"
isDev = require "isDev"
steal = require "steal"
Type = require "Type"

AnimatedWithChildren = require "./AnimatedWithChildren"
NativeAnimated = require "../NativeAnimated"
Animation = require "../Animation"

injected = require "../injectable"

type = Type "AnimatedValue"

type.inherits AnimatedWithChildren

type.initInstance (_, options) ->
  if options and options.isNative
    @__markNative()

type.defineValues (value) ->

  didSet: Event()

  _dep: Tracker.Dependency()

  _value: value

type.defineReactiveValues

  _animation: null

type.definePrototype

  value:
    get: -> throw Error "DEPRECATED: Use the 'get' method!"
    set: -> throw Error "DEPRECATED: Use the 'set' method!"

#
# Prototype
#

type.defineGetters

  isAnimating: -> @_animation isnt null

  animation: -> @_animation

type.definePrototype

  type:
    get: -> @_type
    set: (type) ->
      unless type
        assertType @_value, type
        frozen.define this, "_type", type
      return

type.overrideMethods

  __detach: ->
    @stopAnimation()
    @__super arguments

  __getValue: ->
    return @_value

  __getUpdatedValue: ->
    return @_value

  __getNativeConfig: ->
    {type: "value", value: @_value}

type.defineMethods

  get: ->
    @_dep.depend() if Tracker.isActive
    return @_value

  set: (newValue) ->
    @stopAnimation()
    assertType newValue, @_type if @_type
    if @_updateValue newValue, @__isNative
      if @__isNative and @_children.length
        NativeAnimated.setAnimatedNodeValue @__getNativeTag(), newValue
    return

  animate: (config) ->
    assertType config, Object

    # Clone the `config` so it can be reused.
    config = Object.assign {}, config
    config.useNativeDriver ?= @__isNative

    if isDev and config.useNativeDriver
      unless @didSet.hasListeners or @_children.length
        return log.warn "Must have listeners or animated children!"

    animationType = steal config, "type"
    isDev and assertType animationType, String.or Function.Kind

    if isType animationType, String
      if isDev and not Animation.types[animationType]
        throw Error "Unrecognized animation type: '#{animationType}'"
      animationType = Animation.types[animationType]

    animation = animationType config
    isDev and assertType animation, Animation.Kind

    animation.then config.onEnd if config.onEnd
    return animation.start this, config.onUpdate

  stopAnimation: ->
    if @_animation
      @_animation.stop()
      @_animation = null
    return

  _updateValue: (newValue, isNative) ->

    return no if newValue is oldValue = @_value

    @_value = newValue
    isNative or @_didUpdate()

    @_dep.changed()
    @didSet.emit newValue, oldValue
    return yes

module.exports = type.build()
