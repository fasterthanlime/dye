
use dye
import dye/[core, sprite, math]

import sdl2/OpenGL

import structs/[List, ArrayList, HashMap]

/**
 * Class: GlAnimSource
 * An anim source has a certain number of frames and it can switch
 * from one frame to another.
 */
GlAnimSource: interface {

    /**
     * Function: numFrames
     *
     * Gets the number of frames in that animation source
     *
     * Returns:
     *
     * the number of frames as an Int
     */
    numFrames: func -> Int

    setFrame: func (frame: Int)
    currentFrame: func -> Int
    frameOffset: func (offset: Int)
    getDrawable: func -> GlSpriteLike

}

GlSet: class extends GlSpriteLike implements GlAnimSource {

    current := 0
    children := ArrayList<GlSpriteLike> new()

    init: func

    draw: func (dye: DyeContext, modelView: Matrix4) {
        drawChildren(dye, modelView)
    }

    drawChildren: func (dye: DyeContext, modelView: Matrix4) {
        if (children empty?()) return

        current = current repeat(0, children size)
        child := children get(current)
        if (child) {
            child color set!(color)
            child opacity = opacity
            child render(dye, modelView)
        }
    }

    add: func (d: GlSpriteLike) {
        children add(d)
    }

    remove: func (d: GlSpriteLike) {
        children remove(d)
    }

    clear: func {
        children clear()
    }

    // implement GlAnimSource

    numFrames: func -> Int  { children size }
    getDrawable: func -> GlSpriteLike { this }
    frameOffset: func (offset: Int) {
        current += offset
    }
    setFrame: func (=current)
    currentFrame: func -> Int { current }

}

GlAnim: class extends GlSpriteLike {

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

    draw: func (dye: DyeContext, modelView: Matrix4) {
        drawable := source getDrawable()
        drawable color set!(color)
        drawable opacity = opacity
        drawable render(dye, modelView)
    }

}

GlAnimSet: class extends GlSpriteLike {

    children := HashMap<String, GlAnim> new()
    currentName: String
    current: GlAnim

    init: func

    update: func (ticks := 1) {
        if (current) current update(ticks)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        if (current) {
            match current {
                case sl: GlSpriteLike =>
                    sl color set!(color)
                    sl opacity = opacity
            }
            current render(dye, modelView)
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

    currentFrame: func -> Int {
        if (!current) {
            return -1
        }

        current source currentFrame()
    }
    
    frameOffset: func (offset: Int) {
        if (!current) {
            return
        }

        current source frameOffset(offset)
    }

}

