
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
    @__attach() if @_children.length is 0
    @_children.push child
    @_childKeys.push key
    if @__isNative
      child.__markNative() # Native nodes cannot have non-native children.
      NativeAnimated.connectAnimatedNodes @__getNativeTag(), child.__getNativeTag()
    return

  __updateChildren: (value) ->
    children = @__getChildren()
    for child, index in children
      child.__updateValue value, @_childKeys[index]
    return

  __updateValue: (value, key) ->
    newValues = {}
    newValues[key] = value
    @__updateChildren newValues

  __removeChild: (child) ->
    index = @_children.indexOf child
    return if index < 0
    if @__isNative and child.__isNative
      NativeAnimated.disconnectAnimatedNodes @__getNativeTag(), child.__getNativeTag()
    @_children.splice index, 1
    @_childKeys.splice index, 1
    @__detach() if @_children.length is 0
    return

  __markNative: ->
    return if @__isNative
    @__isNative = yes
    for child, index in @_children
      child.__markNative() # Native nodes cannot have non-native children.
      NativeAnimated.connectAnimatedNodes @__getNativeTag(), child.__getNativeTag()
    return

module.exports = type.build()
