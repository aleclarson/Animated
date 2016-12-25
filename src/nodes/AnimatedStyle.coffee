
flattenStyle = require "flattenStyle"
Type = require "Type"

AnimatedTransform = require "./AnimatedTransform"
NativeAnimated = require "../NativeAnimated"
AnimatedMap = require "./AnimatedMap"

type = Type "AnimatedStyle"

type.inherits AnimatedMap

type.overrideMethods

  attach: (newValues) ->
    @__super [flattenStyle newValues]
    return this

  __attachValue: (value, key) ->

    if key is "transform" and Array.isArray value
      transform = @__animatedValues[key] or AnimatedTransform()
      transform.attach value
      @__attachAnimatedValue transform, key
      return

    @__super arguments
    return

  __detachAnimatedValues: (newValues) ->
    @__super [flattenStyle newValues]
    return

  __attachNewValues: (newValues) ->
    @__super [flattenStyle newValues]
    return

  __getNativeConfig: ->

    style = {}
    for key, animatedValue of @__animatedValues
      if animatedValue.__isNative
        style[key] = animatedValue.__getNativeTag()

    isDev and NativeAnimated.validateStyle style
    return {type: "style", style}

module.exports = type.build()
