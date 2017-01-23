var AnimatedValue, Animation, LazyVar, NativeAnimated, Number, Type, assertType, emptyFunction, injected, isDev, type;

Number = require("Nan").Number;

emptyFunction = require("emptyFunction");

assertType = require("assertType");

LazyVar = require("LazyVar");

isDev = require("isDev");

Type = require("Type");

NativeAnimated = require("./NativeAnimated");

injected = require("./injectable");

AnimatedValue = LazyVar(function() {
  return require("./nodes/AnimatedValue");
});

type = Type("Animation");

type.trace();

type.defineStatics({
  types: Object.create(null)
});

type.defineOptions({
  fromValue: Number,
  isInteraction: Boolean.withDefault(true),
  useNativeDriver: Boolean.withDefault(false),
  captureFrames: Boolean.withDefault(false)
});

type.initArgs((function() {
  var hasWarned;
  hasWarned = false;
  return function(args) {
    if (!args[0].useNativeDriver) {
      return;
    }
    if (NativeAnimated.isAvailable || hasWarned) {
      return;
    }
    args[0].useNativeDriver = false;
    log.warn("Failed to load NativeAnimatedModule! Falling back to JS-driven animations.");
    return hasWarned = true;
  };
})());

type.defineValues(function(options) {
  var ref;
  return {
    startTime: null,
    fromValue: (ref = options.fromValue) != null ? ref : null,
    _state: 0,
    _isInteraction: options.isInteraction,
    _useNativeDriver: options.useNativeDriver,
    _nativeTag: null,
    _animationFrame: null,
    _previousAnimation: null,
    _onUpdate: emptyFunction,
    _onEnd: emptyFunction,
    _onEndQueue: [],
    _frames: options.captureFrames ? [] : void 0,
    _captureFrame: !options.captureFrames ? emptyFunction : void 0
  };
});

type.defineBoundMethods({
  _recomputeValue: function() {
    var value;
    this._animationFrame = null;
    if (this.isDone) {
      return;
    }
    value = this.__computeValue();
    this.__onAnimationUpdate(value);
    this._captureFrame();
    this._onUpdate(value);
    this.isDone || this._requestAnimationFrame();
  }
});

type.defineGetters({
  isPending: function() {
    return this._state === 0;
  },
  isActive: function() {
    return this._state === 1;
  },
  isDone: function() {
    return this._state === 2;
  }
});

type.defineHooks({
  __computeValue: null,
  __onAnimationStart: function(animated) {
    if (this._useNativeDriver) {
      return this._startNativeAnimation(animated);
    } else {
      return this._requestAnimationFrame();
    }
  },
  __onAnimationUpdate: emptyFunction,
  __onAnimationEnd: emptyFunction,
  __captureFrame: emptyFunction,
  __getNativeConfig: function() {
    throw Error("This animation type does not support native offloading!");
  }
});

type.defineMethods({
  start: function(animated, onUpdate) {
    var animation, id;
    assertType(animated, AnimatedValue.get());
    assertType(onUpdate, Function.Maybe);
    if (!this.isPending) {
      return this;
    }
    this._state += 1;
    if (this._isInteraction) {
      id = this._createInteraction();
    }
    animation = animated._animation;
    if (animation != null) {
      animation.stop();
    }
    this._previousAnimation = animation;
    if (onUpdate) {
      onUpdate = animated.didSet(onUpdate).start();
    }
    if (!this._useNativeDriver) {
      this._onUpdate = function(newValue) {
        return animated._updateValue(newValue, false);
      };
    }
    this._onEnd = (function(_this) {
      return function(finished) {
        _this._onEnd = emptyFunction;
        _this._onUpdate = emptyFunction;
        animated._animation = null;
        if (onUpdate != null) {
          onUpdate.detach();
        }
        if (_this._useNativeDriver) {
          NativeAnimated.removeUpdateListener(animated);
        }
        _this._clearInteraction(id);
        _this.__onAnimationEnd(finished);
        _this._flushEndQueue(finished);
      };
    })(this);
    animated._animation = this;
    this._startAnimation(animated);
    return this;
  },
  stop: function(finished) {
    if (finished == null) {
      finished = false;
    }
    isDev && assertType(finished, Boolean);
    return this._stopAnimation(finished);
  },
  then: function(onEnd) {
    var queue;
    isDev && assertType(onEnd, Function);
    if (queue = this._onEndQueue) {
      queue.push(onEnd);
    }
    return this;
  },
  _requestAnimationFrame: function(callback) {
    return this._animationFrame || (this._animationFrame = injected.call("requestAnimationFrame", callback || this._recomputeValue));
  },
  _cancelAnimationFrame: function() {
    if (this._animationFrame) {
      injected.call("cancelAnimationFrame", this._animationFrame);
      this._animationFrame = null;
    }
  },
  _startAnimation: function(animated) {
    this.startTime = Date.now();
    if (this.fromValue != null) {
      animated._updateValue(this.fromValue, this._useNativeDriver);
    } else {
      this.fromValue = animated._value;
    }
    return this.__onAnimationStart(animated);
  },
  _startNativeAnimation: function(animated) {
    var animatedTag, animationConfig;
    this._nativeTag = NativeAnimated.createAnimationTag();
    animated.__markNative();
    animatedTag = animated.__getNativeTag();
    animationConfig = this.__getNativeConfig();
    NativeAnimated.addUpdateListener(animated);
    return NativeAnimated.startAnimatingNode(this._nativeTag, animatedTag, animationConfig, (function(_this) {
      return function(data) {
        if (_this.isDone) {
          return;
        }
        _this._state += 1;
        _this._onEnd(data.finished);
      };
    })(this));
  },
  _stopAnimation: function(finished) {
    if (this.isDone) {
      return;
    }
    this._state += 1;
    if (this._nativeTag) {
      NativeAnimated.stopAnimation(this._nativeTag);
    } else {
      this._cancelAnimationFrame();
    }
    this._onEnd(finished);
  },
  _flushEndQueue: function(finished) {
    var i, len, onEnd, queue;
    queue = this._onEndQueue;
    this._onEndQueue = null;
    for (i = 0, len = queue.length; i < len; i++) {
      onEnd = queue[i];
      onEnd(finished);
    }
  },
  _captureFrame: function() {
    var frame;
    frame = this.__captureFrame();
    assertType(frame, Object);
    this._frames.push(frame);
  },
  _assertNumber: function(value) {
    return assertType(value, Number);
  },
  _createInteraction: function() {
    return injected.get("InteractionManager").createInteractionHandle();
  },
  _clearInteraction: function(handle) {
    return (handle != null) && injected.get("InteractionManager").clearInteractionHandle(handle);
  }
});

module.exports = Animation = type.build();

//# sourceMappingURL=map/Animation.map