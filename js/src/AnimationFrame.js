var Injectable;

Injectable = require("Injectable");

module.exports = Injectable.Map({
  types: {
    requestFrame: Function,
    clearFrame: Function
  },
  values: {
    requestFrame: function(fn) {
      return global.requestAnimationFrame(fn);
    },
    clearFrame: function(id) {
      return global.cancelAnimationFrame(id);
    }
  }
});

//# sourceMappingURL=../../map/src/AnimationFrame.map
