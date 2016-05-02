
emptyFunction = require "emptyFunction"
Type = require "Type"

type = Type "Animated"

type.defineMethods

  __attach: ->
    throw Error "Must override 'Animated::__attach'!"

  __detach: ->
    throw Error "Must override 'Animated::__detach'!"

  __getValue: ->
    throw Error "Must override 'Animated::__getValue'!"

  # Only gets the values that are animated.
  __getAnimatedValue: ->
    return @__getValue()

  __addChild: emptyFunction

  __removeChild: emptyFunction

  __getChildren: ->
    return []

module.exports = type.build()
