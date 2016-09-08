var Injectable, emptyFunction, injectable;

emptyFunction = require("emptyFunction");

Injectable = require("Injectable");

injectable = {
  requestAnimationFrame: Injectable(function(func) {
    return global.requestAnimationFrame(func);
  }),
  cancelAnimationFrame: Injectable(function(id) {
    return global.cancelAnimationFrame(id);
  }),
  InteractionManager: Injectable({
    createInteractionHandle: emptyFunction,
    clearInteractionHandle: emptyFunction
  })
};

exports.get = function(key) {
  return injectable[key].get();
};

exports.inject = function(key, value) {
  return injectable[key].inject(value);
};

//# sourceMappingURL=map/injectable.map
