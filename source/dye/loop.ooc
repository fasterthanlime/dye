
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
    _delay: Float
    delay: Float { get { _delay } }

    running := true
    paused := false

    init: func (=dye, =fpsGoal)

    run: func (body: Func) {
        maxFrameDuration := 1000.0f / fpsGoal

        count := 0

        while (running) {
            t1 := SDL getTicks()
            dye poll()

            if (!paused) {
                body()
                dye render()
            }

            t2 := SDL getTicks()
            delta := (t2 - t1) as Float

            _delay = maxFrameDuration - delta

            if (_delay < 0) {
                // never sleep for a negative amount of time - that'll freeze 
                "negative delay! delta = #{delta}, _delay = #{_delay}, t1 = #{t1}, t2 = #{t2}" println()
                _delay = 0
            }

            if (_delay > maxFrameDuration) {
                "delay too big!" println()
                // don't sleep for more than maxFrameDuration - whatever the weird reason.
                _delay = maxFrameDuration
            }

            SDL delay(_delay as UInt32)
            actualDelta := delta + _delay

            count += 1

            if (count >= 30) {
                count = 0
                current := 1000.0 / actualDelta
                _computedFps = _computedFps * 0.3 + current * 0.7
            }
        }
    }

    stop: func {
        running = false
    }

}

