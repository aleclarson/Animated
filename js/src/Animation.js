var Animation, Type, assertType, assertTypes, cancelAnimationFrame, emptyFunction, fromArgs, requestAnimationFrame, type;

require("isDev");

emptyFunction = require("emptyFunction");

assertTypes = require("assertTypes");

assertType = require("assertType");

fromArgs = require("fromArgs");

Type = require("Type");

requestAnimationFrame = require("./inject/requestAnimationFrame").get();

cancelAnimationFrame = require("./inject/cancelAnimationFrame").get();

type = Type("Animation");

type.optionTypes = {
  isInteraction: Boolean,
  captureFrames: Boolean
};

type.optionDefaults = {
  isInteraction: true,
  captureFrames: false
};

type.bindMethods(["_recomputeValue"]);

type.exposeGetters(["hasStarted", "hasEnded"]);

type.defineValues({
  startTime: null,
  startValue: null,
  _hasStarted: false,
  _hasEnded: false,
  _isInteraction: fromArgs("isInteraction"),
  _animationFrame: null,
  _previousAnimation: null,
  _onUpdate: null,
  _onEnd: null,
  _frames: function(options) {
    if (options.captureFrames) {
      return [];
    }
  },
  _captureFrame: function(options) {
    if (!options.captureFrames) {
      return emptyFunction;
    }
  }
});

type.defineMethods({
  start: function(config) {
    if (this._hasStarted) {
      return;
    }
    this._hasStarted = true;
    assertTypes(config, {
      startValue: Number,
      onUpdate: Function,
      onEnd: Function
    });
    this.startTime = Date.now();
    this.startValue = config.startValue;
    this._onUpdate = config.onUpdate;
    this._onEnd = config.onEnd;
    if (config.previousAnimation instanceof Animation) {
      this._previousAnimation = config.previousAnimation;
    }
    this.__didStart();
    this._captureFrame();
  },
  stop: function() {
    return this._stop(false);
  },
  finish: function() {
    return this._stop(true);
  },
  _stop: function(finished) {
    if (this._hasEnded) {
      return;
    }
    this._hasEnded = true;
    this._cancelAnimationFrame();
    return this.__didEnd(finished);
  },
  _recomputeValue: function() {
    var value;
    this._animationFrame = null;
    if (this._hasEnded) {
      return;
    }
    value = this.__computeValue();
    assertType(value, Number);
    this._onUpdate(value);
    this.__didUpdate(value);
    if (this._hasEnded) {
      return;
    }
    this._requestAnimationFrame();
    return this._captureFrame();
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
    return this._frames.push(frame);
  },
  __didStart: function() {
    return this._requestAnimationFrame();
  },
  __didEnd: emptyFunction,
  __didUpdate: emptyFunction,
  __captureFrame: emptyFunction
});

type.mustOverride(["__computeValue"]);

module.exports = Animation = type.build();

//# sourceMappingURL=map/Animation.map
