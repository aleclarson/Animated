
emptyFunction = require "emptyFunction"
Type = require "Type"

type = Type "Animated"

type.mustOverride [
  "__attach"
  "__detach"
  "__getValue"
]

type.defineMethods

  # Only gets the values that are animated.
  __getAnimatedValue: ->
    return @__getValue()

  __addChild: emptyFunction

  __removeChild: emptyFunction

  __getChildren: emptyFunction.thatReturns []

module.exports = type.build()
