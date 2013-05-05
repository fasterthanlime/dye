
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
    fpsGoal: Float { get set }

    // let's start out optimistic
    _computedFps := 60.0

    fps: Float { get { _computedFps } }

    running := true
    paused := false

    init: func (=dye, =fpsGoal)

    run: func (body: Func) {
        maxFrameDuration := 1000.0 / fpsGoal

        t1 := SDL getTicks()
        count := 0

        while (running) {
            t1 = SDL getTicks()

            dye poll()

            if (!paused) {
                body()
                dye render()
            }

            t2 := SDL getTicks()
            delta := (t2 - t1) as Float

            delay := maxFrameDuration - delta

            if (delay < 0) {
                // never sleep for a negative amount of time - that'll freeze 
                delay = 0
            }

            if (delay > maxFrameDuration) {
                // don't sleep for more than maxFrameDuration - whatever the weird reason.
                delay = maxFrameDuration
            }

            SDL delay(delay as UInt32)

            count += 1

            if (count >= 30) {
                count = 0

                actualDelta := delta + delay
                current := 1000.0 / actualDelta as Float
                _computedFps = _computedFps * 0.1 + current * 0.9
            }
        }
    }

    stop: func {
        running = false
    }

}
