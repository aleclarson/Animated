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

var AnimatedValueXY = require('./animated/AnimatedValueXY');
var AnimatedValue = require('./animated/AnimatedValue');
var parallel = require('./parallel');

import type { CompositeAnimation } from './animations/Animation';

module.exports = function(
  value: AnimatedValue | AnimatedValueXY,
  config: Object,
  anim: (value: AnimatedValue, config: Object) => CompositeAnimation
): ?CompositeAnimation {
  if (value instanceof AnimatedValueXY) {
    var configX = {...config};
    var configY = {...config};
    for (var key in config) {
      var {x, y} = config[key];
      if (x !== undefined && y !== undefined) {
        configX[key] = x;
        configY[key] = y;
      }
    }
    var aX = anim((value: AnimatedValueXY).x, configX);
    var aY = anim((value: AnimatedValueXY).y, configY);
    // We use `stopTogether: false` here because otherwise tracking will break
    // because the second animation will get stopped before it can update.
    return parallel([aX, aY], {stopTogether: false});
  }
  return null;
};
