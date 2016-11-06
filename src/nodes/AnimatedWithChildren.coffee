
Type = require "Type"

Animated = require "./Animated"

type = Type "AnimatedWithChildren"

type.inherits Animated

type.defineFrozenValues

  _children: -> []

type.overrideMethods

  __getChildren: ->
    @_children

  __addChild: (child) ->
    @__attach() if @_children.length is 0
    @_children.push child

  __removeChild: (child) ->
    index = @_children.indexOf child
    return if index < 0
    @_children.splice index, 1
    @__detach() if @_children.length is 0

module.exports = type.build()
