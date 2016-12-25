
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

  didSet: -> Event()

type.defineValues ->

  __values: {}

  __animatedValues: {}

type.definePrototype

  __isAnimatedMap: yes

type.defineMethods

  attach: (newValues) ->
    @__detachOldValues newValues
    @__attachNewValues newValues
    return

type.overrideMethods

  __updateChildren: (value) ->
    @__super arguments
    @didSet.emit value

type.defineHooks

  __getInitialValue: ->
    values = {}
    for key, value of @__values
      values[key] =
        if animatedValue = @__animatedValues[key]
          if animatedValue.__isAnimatedMap
          then animatedValue.__getInitialValue()
          else animatedValue._value
        else value
    return values

  __getValue: do ->

    isNative = (animatedValue) ->
      if animatedValue.__isAnimatedMap
      then animatedValue.__isAnimatedTransform
      else animatedValue.__isNative

    return ->
      values = {}
      for key, value of @__values
        if animatedValue = @__animatedValues[key]
          continue if isNative animatedValue
          values[key] = animatedValue.__getValue()
        else values[key] = value
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
    return if @__animatedValues[key]
    @__values[key] = undefined # <= Preserve key order within this.__values
    @__animatedValues[key] = animatedValue
    animatedValue.__addChild this, key
    return

  #
  # Detaching values
  #

  # Completely resets the `AnimatedMap` node.
  __detachAllValues: ->

    for key, animatedValue of @_animatedValues
      animatedValue.__removeChild this

    @__values = {}
    @__animatedValues = {}
    return

  # Detaches an `Animated` node if it has a new value.
  __detachAnimatedValue: (animatedValue, newValue) ->

    # Since `AnimatedMap` nodes are created internally,
    # we don't bother checking object equivalence.
    if animatedValue.__isAnimatedMap

      if newValue?
        # Traverse `AnimatedMap` nodes recursively.
        animatedValue.__detachAnimatedValues newValue
        return

      # Perform cleanup on detached `AnimatedMap` nodes.
      animatedValue.__detachAllValues()

    else
      # Abort if the same `AnimatedValue` node was passed.
      return if animatedValue is newValue

    animatedValue.__removeChild this
    delete @__animatedValues[key]

  # Detaches any `Animated` nodes that have new values.
  __detachAnimatedValues: (newValues) ->
    assertType newValues, Object
    animatedValues = @__animatedValues
    for key, animatedValue of animatedValues
      @__detachAnimatedValue animatedValue, newValues[key]
    return

module.exports = AnimatedMap = type.build()
