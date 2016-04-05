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
  AnimatedValue: require('./animated/AnimatedValue'),
  AnimatedValueXY: require('./animated/AnimatedValueXY'),
  AnimatedMap: require('./animated/AnimatedMap'),
  AnimatedTransform: require('./animated/AnimatedTransform'),
  AnimatedStyle: require('./animated/AnimatedStyle'),
  AnimatedProps: require('./animated/AnimatedProps'),

  Animation: require('./animations/Animation'),
  DecayAnimation: require('./animations/DecayAnimation'),
  SpringAnimation: require('./animations/SpringAnimation'),
  TimingAnimation: require('./animations/TimingAnimation'),

  isAnimated: require('./isAnimated'),
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

  inject: {
    ApplyAnimatedValues: require('./injectable/ApplyAnimatedValues').inject,
    InteractionManager: require('./injectable/InteractionManager').inject,
    FlattenStyle: require('./injectable/FlattenStyle').inject,
    RequestAnimationFrame: require('./injectable/RequestAnimationFrame').inject,
    CancelAnimationFrame: require('./injectable/CancelAnimationFrame').inject,
  },
};
