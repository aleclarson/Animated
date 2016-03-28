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

var Easing = require('easing');

var Animation = require('./Animation');
var AnimatedValue = require('./AnimatedValue');
var RequestAnimationFrame = require('./injectable/RequestAnimationFrame');
var CancelAnimationFrame = require('./injectable/CancelAnimationFrame');

import type { AnimationConfig, EndCallback } from './Animation';

type TimingAnimationConfigSingle = AnimationConfig & {
  toValue: number | AnimatedValue;
  easing?: (value: number) => number;
  duration?: number;
  delay?: number;
};

class TimingAnimation extends Animation {
  _startTime: number;
  _fromValue: number;
  _toValue: any;
  _duration: number;
  _delay: number;
  _easing: (value: number) => number;
  _onUpdate: (value: number) => void;
  _animationFrame: any;
  _timeout: any;

  constructor(
    config: TimingAnimationConfigSingle,
  ) {
    super();
    this._toValue = config.toValue;
    this._easing = config.easing !== undefined ? config.easing : Easing('linear');
    this._duration = config.duration !== undefined ? config.duration : 500;
    this._delay = config.delay !== undefined ? config.delay : 0;
    this.__isInteraction = config.isInteraction !== undefined ? config.isInteraction : true;
  }

  start(
    fromValue: number,
    onUpdate: (value: number) => void,
    onEnd: ?EndCallback,
  ): void {
    this.__active = true;
    this._fromValue = fromValue;
    this._onUpdate = onUpdate;
    this.__onEnd = onEnd;

    var start = () => {
      if (this._duration === 0) {
        return this._onFinish();
      }

      this._startTime = Date.now();
      this._animationFrame = RequestAnimationFrame.current(this.onUpdate.bind(this));
    };

    if (this._delay) {
      this._timeout = setTimeout(start, this._delay);
    } else {
      start();
    }
  }

  onUpdate(): void {
    var elapsedTime = Date.now() - this._startTime;
    if (elapsedTime >= this._duration) {
      return this._onFinish();
    }

    this._onUpdate(
      this._computeValue(elapsedTime)
    );
    if (this.__active) {
      this._animationFrame = RequestAnimationFrame.current(this.onUpdate.bind(this));
    }
  }

  stop(): void {
    this.__active = false;
    clearTimeout(this._timeout);
    CancelAnimationFrame.current(this._animationFrame);
    this.__debouncedOnEnd({finished: false});
  }

  _onFinish(): void {
    this._onUpdate(
      this._computeValue(this._duration)
    );
    this.__debouncedOnEnd({finished: true});
  }

  _computeValue(
    elapsedTime: number,
  ): number {
    return this._fromValue +
      (this._toValue - this._fromValue) *
      this._computeProgress(elapsedTime);
  }

  _computeProgress(
    elapsedTime: number,
  ): number {
    return
      elapsedTime >= this._duration ?
        this._easing(1) :
      elapsedTime > 0 ?
        this._easing(elapsedTime / this._duration) :
        this._easing(0);
  }
}

module.exports = TimingAnimation;
