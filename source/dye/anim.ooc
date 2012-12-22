
use dye
import dye/[core, sprite, math]

use glew
import glew

import structs/[List, ArrayList, HashMap]

GlSet: class extends GlGroup {

    current := 0

    init: func {
        
    }

    drawChildren: func (dye: DyeContext) {
        if (children empty?()) return

        if (current < 0) {
            current = current + children size
        }
        if (current >= children size) {
            current = current - children size
        }

        child := children get(current)
        if (child) {
            child render(dye)
        }
    }

}

GlAnim: class extends GlGroup {

    current := 0
    xSwap := false

    offset := vec2(0, 0)

    frameDuration, counter: Int

    init: func (frameDuration := 4) {
        super()

        this frameDuration = frameDuration
        this counter = frameDuration
    }

    sequence: static func (formatStr: String, min, max: Int) -> This {
        anim := new()
        for (i in min..(max + 1)) {
            path := formatStr format(i)
            anim add(GlSprite new(path))
        }
        anim
    }

    rewind: func {
        current = 0
    }

    update: func (ticks := 1) {
        counter -= ticks

        if (ticks > 0) {
            if (counter <= 0) {
                current = (current + 1) % children size
                counter += frameDuration
            }
        } else {
            if (counter > children size) {
                current = current - 1
                if (current < 0) {
                    current = children size - 1
                }
                counter -= frameDuration
            }
        }
    }

    drawChildren: func (dye: DyeContext) {
        if (children empty?()) return

        child := children get(current)
        match child {
            case sprite: GlSprite =>
                sprite xSwap = xSwap
        }
        
        glPushMatrix()
        glTranslatef(xSwap ? 0 - offset x : offset x, offset y, 0)
            child render(dye)
        glPopMatrix()
    }

}

GlAnimSet: class extends GlDrawable {

    children := HashMap<String, GlAnim> new()
    currentName: String
    current: GlAnim
    xSwap := false

    update: func (ticks := 1) {
        if (current) current update(ticks)
    }

    draw: func (dye: DyeContext) {
        if (current) {
            current xSwap = xSwap
            current render(dye)
        }
    }

    put: func (name: String, anim: GlAnim) {
        children put(name, anim)
    }

    play: func (name: String) {
        if (name != currentName) {
            kiddo := children get(name)

            if (kiddo) {
                currentName = name
                current = kiddo
                current rewind()
            }
        }
    }

}

