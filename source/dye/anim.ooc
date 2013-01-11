
use dye
import dye/[core, sprite, math]

use glew
import glew

import structs/[List, ArrayList, HashMap]

/**
 * An anim source has a certain number of frames and it can switch
 * from one frame to another.
 */
GlAnimSource: interface {

    numFrames: func -> Int
    setFrame: func (frame: Int)
    frameOffset: func (offset: Int)
    getDrawable: func -> GlDrawable

}

GlSet: class extends GlGroup implements GlAnimSource {

    current := 0

    init: func {
        
    }

    drawChildren: func (dye: DyeContext) {
        if (children empty?()) return

        current = current repeat(0, children size)
        child := children get(current)
        if (child) {
            child render(dye)
        }
    }

    // implement GlAnimSource

    numFrames: func -> Int  { children size }
    getDrawable: func -> GlDrawable { this }
    frameOffset: func (offset: Int) {
        current += offset
    }
    setFrame: func (=current)

}

GlAnim: class extends GlDrawable {

    source: GlAnimSource
    frameDuration, counter: Int

    init: func (=source, frameDuration := 4) {
        super()

        this frameDuration = frameDuration
        this counter = frameDuration
    }

    sequence: static func (formatStr: String, min, max: Int) -> This {
        source := GlSet new()
        for (i in min..(max + 1)) {
            path := formatStr format(i)
            source add(GlSprite new(path))
        }
        new(source)
    }

    rewind: func {
        source setFrame(0)
    }

    update: func (ticks := 1) {
        counter -= ticks

        if (ticks > 0) {
            if (counter <= 0) {
                source frameOffset(1)
                counter += frameDuration
            }
        } else {
            if (counter > frameDuration) {
                source frameOffset(-1)
                counter -= frameDuration
            }
        }
    }

    draw: func (dye: DyeContext) {
        source getDrawable() render(dye)
    }

}

GlAnimSet: class extends GlDrawable {

    children := HashMap<String, GlAnim> new()
    currentName: String
    current: GlAnim

    update: func (ticks := 1) {
        if (current) current update(ticks)
    }

    draw: func (dye: DyeContext) {
        if (current) {
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

