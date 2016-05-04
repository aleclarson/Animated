
Injectable = require "Injectable"

module.exports = Injectable.Map

  types: {
    requestFrame: Function
    clearFrame: Function
  }

  values: {
    requestFrame: (fn) -> global.requestAnimationFrame fn
    clearFrame: (id) -> global.cancelAnimationFrame id
  }
