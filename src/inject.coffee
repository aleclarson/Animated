
AnimationFrame = require "./AnimationFrame"
InteractionManager = require "./InteractionManager"

module.exports =

  requestAnimationFrame: (fn) ->
    AnimationFrame.inject.set "requestFrame", fn

  clearAnimationFrame: (fn) ->
    AnimationFrame.inject.set "clearFrame", fn

  createInteractionHandle: (fn) ->
    InteractionManager.inject.set "createHandle", fn

  clearInteractionHandle: (fn) ->
    InteractionManager.inject.set "clearHandle", fn
