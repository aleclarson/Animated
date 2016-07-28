var Type, emptyFunction, type;

emptyFunction = require("emptyFunction");

Type = require("Type");

type = Type("Animated");

type.defineHooks({
  __attach: null,
  __detach: null,
  __getValue: null,
  __addChild: emptyFunction,
  __removeChild: emptyFunction,
  __getChildren: emptyFunction.thatReturns([]),
  __getAnimatedValue: function() {
    return this.__getValue();
  }
});

module.exports = type.build();

//# sourceMappingURL=map/Animated.map
