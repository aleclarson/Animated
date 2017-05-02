
assertType = require "assertType"
isType = require "isType"
Type = require "Type"

AnimatedWithChildren = require "./AnimatedWithChildren"
NativeAnimated = require "../NativeAnimated"
AnimatedStyle = require "./AnimatedStyle"
AnimatedValue = require "./AnimatedValue"
Animated = require "./Animated"

type = Type "AnimatedMap"

type.inherits AnimatedWithChildren

type.defineValues ->

  _values: {}

  _animatedValues: {}

  _updatedValues: {}

type.definePrototype

  __isAnimatedMap: yes

type.defineMethods

  # Pre-existing static values are not clobbered.
  attach: (newValues) ->
    @__detachAnimatedValues newValues
    @__attachNewValues newValues
    @__isNative and @__connectNativeValues()
    return

type.overrideMethods

  __getValue: ->
    return @__getAllValues()

  __getUpdatedValue: ->

    values = {}
    for key, value of @_updatedValues
      values[key] = value.__getUpdatedValue()

    @_updatedValues = {}
    return values

type.defineHooks

  __didUpdateValue: (key, value) ->
    @_updatedValues[key] = value
    @_didUpdate()
    return

  # Returns an object of all values (including native values).
  # This should be used when creating a new `ReactElement`.
  __getAllValues: ->
    values = {}
    for key, value of @_values
      values[key] =
        if animatedValue = @_animatedValues[key]
        then animatedValue.__getValue()
        else value
    return values

  # Returns an object of all values (except native values).
  # This should be used when re-rendering an existing `ReactElement`.
  __getNonNativeValues: do ->

    # `AnimatedMap` nodes can be partially native, while `AnimatedValue`
    # and `AnimatedTransform` nodes cannot be partially native.
    isNative = (animatedValue) ->
      return no unless animatedValue.__isNative
      return yes unless animatedValue.__isAnimatedMap
      return animatedValue.__isAnimatedTransform

    return ->
      values = {}
      for key, value of @_values
        if animatedValue = @_animatedValues[key]
          unless isNative animatedValue
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
      map = @_animatedValues[key] or AnimatedMap {}
      map.attach value
      @__attachAnimatedValue map, key
      return

    @_values[key] = value
    return

  __attachAnimatedValue: (animatedValue, key) ->
    return if @_animatedValues[key]
    @_values[key] = undefined # <= Preserve key order within this._values
    @_animatedValues[key] = animatedValue
    animatedValue.__addChild this, key
    return

  __connectNativeValues: ->
    animatedValues = @_animatedValues
    nativeTags = []
    for key, value of animatedValues
      continue unless value.__isNative
      nativeTags.push value.__getNativeTag()
    if nativeTags.length
      NativeAnimated.connectAnimatedNodes nativeTags, @__getNativeTag()
    return

  #
  # Detaching values
  #

  # Completely resets the `AnimatedMap` node.
  __detachAllValues: ->

    for key, animatedValue of @_animatedValues
      animatedValue.__removeChild this

    @_values = {}
    @_animatedValues = {}
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
    delete @_animatedValues[key]

  # Detaches any `Animated` nodes that have new values.
  __detachAnimatedValues: (newValues) ->
    assertType newValues, Object
    animatedValues = @_animatedValues
    for key, value of animatedValues
      @__detachAnimatedValue value, newValues[key]
    return

module.exports = AnimatedMap = type.build()
