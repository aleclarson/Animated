
emptyFunction = require "emptyFunction"
Type = require "Type"

type = Type "Animated"

type.defineHooks

  __attach: null

  __detach: null

  __getValue: null

  __addChild: emptyFunction

  __removeChild: emptyFunction

  __getChildren: emptyFunction.thatReturns []

  # Only gets the values that are animated.
  __getAnimatedValue: ->
    return @__getValue()

module.exports = type.build()
