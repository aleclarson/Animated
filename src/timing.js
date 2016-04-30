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

var maybeVectorAnim = require('./maybeVectorAnim');
var TimingAnimation = require('./animations/TimingAnimation');
var AnimatedValueXY = require('./animated/AnimatedValueXY');
var AnimatedValue = require('./animated/AnimatedValue');
var Animated = require('./animated/Animated');

import type { CompositeAnimation, EndCallback } from './animations/Animation';
import type { TimingAnimationConfig } from './animations/TimingAnimation';

var timing = function(
  value: AnimatedValue | AnimatedValueXY,
  config: TimingAnimationConfig,
): CompositeAnimation {
  return maybeVectorAnim(value, config, timing) || {
    start: function(callback?: EndCallback): void {
      var singleValue: any = value;
      var singleConfig: any = config;
      singleValue.stopTracking();
      if (config.toValue instanceof Animated) {
        singleValue.track(new AnimatedTracking(
          singleValue,
          config.toValue,
          TimingAnimation,
          singleConfig,
          callback
        ));
      } else {
        singleValue.animate(new TimingAnimation(singleConfig), callback);
      }
    },

    stop: function(): void {
      value.stopAnimation();
    },
  };
};

module.exports = timing;
