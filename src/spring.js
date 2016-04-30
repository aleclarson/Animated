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
var AnimatedTracking = require('./animated/AnimatedTracking');
var SpringAnimation = require('./animations/SpringAnimation');
var AnimatedValueXY = require('./animated/AnimatedValueXY');
var AnimatedValue = require('./animated/AnimatedValue');
var Animated = require('./animated/Animated');

import type { CompositeAnimation, EndCallback } from './animations/Animation';
import type { SpringAnimationConfig } from './animations/SpringAnimation';

var spring = function(
  value: AnimatedValue | AnimatedValueXY,
  config: SpringAnimationConfig,
): CompositeAnimation {
  return maybeVectorAnim(value, config, spring) || {
    start: function(callback?: EndCallback): void {
      var singleValue: any = value;
      var singleConfig: any = config;
      singleValue.stopTracking();
      if (config.toValue instanceof Animated) {
        singleValue.track(new AnimatedTracking(
          singleValue,
          config.toValue,
          SpringAnimation,
          singleConfig,
          callback
        ));
      } else {
        singleValue.animate(new SpringAnimation(singleConfig), callback);
      }
    },

    stop: function(): void {
      value.stopAnimation();
    },
  };
};

module.exports = spring;
