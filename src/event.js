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

var invariant = require('invariant');

var AnimatedValue = require('./animated/AnimatedValue');

type Mapping = {[key: string]: Mapping} | AnimatedValue;

type EventConfig = {listener?: Function};

module.exports = function(
  argMapping: Array<?Mapping>,
  config?: EventConfig,
): () => void {
  return function(...args): void {
    var traverse = function(recMapping, recEvt, key) {
      if (typeof recEvt === 'number') {
        invariant(
          recMapping instanceof AnimatedValue,
          'Bad mapping of type ' + typeof recMapping + ' for key ' + key +
            ', event value must map to AnimatedValue'
        );
        recMapping.setValue(recEvt);
        return;
      }
      invariant(
        typeof recMapping === 'object',
        'Bad mapping of type ' + typeof recMapping + ' for key ' + key
      );
      invariant(
        typeof recEvt === 'object',
        'Bad event of type ' + typeof recEvt + ' for key ' + key
      );
      for (var key in recMapping) {
        traverse(recMapping[key], recEvt[key], key);
      }
    };
    argMapping.forEach((mapping, idx) => {
      traverse(mapping, args[idx], 'arg' + idx);
    });
    if (config && config.listener) {
      config.listener.apply(null, args);
    }
  };
};
