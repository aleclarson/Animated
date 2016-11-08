
{Children, Style} = require "react-validators"

findNodeHandle = require "findNodeHandle"
emptyFunction = require "emptyFunction"
isDev = require "isDev"
Type = require "Type"

NativeAnimated = require "../NativeAnimated"
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

    return if @__isNative
    @__isNative = yes

    for key, animatedValue of @_animatedValues
      animatedValue.__markNative()

    if @_animatedView
      @_connectAnimatedView()
    return

  __getNativeConfig: ->

    props = {}
    for key, animatedValue of @__animatedValues
      props[key] = animatedValue.__getNativeTag()

    isDev and NativeAnimated.validateProps props
    return {type: "props", props}

type.defineMethods

  setAnimatedView: (animatedView) ->

    if @_animatedView
      throw Error "Must first disconnect the current view!"

    @_animatedView = animatedView
    @__isNative and @_connectAnimatedView()
    return

  _connectAnimatedView: ->
    NativeAnimated.connectAnimatedNodeToView @__getNativeTag(), @_getNativeViewTag()
    return

  _disconnectAnimatedView: ->
    NativeAnimated.disconnectAnimatedNodeFromView @__getNativeTag(), @_getNativeViewTag()
    return

  _getNativeViewTag: ->

    unless @__isNative
      throw Error "Must call '__markNative' before '_disconnectAnimatedView'!"

    tag = findNodeHandle @_animatedView
    unless tag?
      throw Error "Must call 'setAnimatedView' before '_connectAnimatedView'!"

    return tag

module.exports = type.build()
