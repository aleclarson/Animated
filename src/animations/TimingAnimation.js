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

var withDefault = require('withDefault');
var Easing = require('easing');

var Animation = require('./Animation');
var AnimatedValue = require('../animated/AnimatedValue');
var RequestAnimationFrame = require('../injectable/RequestAnimationFrame');
var CancelAnimationFrame = require('../injectable/CancelAnimationFrame');

import type { AnimationConfig, EndCallback } from './Animation';
import type { EasingFunction } from 'Interpolation';

export type TimingAnimationConfig = AnimationConfig & {
  toValue: number | AnimatedValue;
  easing?: EasingFunction;
  duration?: number;
  delay?: number;
};

class TimingAnimation extends Animation {
  _endValue: number;
  _curTime: number;
  _curValue: number;
  _curVelocity: number;
  _lastTime: number;
  _lastValue: number;
  _delay: number;
  _duration: number;
  _easing: EasingFunction;
  _timeout: ?any;

  constructor(
    config: TimingAnimationConfig,
  ) {
    super(config);

    this._curTime = 0;
    this._endValue = config.toValue;
    this._delay = withDefault(config.delay, 0);
    this._duration = withDefault(config.duration, 500);
    this._easing = withDefault(config.easing, Easing('linear'));
    this._timeout = null;
  }

  computeValueAtProgress(
    progress: number,
  ): number {
    return (this.__startValue + progress *
      (this._endValue - this.__startValue));
  }

  computeValueAtTime(
    elapsedTime: number,
  ): number {
    return this.computeValueAtProgress(
      this.computeProgressAtTime(elapsedTime)
    );
  }

  computeProgressAtTime(
    elapsedTime: number,
  ): number {
    if (elapsedTime <= 0) {
      return this._easing(0);
    }
    if (elapsedTime < this._duration) {
      return this._easing(elapsedTime / this._duration);
    }
    return this._easing(1);
  }

  __computeValue(): number {

    this._lastTime = this._curTime;
    this._lastValue = this._curValue;

    this._curTime = Math.min(this._duration, Date.now() - this.__startTime);
    this._curValue = this.computeValueAtTime(this._curTime);
    this._curVelocity = (this._curValue - this._lastValue) / (this._curTime - this._lastTime);

    return this._curValue;
  }

  __didComputeValue(value: number): void {
    if (this._curTime === this._duration) {
      this.__debouncedOnEnd(true);
    }
  }

  __onStart(): void {
    if (this._delay && this._timeout === null) {
      var start = () => this.__onStart();
      this._timeout = setTimeout(start, this._delay);
    } else {
      this._timeout = null;
      if (this._duration === 0) {
        this.__onUpdate(
          this.computeValueAtProgress(1)
        );
        this.__debouncedOnEnd(true);
      } else {
        this.__startTime = Date.now();
        this.__requestAnimationFrame();
      }
    }
  }

  __onStop(): void {
    clearTimeout(this._timeout);
    this._timeout = null;
  }
}

module.exports = TimingAnimation;
