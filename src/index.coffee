
LazyMap = require "LazyMap"

module.exports = LazyMap
  Animation: -> require "./Animation"
  Animated: -> require "./nodes/Animated"
  AnimatedWithChildren: -> require "./nodes/AnimatedWithChildren"
  AnimatedValue: -> require "./nodes/AnimatedValue"
  AnimatedProps: -> require "./nodes/AnimatedProps"
  AnimatedStyle: -> require "./nodes/AnimatedStyle"
  AnimatedTransform: -> require "./nodes/AnimatedTransform"
  # AnimatedAddition: -> require "./nodes/AnimatedAddition"
  # AnimatedExponent: -> require "./nodes/AnimatedExponent"
  # AnimatedDiffClamp: -> require "./nodes/AnimatedDiffClamp"
  # AnimatedInterpolation: -> require "./nodes/AnimatedInterpolation"
