
# Animation : Object

The `Animation` class uses `requestAnimationFrame` to animate
a value using the animation's update function.

```coffee
{ Animation } = require "Animated"

# NOTE: You should never construct an `Animation` directly, because it is
#       an abstract type. Construct a subclass instead! (eg: `TimingAnimation`)
animation = Animation
  isInteraction: no   # Should the animation block InteractionManager callbacks? (defaults to true)
  captureFrames: yes  # Should each animation frame get stored in `this._frames`? (defaults to false)

animation.start
  startValue: 0           # The animation's starting value!
  onUpdate: (newValue) -> # Do something with the newest value!
  onEnd: (finished) ->    # Do something after the animation ends!

# Stop the animation before it is finished.
animation.stop()

# Jump to the final value.
animation.finish()

# Equals true when `animation.start()` has been called.
animation.hasStarted

# The starting value passed to 'this.start()'.
animation.startValue

# When the animation started.
animation.startTime

# Equals true when the animation has been stopped or finished.
animation.hasEnded
```

### Subclassing

These methods can be safely overridden by subclasses:

```coffee
# This function should use 'this.startTime' and 'this.startValue'
# to determine the current value of the animation.
# NOTE: You must override this function!
__computeValue: ->
  return newValue

# This function is called immediately after 'this._onUpdate' is passed
# the newest value. One reason to override this is to call 'this.finish'
# if the newest value equals the final value.
__didUpdate: (newValue) ->
  @finish() if newValue is finalValue

# This function is called inside 'this.start()'.
# NOTE: If you override this, you must call 'this._requestAnimationFrame()'!
__onStart: ->
  @_requestAnimationFrame()

# This function is called when the animation ends.
__onEnd: (finished) ->
```
