var AnimationFrame, InteractionManager;

AnimationFrame = require("./AnimationFrame");

InteractionManager = require("./InteractionManager");

module.exports = {
  requestAnimationFrame: function(fn) {
    return AnimationFrame.inject.set("requestFrame", fn);
  },
  clearAnimationFrame: function(fn) {
    return AnimationFrame.inject.set("clearFrame", fn);
  },
  createInteractionHandle: function(fn) {
    return InteractionManager.inject.set("createHandle", fn);
  },
  clearInteractionHandle: function(fn) {
    return InteractionManager.inject.set("clearHandle", fn);
  }
};

//# sourceMappingURL=../../map/src/inject.map
