var AnimatedWithChildren, Animation, Event, Type, assertType, injected, type;

assertType = require("assertType");

Event = require("Event");

Type = require("Type");

AnimatedWithChildren = require("./AnimatedWithChildren");

Animation = require("./Animation");

injected = require("./injectable");

type = Type("AnimatedValue");

type.inherits(AnimatedWithChildren);

type.defineValues(function(value) {
  return {
    didSet: Event(),
    _value: value,
    _animation: null,
    _tracking: null
  };
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
    this._flushNodes();
    return this.didSet.emit(this.__getValue());
  },
  _createInteraction: function(animation) {
    if (!animation.__isInteraction) {
      return null;
    }
    return injected.get("InteractionManager").createInteractionHandle();
  },
  _clearInteraction: function(handle) {
    if (!handle) {
      return;
    }
    return injected.get("InteractionManager").clearInteractionHandle(handle);
  },
  _flushNodes: function() {
    var i, len, node, nodes;
    nodes = new Set();
    this._gatherNodes(this, nodes);
    for (i = 0, len = nodes.length; i < len; i++) {
      node = nodes[i];
      node.update();
    }
  },
  _gatherNodes: function(node, cache) {
    var i, len, ref;
    if (node.update) {
      cache.add(node);
      return;
    }
    ref = node.__getChildren();
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      this._gatherNodes(node, cache);
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

//# sourceMappingURL=map/AnimatedValue.map
