
emptyFunction = require "emptyFunction"
Type = require "Type"

NativeAnimated = require "../NativeAnimated"

type = Type "Animated"

type.defineValues

  __isNative: no

  __nativeTag: null

type.defineHooks

  __attach: emptyFunction

  __detach: ->
    if @__isNative and @__nativeTag?
      NativeAnimated.dropAnimatedNode @__nativeTag
      @__nativeTag = null
    return

  __getValue: null

  __addChild: emptyFunction

  __removeChild: emptyFunction

  __getChildren: emptyFunction.thatReturns []

  __updateChildren: emptyFunction

  __updateValue: emptyFunction

  __markNative: ->
    unless @__isNative
      throw Error "This animated node is not supported by the native animated module!"

  __getNativeTag: ->

    unless NativeAnimated.isAvailable
      throw Error "Failed to load NativeAnimatedModule!"

    unless @__isNative
      throw Error "Must call '__markNative' before '__getNativeTag'!"

    unless tag = @__nativeTag
      @__nativeTag = tag = NativeAnimated.createAnimatedTag()
      NativeAnimated.createAnimatedNode tag, @__getNativeConfig()

    return tag

  __getNativeConfig: ->
    throw Error "This subclass of Animated is not supported by the NativeAnimatedModule!"

module.exports = type.build()
