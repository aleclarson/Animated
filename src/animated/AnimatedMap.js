/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 * @flow
 */
'use strict';

var Animated = require('./Animated');

class AnimatedMap extends Animated {
  _values: Object;
  _callback: () => void;

  constructor(
    values: Object,
    callback: () => void,
  ) {
    super();
    this._values = values;
    this._callback = callback;
    this.__attach();
  }

  __getValue(): Object {
    var values = {};
    for (var key in this._values) {
      var value = this._values[key];
      if (value instanceof Animated) {
        values[key] = value.__getValue();
      } else {
        values[key] = value;
      }
    }
    return values;
  }

  __getAnimatedValue(): Object {
    var values = {};
    for (var key in this._values) {
      var value = this._values[key];
      if (value instanceof Animated) {
        values[key] = value.__getAnimatedValue();
      }
    }
    return values;
  }

  __attach(): void {
    for (var key in this._values) {
      var value = this._values[key];
      if (value instanceof Animated) {
        value.__addChild(this);
      }
    }
  }

  __detach(): void {
    for (var key in this._values) {
      var value = this._values[key];
      if (value instanceof Animated) {
        value.__removeChild(this);
      }
    }
  }

  update(): void {
    this._callback();
  }
}

module.exports = AnimatedMap;
