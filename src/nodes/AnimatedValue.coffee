
assertType = require "assertType"
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

type.defineValues (value) ->

  didSet: Event {async: no}

  _dep: Tracker.Dependency()

  _value: value

type.defineReactiveValues

  _animation: null

type.defineBoundMethods

  _updateValue: (value, isNative) ->
    @_value = value
    isNative or @__updateChildren value
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
    @__isNative and NativeAnimated.setAnimatedNodeValue @__getNativeTag(), value
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

    @_animation = animation.start this, (finished) =>
      @_animation = null
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

  _createNativeValueListener: ->
    log.it @__name + "._createNativeValueListener()"
    NativeAnimated.addUpdateListener this
    return

  _deleteNativeValueListener: ->
    log.it @__name + "._deleteNativeValueListener()"
    NativeAnimated.removeUpdateListener this
    return

module.exports = type.build()
