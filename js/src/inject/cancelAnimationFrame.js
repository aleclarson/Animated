var Injectable;

Injectable = require("Injectable");

module.exports = Injectable(function(id) {
  return global.cancelAnimationFrame(id);
});

//# sourceMappingURL=../../../map/src/inject/cancelAnimationFrame.map
