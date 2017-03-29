
Type = require "Type"

NativeAnimated = require "../NativeAnimated"
Animated = require "./Animated"

type = Type "AnimatedWithChildren"

type.inherits Animated

type.defineFrozenValues ->

  _children: []

  _childKeys: []

type.overrideMethods

  __getChildren: ->
    return @_children

  __addChild: (child, key) ->

    # Native nodes cannot have non-native children.
    @__isNative and child.__markNative()

    @_children.push child
    @_childKeys.push key

    if @_children.length is 0
      @__attach()
    return

  __updateChildren: (value) ->
    children = @__getChildren()
    for child, index in children
      if child.__isAnimatedTransform
        update = child.__getAllValues()
      else
        key = @_childKeys[index]
        update = {}
        update[key] = value
      child.__updateChildren update
    return

  __removeChild: (child) ->

    index = @_children.indexOf child
    return if index < 0

    if @__isNative and child.__isNative
      NativeAnimated.disconnectAnimatedNodes @__getNativeTag(), child.__getNativeTag()

    @_children.splice index, 1
    @_childKeys.splice index, 1

    if @_children.length is 0
      @__detach()
    return

  __markNative: ->

    # Native animations not supported.
    return unless NativeAnimated.isAvailable

    return if @__isNative
    @__isNative = yes

    children = @_children
    for child, index in children
      child.__markNative() # Native nodes cannot have non-native children.
    return

module.exports = type.build()
