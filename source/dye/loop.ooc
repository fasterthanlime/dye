
// third-party stuff
use sdl2
import sdl2/[Core]

// our stuff
use dye
import dye/[core]

/**
 * A fixed loop allows you to keep a smooth fps all
 * the time. Except if your device is too slow, obviously :)
 * 
 * :author: Amos Wenger (@nddrylliog)
 */
FixedLoop: class {

    dye: DyeContext
    fpsGoal: Float
    _computedFps := 0.0

    fps: Float { get { _computedFps } }

    running := true
    paused := false

    init: func (=dye, =fpsGoal) {
        // let's start out optimistic
        _computedFps = fpsGoal
    }

    run: func (body: Func) {
        maxFrameDuration := 1000.0 / fpsGoal

        t1 := SDL getTicks()

        while (running) {
            t1 = SDL getTicks()

            dye poll()

            if (!paused) {
                body()
                dye render()
            }

            t2 := SDL getTicks()
            delta := t2 - t1

            delay := maxFrameDuration - delta
            if (delay < 0) {
                // never sleep for a negative amount of time - that'll freeze 
                delay = 0
            }

            if (delay > maxFrameDuration) {
                // don't sleep for more than maxFrameDuration - whatever the weird reason.
                delay = maxFrameDuration
            }

            current := 1000.0 / delta
            _computedFps = _computedFps * 0.97 + current * 0.03

            SDL delay(delay)
        }
    }

}
