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

var parallel = require('./parallel');
var sequence = require('./sequence');

import type { CompositeAnimation } from './animations/Animation';

module.exports = function(
  time: number,
  animations: Array<CompositeAnimation>,
): CompositeAnimation {
  return parallel(animations.map((animation, i) => {
    return sequence([
      delay(time * i),
      animation,
    ]);
  }));
};
