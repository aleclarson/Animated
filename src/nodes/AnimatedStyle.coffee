
flattenStyle = require "flattenStyle"
Type = require "Type"

AnimatedTransform = require "./AnimatedTransform"
AnimatedMap = require "./AnimatedMap"

type = Type "AnimatedStyle"

type.inherits AnimatedMap

type.createInstance ->
  return AnimatedMap {}

type.overrideMethods

  attach: (newValues) ->

    if Array.isArray newValues
      newValues = flattenStyle newValues

    @__super arguments
    return this

  __attachValue: (value, key) ->

    if key is "transform" and Array.isArray value
      transform = @__animatedValues[key] or AnimatedTransform()
      transform.attach value
      @__attachAnimatedValue transform, key
      return

    @__super arguments
    return

module.exports = type.build()
