
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

type.definePrototype

  __isAnimatedTransform: yes

type.overrideMethods

  __getAllValues: ->

    transforms = []

    for key, value of @__values
      [index, key] = key.split "."
      transforms[index] = transform = {}
      transform[key] = value

    animatedValues = @__animatedValues
    for key, value of animatedValues
      [index, key] = key.split "."
      transforms[index] = transform = {}
      transform[key] = value.__getValue()

    return transforms

  # If an `AnimatedTransform` node has a native value, all values are considered native.
  __getNonNativeValues: ->
    throw Error "AnimatedTransform::__getNonNativeValues is not supported"

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
      else @__values[key] = value
    return

  # When an `AnimatedTransform` updates its value,
  # all previous `Animated` nodes are detached.
  __detachAnimatedValues: ->
    @__detachAllValues()

  __getNativeConfig: ->
    transforms = []

    type = "static"
    for key, value of @__values
      [index, property] = key.split "."
      transforms[index] = {type, property, value}

    type = "animated"
    animatedValues = @__animatedValues
    for key, value of animatedValues
      [index, property] = key.split "."
      nodeTag = value.__getNativeTag()
      transforms[index] = {type, property, nodeTag}

    isDev and NativeAnimated.validateTransform transforms
    return {type: "transform", transforms}

module.exports = type.build()
