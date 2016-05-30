
getArgProp = require "getArgProp"
Type = require "Type"

Animated = require "./Animated"

type = Type "AnimatedMap"

type.inherits Animated

type.argumentTypes =
  values: Object
  onUpdate: Function

type.defineFrozenValues

  _values: getArgProp 0

  _onUpdate: getArgProp 1

type.initInstance ->

  @__attach()

type.defineMethods

  update: ->
    @_callback()

  __getValue: ->
    values = {}
    for key, value of @_values
      if value instanceof Animated
        values[key] = value.__getValue()
      else values[key] = value
    return values

  __getAnimatedValue: ->
    values = {}
    for key, value of @_values
      continue unless value instanceof Animated
      values[key] = value.__getAnimatedValue()
    return values

  __attach: ->
    for key, value of @_values
      continue unless value instanceof Animated
      value.__addChild this
    return

  __detach: ->
    for key, value of @_values
      continue unless value instanceof Animated
      value.__removeChild this
    return

module.exports = type.build()
