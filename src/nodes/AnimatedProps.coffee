
{Children, Style} = require "modx"

Type = require "Type"

AnimatedStyle = require "./AnimatedStyle"
AnimatedMap = require "./AnimatedMap"

type = Type "AnimatedProps"

type.inherits AnimatedMap

type.defineArgs
  propTypes: Object

type.createInstance ->
  return AnimatedMap {}

type.defineValues (propTypes) ->

  _propTypes: propTypes or {}

type.overrideMethods

  __attachValue: (value, key) ->

    type = @_propTypes[key] if @_propTypes

    if type is Children
      @__values[key] = value
      return

    if type is Style and value?
      style = @__animatedValues[key] or AnimatedStyle()
      style.attach value
      @__attachAnimatedValue style, key
      return

    @__super arguments
    return

module.exports = type.build()
