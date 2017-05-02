// Generated by CoffeeScript 1.12.4
var InjectableMap, Shape, emptyFunction, injectable;

InjectableMap = require("InjectableMap");

emptyFunction = require("emptyFunction");

Shape = require("Shape");

injectable = InjectableMap({
  requestAnimationFrame: Function,
  cancelAnimationFrame: Function,
  InteractionManager: Shape({
    createInteractionHandle: Function,
    clearInteractionHandle: Function
  })
});

injectable.inject({
  requestAnimationFrame: function(func) {
    return global.requestAnimationFrame(func);
  },
  cancelAnimationFrame: function(id) {
    return global.cancelAnimationFrame(id);
  },
  InteractionManager: {
    createInteractionHandle: emptyFunction,
    clearInteractionHandle: emptyFunction
  }
});

module.exports = injectable;