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

var Animation = require('./Animation');

import type { AnimationConfig, EndCallback } from './Animation';

export type DecayAnimationConfig = AnimationConfig & {
  velocity: number;
  restVelocity?: number;
  deceleration?: number;
  duration?: number;
};

class DecayAnimation extends Animation {
  _startVelocity: number;
  _curValue: number;
  _curVelocity: number;
  _restVelocity: number;
  _deceleration: number;

  constructor(
    config: DecayAnimationConfig,
  ) {
    super(config);

    this._deceleration = withDefault(config.deceleration, 0.998);
    this._startVelocity = config.velocity;
    this._restVelocity = withDefault(config.restVelocity, 0.005);
  }

  __onStart(): void {

    this._curValue = this.__startValue;
    this._curVelocity = this._startVelocity;

    super.__onStart();
  }

  __computeValue(): number {

    var elapsedTime = Date.now() - this.__startTime;

    var kd = 1 - this._deceleration;
    var kv = Math.exp(-1 * elapsedTime * kd);

    var value = this.__startValue + (this._startVelocity / kd) * (1 - kv);
    var velocity = this._startVelocity * kv;

    this._lastValue = this._curValue;
    this._lastVelocity = this._curVelocity;

    this._curValue = value;
    this._curVelocity = velocity;

    return value;
  }

  __didComputeValue(
    value: number,
  ): void {
    if (Math.abs(this._curVelocity) < this._restVelocity) {
      this.__onFinish();
    }
  }
}

module.exports = DecayAnimation;
