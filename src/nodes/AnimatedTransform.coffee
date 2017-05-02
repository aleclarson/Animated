
assertType = require "assertType"
isType = require "isType"
isDev = require "isDev"
Type = require "Type"

NativeAnimated = require "../NativeAnimated"
AnimatedValue = require "./AnimatedValue"
AnimatedMap = require "./AnimatedMap"
Animated = require "./Animated"

type = Type "AnimatedTransform"

type.inherits AnimatedMap

type.defineValues

  _updatedValues: null

type.definePrototype

  __isAnimatedTransform: yes

type.overrideMethods

  # All previous `Animated` nodes must be detached.
  __detachAnimatedValues: ->
    @__detachAllValues()

  # If one value is native, all values are considered native.
  __getNonNativeValues: ->
    throw Error "AnimatedTransform cannot be partially native!"

  __didUpdateValue: ->
    @_didUpdate()
    return

  __getUpdatedValue: ->
    return @__getAllValues()

  __getAllValues: ->

    transforms = []

    for key, value of @_values
      [index, key] = key.split "."
      transforms[index] = transform = {}
      transform[key] = value

    animatedValues = @_animatedValues
    for key, value of animatedValues
      [index, key] = key.split "."
      transforms[index] = transform = {}
      transform[key] = value.__getValue()

    return transforms

  __attachNewValues: (transforms) ->
    assertType transforms, Array
    for transform, index in transforms
      @__attachValue transform, index
    return

  __attachValue: (transform, index) ->
    return unless isType transform, Object
    for key, value of transform
      key = index + "." + key
      if value instanceof Animated
      then @__attachAnimatedValue value, key
      else @_values[key] = value
    return

  __getNativeConfig: ->
    transforms = []

    type = "static"
    for key, value of @_values
      [index, property] = key.split "."
      transforms[index] = {type, property, value}

    type = "animated"
    animatedValues = @_animatedValues
    for key, value of animatedValues
      [index, property] = key.split "."
      nodeTag = value.__getNativeTag()
      transforms[index] = {type, property, nodeTag}

    isDev and NativeAnimated.validateTransform transforms
    return {type: "transform", transforms}

module.exports = type.build()
