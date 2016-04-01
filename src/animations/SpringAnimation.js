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
var invariant = require('invariant');

var AnimatedValueXY = require('../animated/AnimatedValueXY');
var AnimatedValue = require('../animated/AnimatedValue');
var SpringConfig = require('./SpringConfig');
var Animation = require('./Animation');

import type { AnimationConfig, EndCallback } from './Animation';

export type SpringAnimationConfig = AnimationConfig & {
  toValue: number | AnimatedValue | {x: number, y: number} | AnimatedValueXY;
  overshootClamping?: bool;
  restDisplacementThreshold?: number;
  restSpeedThreshold?: number;
  velocity?: number | {x: number, y: number};
  bounciness?: number;
  speed?: number;
  tension?: number;
  friction?: number;
};

class SpringAnimation extends Animation {
  _endValue: number;
  _startVelocity: ?number;
  _curTime: number;
  _curValue: number;
  _curVelocity: number;
  _tension: number;
  _friction: number;
  _overshootClamping: bool;
  _restSpeedThreshold: number;
  _restDisplacementThreshold: number;

  constructor(
    config: SpringAnimationConfig,
  ) {
    super(config);

    this._endValue = config.toValue;
    this._startVelocity = config.velocity;
    this._overshootClamping = withDefault(config.overshootClamping, false);
    this._restSpeedThreshold = withDefault(config.restSpeedThreshold, 0.001);
    this._restDisplacementThreshold = withDefault(config.restDisplacementThreshold, 0.01);

    var springConfig = this._getSpringConfig(config);
    this._tension = springConfig.tension;
    this._friction = springConfig.friction;
  }

  __onStart(): void {

    if (this.__previousAnimation instanceof SpringAnimation) {
      var internalState = this.__previousAnimation.getInternalState();
      this._curValue = internalState.curValue;
      this._curVelocity = internalState.curVelocity;
      this._curTime = internalState.curTime;
    } else {
      this._curTime = Date.now();
      this._curValue = this.__startValue;
    }

    if (this._startVelocity !== undefined &&
        this._startVelocity !== null) {
      this._curVelocity = this._startVelocity;
    }

    this.__recomputeValue();
  }

  getInternalState(): Object {
    return {
      curValue: this._curValue,
      curVelocity: this._curVelocity,
      curTime: this._curTime,
    };
  }

  __computeValue(): number {
    var value = this._curValue;
    var velocity = this._curVelocity;

    var tempValue = this._curValue;
    var tempVelocity = this._curVelocity;

    // If for some reason we lost a lot of frames (e.g. process large payload or
    // stopped in the debugger), we only advance by 4 frames worth of
    // computation and will continue on the next frame. It's better to have it
    // running at faster speed than jumping to the end.
    var MAX_STEPS = 64;
    var now = Date.now();
    if (now > this._curTime + MAX_STEPS) {
      now = this._curTime + MAX_STEPS;
    }

    // We are using a fixed time step and a maximum number of iterations.
    // The following post provides a lot of thoughts into how to build this
    // loop: http://gafferongames.com/game-physics/fix-your-timestep/
    var TIMESTEP_MSEC = 1;
    var numSteps = Math.floor((now - this._curTime) / TIMESTEP_MSEC);

    for (var i = 0; i < numSteps; ++i) {
      // Velocity is based on seconds instead of milliseconds
      var step = TIMESTEP_MSEC / 1000;

      // This is using RK4. A good blog post to understand how it works:
      // http://gafferongames.com/game-physics/integration-basics/
      var aVelocity = velocity;
      var aAcceleration = this._tension * (this._endValue - tempValue) - this._friction * tempVelocity;
      var tempValue = value + aVelocity * step / 2;
      var tempVelocity = velocity + aAcceleration * step / 2;

      var bVelocity = tempVelocity;
      var bAcceleration = this._tension * (this._endValue - tempValue) - this._friction * tempVelocity;
      tempValue = value + bVelocity * step / 2;
      tempVelocity = velocity + bAcceleration * step / 2;

      var cVelocity = tempVelocity;
      var cAcceleration = this._tension * (this._endValue - tempValue) - this._friction * tempVelocity;
      tempValue = value + cVelocity * step / 2;
      tempVelocity = velocity + cAcceleration * step / 2;

      var dVelocity = tempVelocity;
      var dAcceleration = this._tension * (this._endValue - tempValue) - this._friction * tempVelocity;
      tempValue = value + cVelocity * step / 2;
      tempVelocity = velocity + cAcceleration * step / 2;

      var dxdt = (aVelocity + 2 * (bVelocity + cVelocity) + dVelocity) / 6;
      var dvdt = (aAcceleration + 2 * (bAcceleration + cAcceleration) + dAcceleration) / 6;

      value += dxdt * step;
      velocity += dvdt * step;
    }

    this._curTime = now;
    this._curValue = value;
    this._curVelocity = velocity;

    return value;
  }

  __didComputeValue(
    value: number
  ): void {
    if (!this.__active) { // a listener might have stopped us in __onUpdate
      return;
    }

    // Conditions for stopping the spring animation
    var isOvershooting = false;
    if (this._overshootClamping && this._tension !== 0) {
      if (this.__startValue < this._endValue) {
        isOvershooting = value > this._endValue;
      } else {
        isOvershooting = value < this._endValue;
      }
    }
    var isVelocity = Math.abs(velocity) <= this._restSpeedThreshold;
    var isDisplacement = true;
    if (this._tension !== 0) {
      isDisplacement = Math.abs(this._endValue - value) <= this._restDisplacementThreshold;
    }

    if (isOvershooting || (isVelocity && isDisplacement)) {
      this.__onFinish();
    }
  }

  _getSpringConfig(config: SpringAnimationConfig): Object {
    if (config.bounciness !== undefined || config.speed !== undefined) {
      invariant(
        config.tension === undefined && config.friction === undefined,
        'You can only define bounciness/speed or tension/friction but not both',
      );
      springConfig = SpringConfig.fromBouncinessAndSpeed(
        withDefault(config.bounciness, 8),
        withDefault(config.speed, 12),
      );
    } else {
      springConfig = SpringConfig.fromOrigamiTensionAndFriction(
        withDefault(config.tension, 40),
        withDefault(config.friction, 7),
      );
    }
    return springConfig;
  }

  __onFinish(): void {
    if (this._tension !== 0) {
      // Ensure that we end up with a round value
      this.__onUpdate(this._endValue);
    }

    this.__debouncedOnEnd(true);
  }
}

module.exports = SpringAnimation;
