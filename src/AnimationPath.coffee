
assertType = require "assertType"
Type = require "Type"

type = Type "AnimationPath"

type.defineValues ->

  _paths: []

type.defineMethods

  attach: (value, nodes) ->
    if isDev
      AnimatedValue = require "./nodes/AnimatedValue"
      assertType value, AnimatedValue
      assertType nodes, Array

    path = {}
    index = -1

    # Connect the dots of each animation path.
    for node in nodes

      if path.endValue isnt undefined
        path = {startValue: path.endValue}

      if path.startValue is undefined
        assertType node, Number
        path.startValue = node

      else if typeof node is "function"
        path.easing = node

      else
        assertType node, Number
        path.endValue = node
        path.easing ?= emptyFunction.thatReturnsArgument
        @_attach ++index, value, path

    if path.endValue is undefined
      throw Error "Animation path is missing an 'endValue'!"

    return this

  _attach: (index, value, { startValue, endValue, easing }) ->
    distance = endValue - startValue
    @_paths.push [] if @_paths.length <= index
    @_paths[index].push (progress) ->
      value.set startValue + distance * easing progress

  _update: (index, progress) ->
    for update in @_paths[index]
      update progress
    return

module.exports = type.build()
