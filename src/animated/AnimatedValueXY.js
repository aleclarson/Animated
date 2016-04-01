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
var isNumber = require('isNumber');
var Event = require('event');

var AnimatedWithChildren = require('./AnimatedWithChildren');
var AnimatedValue = require('./AnimatedValue');
var Animated = require('./Animated');

type AnimatedValueXYConfig = {
  x: number | AnimatedValue;
  y: number | AnimatedValue;
};

type ValueXY = {
  x: number;
  y: number;
};

/**
 * 2D Value for driving 2D animations, such as pan gestures.  Almost identical
 * API to normal `Animated.Value`, but multiplexed.  Contains two regular
 * `Animated.Value`s under the hood.  Example:
 *
 *```javascript
 *  class DraggableView extends React.Component {
 *    constructor(props) {
 *      super(props);
 *      this.state = {
 *        pan: new Animated.ValueXY(), // inits to zero
 *      };
 *      this.state.panResponder = PanResponder.create({
 *        onStartShouldSetPanResponder: () => true,
 *        onPanResponderMove: Animated.event([null, {
 *          dx: this.state.pan.x, // x,y are Animated.Value
 *          dy: this.state.pan.y,
 *        }]),
 *        onPanResponderRelease: () => {
 *          Animated.spring(
 *            this.state.pan,         // Auto-multiplexed
 *            {endValue: {x: 0, y: 0}} // Back to zero
 *          ).start();
 *        },
 *      });
 *    }
 *    render() {
 *      return (
 *        <Animated.View
 *          {...this.state.panResponder.panHandlers}
 *          style={this.state.pan.getLayout()}>
 *          {this.props.children}
 *        </Animated.View>
 *      );
 *    }
 *  }
 *```
 */
class AnimatedValueXY extends AnimatedWithChildren {
  x: AnimatedValue;
  y: AnimatedValue;
  didSet: Event;
  _listeners: ?Array;

  constructor(
    config?: AnimatedValueXYConfig
  ) {
    super();

    this.didSet = Event({
      onSetListeners: (_, listenerCount) => {
        if (listenerCount === 0) {
          this._listeners.forEach(listener => listener.stop());
          this._listeners = null;
        } else if (!this._listeners) {
          var emit = () => this.didSet.emit(this.__getValue());
          this._listeners = [ this.x.didSet(emit), this.y.didSet(emit) ];
        }
      },
    });

    if (!config) {
      this.x = new AnimatedValue(0);
      this.y = new AnimatedValue(0);
    } else if (isNumber(config.x) && isNumber(config.y)) {
      this.x = new AnimatedValue(config.x);
      this.y = new AnimatedValue(config.y);
    } else {
      invariant(
        config.x instanceof AnimatedValue &&
        config.y instanceof AnimatedValue,
        'AnimatedValueXYConfig requires "x" and "y" be the same type!'
      );
      this.x = config.x;
      this.y = config.y;
    }
  }

  setValue(value: ValueXY) {
    this.x.setValue(value.x);
    this.y.setValue(value.y);
  }

  setOffset(offset: ValueXY) {
    this.x.setOffset(offset.x);
    this.y.setOffset(offset.y);
  }

  flattenOffset(): void {
    this.x.flattenOffset();
    this.y.flattenOffset();
  }

  __getValue(): ValueXY {
    return {
      x: this.x.__getValue(),
      y: this.y.__getValue(),
    };
  }

  stopAnimation(callback?: () => number): void {
    this.x.stopAnimation();
    this.y.stopAnimation();
    callback && callback(this.__getValue());
  }

  /**
   * Converts `{x, y}` into `{left, top}` for use in style, e.g.
   *
   *```javascript
   *  style={this.state.anim.getLayout()}
   *```
   */
  getLayout(): {[key: string]: AnimatedValue} {
    return {
      left: this.x,
      top: this.y,
    };
  }

  /**
   * Converts `{x, y}` into a useable translation transform, e.g.
   *
   *```javascript
   *  style={{
   *    transform: this.state.anim.getTranslateTransform()
   *  }}
   *```
   */
  getTranslateTransform(): Array<{[key: string]: AnimatedValue}> {
    return [
      {translateX: this.x},
      {translateY: this.y}
    ];
  }
}

module.exports = AnimatedValueXY;
