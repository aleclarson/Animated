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

var Interpolation = require('Interpolation');
var invariant = require('invariant');
var isNumber = require('isNumber');
var Event = require('event');

var AnimatedWithChildren = require('./AnimatedWithChildren');
var Animated = require('./Animated');

import type { InterpolationConfigType, EasingFunction } from 'Interpolation';

class AnimatedInterpolation extends AnimatedWithChildren {
  didSet: Event;
  _parent: Animated;
  _interpolation: EasingFunction;
  _parentListener: ?Event.Listener;

  constructor(
    parent: Animated,
    interpolation: (input: number) => number | string
  ) {
    super();

    this.didSet = Event({
      onSetListeners: (_, listenerCount) => {
        if (listenerCount === 0) {
          this._parentListener.stop();
          this._parentListener = null;
        } else if (!this._parentListener) {
          this._parentListener = this._parent.didSet(
            () => this.didSet.emit(this.__getValue())
          );
        }
      },
    });

    invariant(
      this._parent.didSet instanceof Event,
      'The given parent value cannot be interpolated!'
    );

    this._parent = parent;
    this._interpolation = interpolation;
  }

  __getValue(): number | string {
    var parentValue: number = this._parent.__getValue();
    invariant(
      isNumber(parentValue),
      'Only numbers can be interpolated!'
    );
    return this._interpolation(parentValue);
  }

  interpolate(config: InterpolationConfigType): AnimatedInterpolation {
    return new AnimatedInterpolation(this, Interpolation.create(config));
  }

  __attach(): void {
    this._parent.__addChild(this);
  }

  __detach(): void {
    this._parent.__removeChild(this);
    this._parentListener = this._parent.removeListener(this._parentListener);
  }
}

module.exports = AnimatedInterpolation;
