
// third-party stuff
use sdl2
import sdl2/[Core]

// our stuff
use dye
import dye/[core]

import os/Time

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
    _delay: Float
    delay: Float { get { _delay } }

    running := true
    paused := false

    init: func (=dye, =fpsGoal)

    run: func (body: Func) {
        count := 0

        t1 := SDL getTicks()
        while (running) {
            dye poll()

            if (!paused) {
                body()
                dye render()
            }

            count += 1

            if (count >= 120) {
                count = 0
                t2 := SDL getTicks()
                delta := (t2 - t1) as Float

                current := 1_000.0 * 120.0 / delta
                "current = #{current}" println()
                _computedFps = _computedFps * 0.9 + current * 0.1
                t1 = t2
            }
        }
    }

    stop: func {
        running = false
    }

}

