var AnimatedWithChildren, Animation, Event, Immutable, InteractionManager, Type, assertType, getArgProp, type;

assertType = require("assertType");

getArgProp = require("getArgProp");

Immutable = require("immutable");

Event = require("event");

Type = require("Type");

AnimatedWithChildren = require("./AnimatedWithChildren");

Animation = require("./Animation");

InteractionManager = require("./inject/InteractionManager").get();

type = Type("AnimatedValue");

type.inherits(AnimatedWithChildren);

type.defineValues({
  didSet: function() {
    return Event();
  },
  _value: getArgProp(0),
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
    assertType(animation, Animation.Kind);
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
    return InteractionManager.createInteractionHandle();
  },
  _clearInteraction: function(handle) {
    if (!handle) {
      return;
    }
    return InteractionManager.clearInteractionHandle(handle);
  },
  _flush: function() {
    var leaves;
    leaves = Immutable.Set().withMutations((function(_this) {
      return function(leaves) {
        return _this._rake(leaves, _this);
      };
    })(this));
    return leaves.forEach(function(node) {
      return node.update();
    });
  },
  _rake: function(leaves, node) {
    var i, len, ref;
    if (node.update) {
      leaves.add(node);
      return;
    }
    ref = node.__getChildren();
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      this._rake(leaves, node);
    }
  }
});

type.overrideMethods({
  __detach: function() {
    return this.stopAnimation();
  },
  __getValue: function() {
    return this._value;
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/AnimatedValue.map
