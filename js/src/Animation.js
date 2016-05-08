var Animation, AnimationFrame, Type, configTypes, emptyFunction, type;

require("isDev");

emptyFunction = require("emptyFunction");

Type = require("Type");

AnimationFrame = require("./AnimationFrame");

if (isDev) {
  configTypes = {};
  configTypes.start = {
    startValue: Number,
    onUpdate: Function,
    onEnd: Function
  };
}

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
  _isInteraction: function(options) {
    return options.isInteraction;
  },
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
  __onStart: function() {
    return this._requestAnimationFrame();
  },
  __onEnd: emptyFunction,
  __captureFrame: emptyFunction,
  __computeValue: function() {
    throw Error("Must override 'Animation::__computeValue'!");
  },
  __didComputeValue: emptyFunction,
  start: function(config) {
    if (this._hasStarted) {
      return;
    }
    this._hasStarted = true;
    if (isDev) {
      validateTypes(config, configTypes.start);
    }
    this.startTime = Date.now();
    this.startValue = config.startValue;
    this._onUpdate = config.onUpdate;
    this._onEnd = config.onEnd;
    if (isType(previousAnimation, Animation.Kind)) {
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
    if (this._animationFrame) {
      return;
    }
    return this._animationFrame = AnimationFrame.requestFrame(this._recomputeValue);
  },
  _cancelAnimationFrame: function() {
    if (!this._animationFrame) {
      return;
    }
    AnimationFrame.clearFrame(this._animationFrame);
    return this._animationFrame = null;
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
  }
});

module.exports = Animation = type.build();

//# sourceMappingURL=../../map/src/Animation.map
