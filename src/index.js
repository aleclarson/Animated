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

module.exports = {
  Value: require('./animated/AnimatedValue'),
  ValueXY: require('./animated/AnimatedValueXY'),
  Map: require('./animated/AnimatedMap'),
  Transform: require('./animated/AnimatedTransform'),
  Style: require('./animated/AnimatedStyle'),
  Props: require('./animated/AnimatedProps'),
  decay: require('./decay'),
  timing: require('./timing'),
  spring: require('./spring'),
  add: require('./add'),
  multiply: require('./multiply'),
  modulo: require('./modulo'),
  delay: require('./delay'),
  sequence: require('./sequence'),
  parallel: require('./parallel'),
  stagger: require('./stagger'),
  event: require('./event'),
  isAnimated: require('./isAnimated'),
  inject: {
    ApplyAnimatedValues: require('./injectable/ApplyAnimatedValues').inject,
    InteractionManager: require('./injectable/InteractionManager').inject,
    FlattenStyle: require('./injectable/FlattenStyle').inject,
    RequestAnimationFrame: require('./injectable/RequestAnimationFrame').inject,
    CancelAnimationFrame: require('./injectable/CancelAnimationFrame').inject,
  },
};
