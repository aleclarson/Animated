
injectable =
  InteractionManager: require "./InteractionManager"
  requestAnimationFrame: require "./requestAnimationFrame"
  cancelAnimationFrame: require "./cancelAnimationFrame"

module.exports = (key, value) ->
  injectable[key].inject value
  return
