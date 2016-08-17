
Type = require "Type"

Animated = require "./Animated"

type = Type "AnimatedMap"

type.inherits Animated

type.defineArgs
  values: Object.isRequired
  onUpdate: Function.isRequired

type.defineFrozenValues (values, onUpdate) ->

  _values: values

  _onUpdate: onUpdate

type.initInstance ->

  @__attach()

type.defineMethods

  update: ->
    @_callback()

type.overrideMethods

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
