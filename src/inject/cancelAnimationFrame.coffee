
Injectable = require "Injectable"

module.exports = Injectable (id) ->
  global.cancelAnimationFrame id
