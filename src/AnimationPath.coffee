
assertType = require "assertType"
LazyVar = require "LazyVar"
Type = require "Type"

# Avoid circular dependency.
AnimatedValue = LazyVar -> require "./nodes/AnimatedValue"

type = Type "AnimationPath"

type.defineValues ->

  _paths: []

type.defineMethods

  attach: (value, nodes) ->
    assertType value, AnimatedValue.get()
    assertType nodes, Array

    path = {}
    index = -1

    # Connect the dots of each animation path.
    for node in nodes

      if path.toValue isnt undefined
        path = {fromValue: path.toValue}

      if path.fromValue is undefined
        assertType node, Number
        path.fromValue = node

      else if typeof node is "function"
        path.easing = node

      else
        assertType node, Number
        path.toValue = node
        path.easing ?= emptyFunction.thatReturnsArgument
        @_attach ++index, value, path

    if path.toValue is undefined
      throw Error "Animation path is missing its 'toValue'!"

    return this

  _attach: (index, value, { fromValue, toValue, easing }) ->
    distance = toValue - fromValue
    @_paths.push [] if @_paths.length <= index
    @_paths[index].push (progress) ->
      value.set fromValue + distance * easing progress

  _update: (index, progress) ->
    for update in @_paths[index]
      update progress
    return

module.exports = type.build()
