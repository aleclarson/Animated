
Injectable = require "Injectable"

module.exports = Injectable (func) ->
  global.requestAnimationFrame func
