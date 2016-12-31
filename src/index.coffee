
require "LazyVar"
LazyMap = require "LazyMap"

module.exports = LazyMap

  Animation: -> require "./Animation"

  AnimatedValue: -> require "./nodes/AnimatedValue"

  AnimatedProps: -> require "./nodes/AnimatedProps"

  AnimatedStyle: -> require "./nodes/AnimatedStyle"

  AnimatedTransform: -> require "./nodes/AnimatedTransform"

  # AnimatedAddition: -> require "./nodes/AnimatedAddition"

  # AnimatedExponent: -> require "./nodes/AnimatedExponent"

  # AnimatedDiffClamp: -> require "./nodes/AnimatedDiffClamp"

  # AnimatedInterpolation: -> require "./nodes/AnimatedInterpolation"

  AnimatedWithChildren: -> require "./nodes/AnimatedWithChildren"

  Animated: -> require "./nodes/Animated"

  NativeAnimated: -> require "./NativeAnimated"
