
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

  __getInitialValue: -> @__getValue()

  __getValue: ->
    transforms = []

    for key, value of @__values
      [index, key] = key.split "."
      transform = transforms[index] = {}
      transform[key] = value

    for key, animatedValue of @__animatedValues
      [index, key] = key.split "."
      transform = transforms[index] = {}
      transform[key] = animatedValue.__getValue()

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
      else @__values[key] = value
    return

  __detachOldValues: ->
    @detach()

  __onParentUpdate: ->
    @__updateChildren @__getValue()

  __getNativeConfig: ->
    transforms = []

    type = "static"
    for key, value of @__values
      [index, property] = key.split "."
      transforms[index] = {type, property, value}

    type = "animated"
    for key, animatedValue of @__animatedValues
      [index, property] = key.split "."
      nodeTag = animatedValue.__getNativeTag()
      transforms[index] = {type, property, nodeTag}

    isDev and NativeAnimated.validateTransform transforms
    return {type: "transform", transforms}

module.exports = type.build()
