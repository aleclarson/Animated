var AnimatedMap, AnimatedStyle, Children, NativeAnimated, Style, Type, emptyFunction, findNodeHandle, isDev, ref, type;

ref = require("react-validators"), Children = ref.Children, Style = ref.Style;

findNodeHandle = require("findNodeHandle");

emptyFunction = require("emptyFunction");

isDev = require("isDev");

Type = require("Type");

NativeAnimated = require("../NativeAnimated");

AnimatedStyle = require("./AnimatedStyle");

AnimatedMap = require("./AnimatedMap");

type = Type("AnimatedProps");

type.inherits(AnimatedMap);

type.defineArgs({
  propTypes: Object
});

type.defineValues(function(propTypes) {
  return {
    _propTypes: propTypes || {},
    _animatedView: null
  };
});

type.overrideMethods({
  __detach: function() {
    if (this.__isNative && this._animatedView) {
      this._disconnectAnimatedView();
    }
    return this.__super(arguments);
  },
  __addChild: emptyFunction,
  __updateChildren: function(value) {
    return this.didSet.emit(value);
  },
  __removeChild: emptyFunction,
  __attachValue: function(value, key) {
    var style;
    if (this._propTypes) {
      type = this._propTypes[key];
    }
    if (type === Children) {
      this.__values[key] = value;
      return;
    }
    if (type === Style && (value != null)) {
      style = this.__animatedValues[key] || AnimatedStyle();
      style.attach(value);
      this.__attachAnimatedValue(style, key);
      return;
    }
    this.__super(arguments);
  },
  __markNative: function() {
    if (this.__isNative) {
      return;
    }
    this.__isNative = true;
    if (this._animatedView) {
      this._connectAnimatedView();
    }
  },
  __getNativeConfig: function() {
    var animatedValues, key, props, value;
    props = {};
    animatedValues = this.__animatedValues;
    for (key in animatedValues) {
      value = animatedValues[key];
      if (!value.__isNative) {
        continue;
      }
      props[key] = value.__getNativeTag();
    }
    isDev && NativeAnimated.validateProps(props);
    return {
      type: "props",
      props: props
    };
  }
});

type.defineMethods({
  setAnimatedView: function(animatedView) {
    if (this.__isNative && this._animatedView) {
      this._disconnectAnimatedView();
    }
    this._animatedView = animatedView;
    if (this.__isNative && animatedView) {
      this._connectAnimatedView();
    }
  },
  _connectAnimatedView: function() {
    var nodeTag;
    if (!this.__isNative) {
      throw Error("Must call '__markNative' before '_connectAnimatedView'!");
    }
    if (!this._animatedView) {
      throw Error("Must call 'setAnimatedView' before '_connectAnimatedView'!");
    }
    nodeTag = findNodeHandle(this._animatedView);
    NativeAnimated.connectAnimatedNodeToView(this.__getNativeTag(), nodeTag);
  },
  _disconnectAnimatedView: function() {
    if (!this.__isNative) {
      throw Error("Must call '__markNative' before '_disconnectAnimatedView'!");
    }
    NativeAnimated.disconnectAnimatedNodeFromView(this.__getNativeTag());
  }
});

module.exports = type.build();

//# sourceMappingURL=map/AnimatedProps.map