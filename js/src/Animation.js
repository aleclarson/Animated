var Animation, Type, assertType, assertTypes, cancelAnimationFrame, emptyFunction, getArgProp, requestAnimationFrame, type;

require("isDev");

emptyFunction = require("emptyFunction");

assertTypes = require("assertTypes");

assertType = require("assertType");

getArgProp = require("getArgProp");

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
  _isInteraction: getArgProp("isInteraction"),
  _animationFrame: null,
  _previousAnimation: null,
  _onUpdate: null,
  _onEnd: null,
  _frames: function(options) {
    if (options.captureFrames) {
      return [];
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
    this.__onStart();
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
    return this.__onEnd(finished);
  },
  _recomputeValue: function() {
    var value;
    if (this._hasEnded) {
      return;
    }
    value = this.__computeValue();
    assertType(value, Number);
    this._onUpdate(value);
    this.__didComputeValue(value);
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
    if (!this._frames) {
      return;
    }
    frame = this.__captureFrame();
    if (frame) {
      return this._frames.push(frame);
    }
  },
  __onStart: function() {
    return this._requestAnimationFrame();
  },
  __onEnd: emptyFunction,
  __captureFrame: emptyFunction,
  __didComputeValue: emptyFunction
});

type.mustOverride(["__computeValue"]);

module.exports = Animation = type.build();

//# sourceMappingURL=../../map/src/Animation.map
