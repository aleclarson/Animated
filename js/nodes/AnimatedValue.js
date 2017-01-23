var AnimatedWithChildren, Animation, Event, NativeAnimated, Tracker, Type, assertType, clampValue, injected, isDev, isType, steal, type;

assertType = require("assertType");

clampValue = require("clampValue");

Tracker = require("tracker");

isType = require("isType");

Event = require("Event");

isDev = require("isDev");

steal = require("steal");

Type = require("Type");

AnimatedWithChildren = require("./AnimatedWithChildren");

NativeAnimated = require("../NativeAnimated");

Animation = require("../Animation");

injected = require("../injectable");

type = Type("AnimatedValue");

type.inherits(AnimatedWithChildren);

type.initInstance(function(_, options) {
  if (options && options.isNative) {
    return this.__markNative();
  }
});

type.defineValues(function(value) {
  return {
    didSet: Event(),
    _dep: Tracker.Dependency(),
    _value: value
  };
});

type.defineReactiveValues({
  _animation: null
});

type.definePrototype({
  value: {
    get: function() {
      throw Error("DEPRECATED: Use the 'get' method!");
    },
    set: function() {
      throw Error("DEPRECATED: Use the 'set' method!");
    }
  }
});

type.defineGetters({
  isAnimating: function() {
    return this._animation !== null;
  },
  animation: function() {
    return this._animation;
  }
});

type.definePrototype({
  type: {
    get: function() {
      return this._type;
    },
    set: function(type) {
      if (!type) {
        assertType(this._value, type);
        frozen.define(this, "_type", type);
      }
    }
  }
});

type.overrideMethods({
  __detach: function() {
    this.stopAnimation();
    return this.__super(arguments);
  },
  __getValue: function() {
    return this._value;
  },
  __updateChildren: function() {
    return this.__super([this.__getValue()]);
  },
  __getNativeConfig: function() {
    return {
      type: "value",
      value: this._value
    };
  }
});

type.defineMethods({
  get: function() {
    if (Tracker.isActive) {
      this._dep.depend();
    }
    return this._value;
  },
  set: function(newValue) {
    this.stopAnimation();
    if (this._type) {
      assertType(newValue, this._type);
    }
    if (this._updateValue(newValue, this.__isNative)) {
      if (this.__isNative && this._children.length) {
        NativeAnimated.setAnimatedNodeValue(this.__getNativeTag(), newValue);
      }
    }
  },
  animate: function(config) {
    var animation, animationType;
    assertType(config, Object);
    config = Object.assign({}, config);
    if (config.useNativeDriver == null) {
      config.useNativeDriver = this.__isNative;
    }
    if (isDev && config.useNativeDriver) {
      if (!(this.didSet.hasListeners || this._children.length)) {
        return log.warn("Must have listeners or animated children!");
      }
    }
    animationType = steal(config, "type");
    isDev && assertType(animationType, String.or(Function.Kind));
    if (isType(animationType, String)) {
      if (isDev && !Animation.types[animationType]) {
        throw Error("Unrecognized animation type: '" + animationType + "'");
      }
      animationType = Animation.types[animationType];
    }
    animation = animationType(config);
    isDev && assertType(animation, Animation.Kind);
    if (config.onEnd) {
      animation.then(config.onEnd);
    }
    return animation.start(this, config.onUpdate);
  },
  stopAnimation: function() {
    if (this._animation) {
      this._animation.stop();
      this._animation = null;
    }
  },
  _updateValue: function(newValue, isNative) {
    var oldValue;
    if (newValue === (oldValue = this._value)) {
      return false;
    }
    this._value = newValue;
    if (!isNative) {
      this.__updateChildren(newValue);
    }
    this._dep.changed();
    this.didSet.emit(newValue, oldValue);
    return true;
  }
});

module.exports = type.build();

//# sourceMappingURL=map/AnimatedValue.map
