
assertType = require "assertType"
clampValue = require "clampValue"
Tracker = require "tracker"
isType = require "isType"
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

  didSet: Event()

  _dep: Tracker.Dependency()

  _value: value

type.defineReactiveValues

  _animation: null

type.defineBoundMethods

  _updateValue: (value, isNative) ->
    oldValue = @_value
    return if value is oldValue
    @_value = value
    @__updateChildren value unless isNative
    @_dep.changed()
    @didSet.emit value, oldValue

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
    if @__isNative and @_children.length
      NativeAnimated.setAnimatedNodeValue @__getNativeTag(), value
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
