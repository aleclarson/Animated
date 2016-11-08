
cloneObject = require "cloneObject"
assertType = require "assertType"
isType = require "isType"
Event = require "Event"
Type = require "Type"

AnimatedWithChildren = require "./AnimatedWithChildren"
AnimatedStyle = require "./AnimatedStyle"
AnimatedValue = require "./AnimatedValue"
Animated = require "./Animated"

type = Type "AnimatedMap"

type.inherits AnimatedWithChildren

type.defineFrozenValues

  didSet: -> Event {async: no}

type.defineValues (values) ->

  __values: values

  __animatedValues: {}

type.definePrototype

  __isAnimatedMap: yes

type.defineMethods

  attach: (newValues) ->
    @__detachOldValues newValues
    @__attachNewValues newValues
    @__attach()
    return

  detach: ->

    for key, animatedValue of @_animatedValues
      animatedValue.__removeChild this

    @__values = {}
    @__animatedValues = {}
    @__detach()
    return

type.overrideMethods

  __updateChildren: (value) ->
    @__super arguments
    @didSet.emit value

type.defineHooks

  __getValue: ->

    values = cloneObject @__values

    for key, animatedValue of @__animatedValues

      if animatedValue.__isAnimatedMap
        continue if animatedValue.__isAnimatedTransform

      else if animatedValue.__isNative
        continue

      values[key] = animatedValue.__getValue()

    return values

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
      animatedValue.__addChild this, key
      @__values[key] = undefined # <= Preserve key order within this.__values
      @__animatedValues[key] = animatedValue
    return

  #
  # Detaching values
  #

  __detachOldValues: (newValues) ->
    assertType newValues, Object
    animatedValues = @__animatedValues
    for key, animatedValue of animatedValues
      if animatedValue is newValues[key]
        if animatedValue.__isAnimatedMap
          animatedValue.__detachOldValues newValues[key]
      else
        if animatedValue.__isAnimatedMap
          animatedValue.detach()
        delete animatedValues[key]
    return

module.exports = AnimatedMap = type.build()
