
emptyFunction = require "emptyFunction"
Injectable = require "Injectable"

injectable =

  requestAnimationFrame: Injectable (func) ->
    global.requestAnimationFrame func

  cancelAnimationFrame: Injectable (id) ->
    global.cancelAnimationFrame id

  InteractionManager: Injectable
    createInteractionHandle: emptyFunction
    clearInteractionHandle: emptyFunction

exports.get = (key) ->
  injectable[key].get()

exports.inject = (key, value) ->
  injectable[key].inject value
