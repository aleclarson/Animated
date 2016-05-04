var Injectable, emptyFunction;

emptyFunction = require("emptyFunction");

Injectable = require("Injectable");

module.exports = Injectable.Map({
  types: {
    createHandle: Function,
    clearHandle: Function
  },
  values: {
    createHandle: emptyFunction,
    clearHandle: emptyFunction
  }
});

//# sourceMappingURL=../../map/src/InteractionManager.map
