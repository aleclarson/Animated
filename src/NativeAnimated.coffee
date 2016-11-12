
{NativeAnimatedModule} = require "NativeModules"

NativeEventEmitter = require "NativeEventEmitter"
assertType = require "assertType"
isDev = require "isDev"

if exports.isAvailable = NativeAnimatedModule?

  Object.assign exports, NativeAnimatedModule

  nativeEvents = new NativeEventEmitter NativeAnimatedModule

  updatedValues = Object.create null
  nativeEvents.addListener "onAnimatedValueUpdate", (data) ->
    return unless animatedValue = updatedValues[data.tag]
    return unless animation = animatedValue._animation
    if animation._nativeTag is data.animation
      animatedValue._updateValue data.value, yes

  delete exports.startListeningToAnimatedNodeValue
  exports.addUpdateListener = (animatedValue) ->
    tag = animatedValue.__getNativeTag()
    NativeAnimatedModule.startListeningToAnimatedNodeValue tag
    updatedValues[tag] = animatedValue
    return

  delete exports.stopListeningToAnimatedNodeValue
  exports.removeUpdateListener = (animatedValue) ->
    tag = animatedValue.__nativeTag
    NativeAnimatedModule.stopListeningToAnimatedNodeValue tag
    delete updatedValues[tag]
    return

  exports.createAnimatedTag = do ->
    tag = 1
    -> tag++

  exports.createAnimationTag = do ->
    tag = 1
    -> tag++

isDev and
Object.assign exports, do ->
  OneOf = require "OneOf"

  validProps = OneOf "style"
  validStyles = OneOf "opacity transform"
  validTransforms = OneOf "translateX translateY scale scaleX scaleY rotate rotateX rotateY perspective"
  validInterpolation = OneOf "inputRange outputRange extrapolate extrapolateRight extrapolateLeft"

  validateProps: (props) ->
    assertType props, Object
    Object.keys(props).forEach (key) ->
      unless validProps.test key
        throw Error "Property '#{key}' not supported by native animated module!"

  validateStyle: (style) ->
    assertType style, Object
    Object.keys(style).forEach (key) ->
      unless validStyles.test key
        throw Error "Property '#{key}' not supported by native animated module!"

  validateTransform: (transform) ->
    assertType transform, Array
    transform.forEach (config) ->
      unless validTransforms.test config.property
        throw Error "Property '#{config.property}' not supported by native animated module!"

  validateInterpolation: (config) ->
    Object.keys(config).forEach (key) ->
      unless validInterpolation.test key
        throw Error "Property '#{key}' not supported by native animated module!"