var injectable;

injectable = {
  InteractionManager: require("./InteractionManager"),
  requestAnimationFrame: require("./requestAnimationFrame"),
  cancelAnimationFrame: require("./cancelAnimationFrame")
};

module.exports = function(key, value) {
  injectable[key].inject(value);
};

//# sourceMappingURL=../../../map/src/inject/index.map
