var Injectable;

Injectable = require("Injectable");

module.exports = Injectable(function(func) {
  return global.requestAnimationFrame(func);
});

//# sourceMappingURL=../../../map/src/inject/requestAnimationFrame.map
