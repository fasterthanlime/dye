
// our stuff
use dye
import dye/[core, math]
import dye/gritty/font

// third-party stuff
import sdl2/[OpenGL]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/HashMap

GlText: class extends GlSpriteLike {

    cache := static HashMap<String, Font> new()
    logger := static Log getLogger(This name)

    fontPath: String
    font: Font
    value: String

    lineHeight: Float

    init: func (=fontPath, =value, fontSize := 40) {
        font = loadFont(fontPath, fontSize)
        lineHeight = font getLineHeight()
    }

    size: Vec2 {
        get {
            bounds := font getBounds(value)
            vec2(bounds width, lineHeight)
        }
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        font render(pass, modelView, value, color, opacity)
    }

    loadFont: static func (fontPath: String, fontSize: Int) -> Font {
        key := "%s-%d" format(fontPath, fontSize)

        if (cache contains?(key)) {
            cache get(key)
        } else {
            logger debug("Loading font %s at size %d" format(fontPath, fontSize))
            font := Font new(fontSize, fontPath)
            cache put(key, font)
            font
        }
    }

}

