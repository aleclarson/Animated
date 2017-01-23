var AnimatedMap, AnimatedTransform, NativeAnimated, Type, flattenStyle, type;

flattenStyle = require("flattenStyle");

Type = require("Type");

AnimatedTransform = require("./AnimatedTransform");

NativeAnimated = require("../NativeAnimated");

AnimatedMap = require("./AnimatedMap");

type = Type("AnimatedStyle");

type.inherits(AnimatedMap);

type.overrideMethods({
  attach: function(newValues) {
    this.__super([flattenStyle(newValues)]);
    return this;
  },
  __attachValue: function(value, key) {
    var transform;
    if (key === "transform" && Array.isArray(value)) {
      transform = this.__animatedValues[key] || AnimatedTransform();
      transform.attach(value);
      this.__attachAnimatedValue(transform, key);
      return;
    }
    this.__super(arguments);
  },
  __detachAnimatedValues: function(newValues) {
    this.__super([flattenStyle(newValues)]);
  },
  __attachNewValues: function(newValues) {
    this.__super([flattenStyle(newValues)]);
  },
  __getNativeConfig: function() {
    var animatedValues, key, style, value;
    style = {};
    animatedValues = this.__animatedValues;
    for (key in animatedValues) {
      value = animatedValues[key];
      if (!value.__isNative) {
        continue;
      }
      style[key] = value.__getNativeTag();
    }
    isDev && NativeAnimated.validateStyle(style);
    return {
      type: "style",
      style: style
    };
  }
});

module.exports = type.build();

//# sourceMappingURL=map/AnimatedStyle.map