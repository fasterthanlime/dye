
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

        ticksPerUpdate := 1000.0 / fpsGoal
        lastUpdateTicks := SDL getTicks() as Float
        lastFpsTicks := SDL getTicks() as Float

        while (running) {
            dye poll()
            dye render()

            currentUpdateTicks := SDL getTicks() as Float

            // update game if needed, as much as needed
            while (currentUpdateTicks - lastUpdateTicks >= ticksPerUpdate) {
                lastUpdateTicks += ticksPerUpdate
                if (!paused) {
                    body()
                }
            }

            // update fps counter every 30 ticks
            if (count >= 30) {
                count = 0
                delta := currentUpdateTicks - lastFpsTicks

                current := 1_000.0 * 30.0 / delta
                _computedFps = current
                lastFpsTicks = currentUpdateTicks
            }

            count += 1
        }
    }

    stop: func {
        running = false
    }

}

