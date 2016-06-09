var Animated, Type, type;

Type = require("Type");

Animated = require("./Animated");

type = Type("AnimatedWithChildren");

type.inherits(Animated);

type.defineFrozenValues({
  _children: function() {
    return [];
  }
});

type.overrideMethods({
  __getChildren: function() {
    return this._children;
  },
  __addChild: function(child) {
    if (this._children.length === 0) {
      this.__attach();
    }
    return this._children.push(child);
  },
  __removeChild: function(child) {
    var index;
    index = this._children.indexOf(child);
    if (index < 0) {
      return;
    }
    this._children.splice(index, 1);
    if (this._children.length === 0) {
      return this.__detach();
    }
  }
});

module.exports = type.build();

//# sourceMappingURL=../../map/src/AnimatedWithChildren.map
