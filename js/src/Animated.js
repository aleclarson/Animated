var Type, emptyFunction, type;

emptyFunction = require("emptyFunction");

Type = require("Type");

type = Type("Animated");

type.defineMethods({
  __attach: function() {
    throw Error("Must override 'Animated::__attach'!");
  },
  __detach: function() {
    throw Error("Must override 'Animated::__detach'!");
  },
  __getValue: function() {
    throw Error("Must override 'Animated::__getValue'!");
  },
  __getAnimatedValue: function() {
    return this.__getValue();
  },
  __addChild: emptyFunction,
  __removeChild: emptyFunction,
  __getChildren: function() {
    return [];
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/Animated.map