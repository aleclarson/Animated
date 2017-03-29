
{Children, Style} = require "react-validators"

findNodeHandle = require "react/lib/findNodeHandle"

emptyFunction = require "emptyFunction"
isDev = require "isDev"
Type = require "Type"

NativeAnimated = require "../NativeAnimated"
AnimatedStyle = require "./AnimatedStyle"
AnimatedMap = require "./AnimatedMap"

type = Type "AnimatedProps"

type.inherits AnimatedMap

type.defineArgs ->
  required: no
  types: [Object]

type.defineValues (propTypes) ->

  _propTypes: propTypes or {}

  _animatedView: null

#
# Prototype
#

type.overrideMethods

  __detach: ->
    if @__isNative and @_animatedView
      @_disconnectAnimatedView()
    return @__super arguments

  __addChild: emptyFunction

  __updateChildren: (value) ->
    @didSet.emit value

  __removeChild: emptyFunction

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

  __markNative: ->

    # Native animations not supported.
    return unless NativeAnimated.isAvailable

    return if @__isNative
    @__isNative = yes

    if @_animatedView
      @_connectAnimatedView()
    return

  __getNativeConfig: ->

    props = {}
    animatedValues = @__animatedValues
    for key, value of animatedValues
      continue unless value.__isNative
      props[key] = value.__getNativeTag()

    isDev and NativeAnimated.validateProps props
    return {type: "props", props}

type.defineMethods

  setAnimatedView: (animatedView) ->

    if @__isNative and @_animatedView
      @_disconnectAnimatedView()

    @_animatedView = animatedView

    if @__isNative and animatedView
      @_connectAnimatedView()
    return

  _connectAnimatedView: ->

    unless @__isNative
      throw Error "Must call '__markNative' before '_connectAnimatedView'!"

    unless @_animatedView
      throw Error "Must call 'setAnimatedView' before '_connectAnimatedView'!"

    nodeTag = findNodeHandle @_animatedView
    NativeAnimated.connectAnimatedNodeToView @__getNativeTag(), nodeTag
    return

  _disconnectAnimatedView: ->

    unless @__isNative
      throw Error "Must call '__markNative' before '_disconnectAnimatedView'!"

    NativeAnimated.disconnectAnimatedNodeFromView @__getNativeTag()
    return

module.exports = type.build()
