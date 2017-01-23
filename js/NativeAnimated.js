var NativeAnimatedModule, NativeEventEmitter, assertType, isDev, nativeEvents, updatedValues;

NativeAnimatedModule = require("NativeModules").NativeAnimatedModule;

NativeEventEmitter = require("NativeEventEmitter");

assertType = require("assertType");

isDev = require("isDev");

if (exports.isAvailable = NativeAnimatedModule != null) {
  Object.assign(exports, NativeAnimatedModule);
  nativeEvents = new NativeEventEmitter(NativeAnimatedModule);
  updatedValues = Object.create(null);
  nativeEvents.addListener("onAnimatedValueUpdate", function(data) {
    var animated, animation;
    if (!(animated = updatedValues[data.tag])) {
      return;
    }
    if (!(animation = animated._animation)) {
      return;
    }
    if (animation._nativeTag === data.animation) {
      animated._updateValue(data.value, true);
    }
  });
  delete exports.startListeningToAnimatedNodeValue;
  exports.addUpdateListener = function(animated) {
    var tag;
    tag = animated.__getNativeTag();
    NativeAnimatedModule.startListeningToAnimatedNodeValue(tag);
    updatedValues[tag] = animated;
  };
  delete exports.stopListeningToAnimatedNodeValue;
  exports.removeUpdateListener = function(animated) {
    var tag;
    tag = animated.__nativeTag;
    NativeAnimatedModule.stopListeningToAnimatedNodeValue(tag);
    delete updatedValues[tag];
  };
  exports.createAnimatedTag = (function() {
    var tag;
    tag = 1;
    return function() {
      return tag++;
    };
  })();
  exports.createAnimationTag = (function() {
    var tag;
    tag = 1;
    return function() {
      return tag++;
    };
  })();
}

isDev && Object.assign(exports, (function() {
  var OneOf, validInterpolation, validProps, validStyles, validTransforms;
  OneOf = require("OneOf");
  validProps = OneOf("style");
  validStyles = OneOf("opacity transform");
  validTransforms = OneOf("translateX translateY scale scaleX scaleY rotate rotateX rotateY perspective");
  validInterpolation = OneOf("inputRange outputRange extrapolate extrapolateRight extrapolateLeft");
  return {
    validateProps: function(props) {
      assertType(props, Object);
      return Object.keys(props).forEach(function(key) {
        if (!validProps.test(key)) {
          throw Error("Property '" + key + "' not supported by native animated module!");
        }
      });
    },
    validateStyle: function(style) {
      assertType(style, Object);
      return Object.keys(style).forEach(function(key) {
        if (!validStyles.test(key)) {
          throw Error("Property '" + key + "' not supported by native animated module!");
        }
      });
    },
    validateTransform: function(transform) {
      assertType(transform, Array);
      return transform.forEach(function(config) {
        if (!validTransforms.test(config.property)) {
          throw Error("Property '" + config.property + "' not supported by native animated module!");
        }
      });
    },
    validateInterpolation: function(config) {
      return Object.keys(config).forEach(function(key) {
        if (!validInterpolation.test(key)) {
          throw Error("Property '" + key + "' not supported by native animated module!");
        }
      });
    }
  };
})());

//# sourceMappingURL=map/NativeAnimated.map