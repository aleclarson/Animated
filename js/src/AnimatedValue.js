var AnimatedWithChildren, Animation, Event, InteractionManager, Set, assertType, type;

assertType = require("type-utils").assertType;

Event = require("event");

Set = require("es6-set");

AnimatedWithChildren = require("./AnimatedWithChildren");

InteractionManager = require("./InteractionManager");

Animation = require("./Animation");

type = Type("AnimatedValue");

type.inherits(AnimatedWithChildren);

type.defineValues({
  didSet: function() {
    return Event();
  },
  _value: function(value) {
    return value;
  },
  _animation: null,
  _tracking: null
});

type.defineMethods({
  setValue: function(value) {
    if (this._animation) {
      this._animation.stop();
      this._animation = null;
    }
    this._updateValue(value);
  },
  track: function(animated) {
    this.stopTracking();
    this._tracking = animated;
  },
  stopTracking: function() {
    if (this._tracking) {
      this._tracking.__detach();
      this._tracking = null;
    }
  },
  animate: function(animation, onEnd) {
    var handle, previousAnimation;
    assertType(animation, Animation);
    handle = this._createInteraction(animation);
    previousAnimation = this._animation;
    if (previousAnimation) {
      previousAnimation.stop();
    }
    this._animation = animation;
    return animation.start({
      previousAnimation: previousAnimation,
      startValue: this._value,
      onUpdate: (function(_this) {
        return function(value) {
          return _this._updateValue(value);
        };
      })(this),
      onEnd: (function(_this) {
        return function(result) {
          _this._animation = null;
          _this._clearInteraction(handle);
          if (onEnd) {
            return onEnd(result);
          }
        };
      })(this)
    });
  },
  stopAnimation: function() {
    this.stopTracking();
    if (this._animation) {
      this._animation.stop();
      this._animation = null;
    }
  },
  _updateValue: function(value) {
    this._value = value;
    this._flush();
    return this.didSet.emit(this.__getValue());
  },
  _createInteraction: function(animation) {
    if (!animation.__isInteraction) {
      return null;
    }
    return InteractionManager.createHandle();
  },
  _clearInteraction: function(handle) {
    if (!handle) {
      return;
    }
    return InteractionManager.clearHandle(handle);
  },
  _flush: function() {
    var animatedStyles;
    animatedStyles = new Set;
    this._findAnimatedStyles(this);
    return animatedStyles.forEach(function(animatedStyle) {
      return animatedStyle.update();
    });
  },
  _findAnimatedStyles: function(node) {
    if (node.update) {
      return animatedStyles.add(node);
    } else {
      return node.__getChildren().forEach(this._findAnimatedStyles);
    }
  },
  __detach: function() {
    return this.stopAnimation();
  },
  __getValue: function() {
    return this._value;
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/AnimatedValue.map
