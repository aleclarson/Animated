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
var isNumber = require('isNumber');
var isDev = require('isDev');

var RequestAnimationFrame = require('../injectable/RequestAnimationFrame');
var CancelAnimationFrame = require('../injectable/CancelAnimationFrame');

export type UpdateCallback = (value: number) => void;

export type EndResult = {finished: bool};
export type EndCallback = (result: EndResult) => void;

export type AnimationConfig = {
  isInteraction?: bool;
};

export type CompositeAnimation = {
  start: (callback?: EndCallback) => void;
  stop: () => void;
};

// Important note: start() and stop() will only be called at most once.
// Once an animation has been stopped or finished its course, it will
// not be reused.
class Animation {
  __started: bool;
  __active: bool;
  __startTime: number;
  __startValue: number;
  __onUpdate: ?UpdateCallback;
  __onEnd: ?EndCallback;
  __isInteraction: bool;
  __animationFrame: ?any;
  __previousAnimation: ?Animation;

  constructor(
    config: Object
  ) {
    this.__started = false;
    this.__active = false;
    this.__isInteraction = withDefault(config.isInteraction, true);
    this.__boundRecompute = () => this.__recomputeValue();
  }

  start(
    startValue: number,
    onUpdate?: UpdateCallback,
    onEnd?: EndCallback,
    previousAnimation?: Animation,
  ): void {
    // Animations cannot be reused.
    if (this.__started) { return; }
    this.__started = true;
    this.__startTime = Date.now();
    this.__startValue = startValue;
    this.__onUpdate = onUpdate;
    this.__onEnd = onEnd;
    this.__previousAnimation = previousAnimation;
    this.__active = true;
    this.__onStart();
    this.__previousAnimation = null;
  }

  stop(): void {
    if (!this.__active) { return; }
    CancelAnimationFrame.current(this.__animationFrame);
    this.__animationFrame = null;
    this.__onStop();
    this.__debouncedOnEnd(false);
  }

  __computeValue(): number {
    return this.__startValue;
  }

  __didComputeValue(
    value: number
  ): void {
    // no-op
  }

  __recomputeValue(): void {

    var value = this.__computeValue();

    if (isDev && !isNumber(this._curValue)) {
      throw TypeError('Animation.__computeValue() must return a number!');
    }

    this.__onUpdate(value);
    this.__didComputeValue(value);

    this.__requestAnimationFrame();
  }

  __requestAnimationFrame(): void {
    if (this.__active) {
      this.__animationFrame = RequestAnimationFrame.current(this.__boundRecompute);
    }
  }

  __onStart(): void {
    this.__requestAnimationFrame();
  }

  __onStop(): void {
    // no-op
  }

  __onFinish(): void {
    this.__debouncedOnEnd(true);
  }

  __debouncedOnEnd(finished: bool): void {
    if (!this.__active) { return; }
    this.__active = false;
    this.__onEnd({ finished });
  }
}

module.exports = Animation;
