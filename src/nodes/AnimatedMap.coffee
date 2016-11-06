
cloneObject = require "cloneObject"
assertType = require "assertType"
isType = require "isType"
Event = require "Event"
Type = require "Type"

AnimatedValue = require "./AnimatedValue"
Animated = require "./Animated"

type = Type "AnimatedMap"

type.defineFrozenValues

  didSet: -> Event {async: no}

type.defineValues (values) ->

  __values: values

  __animatedListeners: {}

  __animatedValues: {}

type.defineMethods

  attach: (newValues) ->
    @__detachOldValues newValues
    @__attachNewValues newValues
    return this

  detach: ->
    @__detachAnimatedValues()
    @__animatedValues = {}
    @__animatedListeners = {}
    return

type.defineHooks

  __getValue: ->

    values = cloneObject @__values

    for key, animatedValue of @__animatedValues
      values[key] = animatedValue.__getValue()

    return values

  __didSet: (newValues) ->
    @didSet.emit newValues

  #
  # Attaching values
  #

  __attachNewValues: (newValues) ->
    assertType newValues, Object
    for key, value of newValues
      @__attachValue value, key
    return

  __attachValue: (value, key) ->

    if value instanceof Animated
      @__attachAnimatedValue value, key
      return

    if isType value, Object
      map = @__animatedValues[key] or AnimatedMap {}
      map.attach value
      @__attachAnimatedValue map, key
      return

    @__values[key] = value
    return

  __attachAnimatedValue: (animatedValue, key) ->
    if not @__animatedValues[key]
      @__values[key] = undefined # <= Preserve key order within this.__values
      @__animatedValues[key] = animatedValue
      @__attachAnimatedListener animatedValue, key
    return

  __attachAnimatedListener: (animatedValue, key) ->

    onChange = (newValue) =>
      newValues = {}
      newValues[key] = newValue
      @__didSet newValues

    listener = animatedValue.didSet onChange
    @__animatedListeners[key] = listener.start()
    return

  #
  # Detaching values
  #

  __detachAnimatedValues: ->
    for key, animatedValue of @__animatedValues
      @__detachAnimatedListener animatedValue, key
    return

  __detachAnimatedListener: (animatedValue, key) ->
    @__animatedListeners[key].stop()
    delete @__animatedListeners[key]
    return

  __detachOldValues: (newValues) ->
    assertType newValues, Object
    animatedValues = @__animatedValues
    for key, animatedValue of animatedValues
      if animatedValue is newValues[key]
        if animatedValue instanceof AnimatedMap
          animatedValue.__detachOldValues newValues[key]
      else
        @__detachAnimatedListener animatedValue, key
        if animatedValue instanceof AnimatedMap
          animatedValue.detach()
        delete animatedValues[key]
    return

module.exports = AnimatedMap = type.build()
