
InjectableMap = require "InjectableMap"
emptyFunction = require "emptyFunction"
Shape = require "Shape"

injectable = InjectableMap
  requestAnimationFrame: Function
  cancelAnimationFrame: Function
  InteractionManager: Shape
    createInteractionHandle: Function
    clearInteractionHandle: Function

injectable.inject

  requestAnimationFrame: (func) ->
    global.requestAnimationFrame func

  cancelAnimationFrame: (id) ->
    global.cancelAnimationFrame id

  InteractionManager:
    createInteractionHandle: emptyFunction
    clearInteractionHandle: emptyFunction

module.exports = injectable
