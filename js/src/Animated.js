var Type, emptyFunction, type;

emptyFunction = require("emptyFunction");

Type = require("Type");

type = Type("Animated");

type.mustOverride(["__attach", "__detach", "__getValue"]);

type.defineMethods({
  __getAnimatedValue: function() {
    return this.__getValue();
  },
  __addChild: emptyFunction,
  __removeChild: emptyFunction,
  __getChildren: emptyFunction.thatReturns([])
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/Animated.map
