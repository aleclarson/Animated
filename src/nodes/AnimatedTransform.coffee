
assertType = require "assertType"
isType = require "isType"
Type = require "Type"

AnimatedValue = require "./AnimatedValue"
AnimatedMap = require "./AnimatedMap"

type = Type "AnimatedTransform"

type.inherits AnimatedMap

type.createInstance ->
  return AnimatedMap {}

type.overrideMethods

  # All values are refreshed when attaching new values.
  __didSet: (newValues) ->
    @didSet.emit @values

  __getValue: ->

    transforms = []

    for key, value of @__values
      [index, key] = key.split "."
      transform = transforms[index] ?= {}
      transform[key] = value

    for key, animatedValue of @__animatedValues
      [index, key] = key.split "."
      transform = transforms[index] ?= {}
      transform[key] = animatedValue.__getValue()

    return transforms

  __attachNewValues: (transforms) ->
    assertType transforms, Array
    for transform, index in transforms
      @__attachValue transform, index
    return

  __attachValue: (transform, index) ->

    return if not isType transform, Object

    for key, value of transform

      key = index + "." + key

      if value instanceof AnimatedValue
        @__attachAnimatedValue value, key
      else @__values[key] = value

    return

  # All values are refreshed when attaching new values.
  __detachOldValues: ->
    @detach()

module.exports = type.build()
