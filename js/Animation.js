var Animation, Number, Type, assertType, assertTypes, cancelAnimationFrame, emptyFunction, isType, requestAnimationFrame, type;

Number = require("Nan").Number;

emptyFunction = require("emptyFunction");

assertTypes = require("assertTypes");

assertType = require("assertType");

isType = require("isType");

Type = require("Type");

requestAnimationFrame = require("./inject/requestAnimationFrame").get();

cancelAnimationFrame = require("./inject/cancelAnimationFrame").get();

type = Type("Animation");

type.defineOptions({
  startValue: Number,
  isInteraction: Boolean.withDefault(true),
  captureFrames: Boolean.withDefault(false)
});

type.defineValues(function(options) {
  var ref;
  return {
    startTime: null,
    startValue: (ref = options.startValue) != null ? ref : null,
    _state: 0,
    _isInteraction: options.isInteraction,
    _animationFrame: null,
    _previousAnimation: null,
    _onUpdate: null,
    _onEnd: null,
    _frames: options.captureFrames ? [] : void 0,
    _captureFrame: !options.captureFrames ? emptyFunction : void 0
  };
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
  __didStart: function(config) {
    this.startTime = Date.now();
    this.startValue = config.startValue;
    return this._requestAnimationFrame();
  },
  __didEnd: emptyFunction,
  __didUpdate: emptyFunction,
  __captureFrame: emptyFunction
});

type.defineMethods({
  start: function(config) {
    if (!this.isPending) {
      return;
    }
    this._state += 1;
    if (config.previousAnimation instanceof Animation) {
      this._previousAnimation = config.previousAnimation;
    }
    if (this.startValue !== null) {
      config.startValue = this.startValue;
    }
    this._onUpdate = config.onUpdate || emptyFunction;
    this._onEnd = config.onEnd || emptyFunction;
    this.__didStart(config);
  },
  stop: function() {
    return this._stop(false);
  },
  finish: function() {
    return this._stop(true);
  },
  _stop: function(finished) {
    if (this.isDone) {
      return;
    }
    this._state += 1;
    this._cancelAnimationFrame();
    this.__didEnd(finished);
    return this._onEnd(finished);
  },
  _requestAnimationFrame: function() {
    if (!this._animationFrame) {
      this._animationFrame = requestAnimationFrame(this._recomputeValue);
    }
  },
  _cancelAnimationFrame: function() {
    if (this._animationFrame) {
      cancelAnimationFrame(this._animationFrame);
      this._animationFrame = null;
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
  }
});

type.defineBoundMethods({
  _recomputeValue: function() {
    var value;
    this._animationFrame = null;
    if (this.isDone) {
      return;
    }
    value = this.__computeValue();
    this._onUpdate(value);
    this.__didUpdate(value);
    this._captureFrame();
    this.isDone || this._requestAnimationFrame();
  }
});

module.exports = Animation = type.build();

//# sourceMappingURL=map/Animation.map
