var NativeAnimated, Type, emptyFunction, type;

emptyFunction = require("emptyFunction");

Type = require("Type");

NativeAnimated = require("../NativeAnimated");

type = Type("Animated");

type.defineValues({
  __isNative: false,
  __nativeTag: null
});

type.defineHooks({
  __attach: emptyFunction,
  __detach: function() {
    if (this.__isNative && (this.__nativeTag != null)) {
      NativeAnimated.dropAnimatedNode(this.__nativeTag);
      this.__nativeTag = null;
    }
  },
  __getValue: null,
  __addChild: emptyFunction,
  __removeChild: emptyFunction,
  __getChildren: emptyFunction.thatReturns([]),
  __updateChildren: emptyFunction,
  __markNative: function() {
    if (!this.__isNative) {
      throw Error("This animated node is not supported by the native animated module!");
    }
  },
  __getNativeTag: function() {
    return this.__nativeTag || this.__createNativeTag();
  },
  __createNativeTag: function() {
    var tag;
    if (!NativeAnimated.isAvailable) {
      throw Error("Failed to load NativeAnimatedModule!");
    }
    if (!this.__isNative) {
      throw Error("Must call '__markNative' before '__getNativeTag'!");
    }
    this.__nativeTag = tag = NativeAnimated.createAnimatedTag();
    NativeAnimated.createAnimatedNode(tag, this.__getNativeConfig());
    return tag;
  },
  __getNativeConfig: function() {
    throw Error("This subclass of Animated is not supported by the NativeAnimatedModule!");
  }
});

module.exports = type.build();

//# sourceMappingURL=map/Animated.map
