
use ftgl
import ftgl

use glew
import glew

use dye
import dye/[core, math]

use deadlogger
import deadlogger/[Log, Logger]

import structs/HashMap

GlText: class extends GlDrawable {

    cache := static HashMap<String, Font> new()
    logger := static Log getLogger(This name)

    fontPath: String
    font: Font
    pos := vec2(20, 40)
    color := Color white()
    value: String

    scale := 1.0
    lineHeight: Float
    
    fontWidth, fontHeight: Int

    init: func (=fontPath, =value, fontSize := 20) {
        font = loadFont(fontPath, fontSize)
        lineHeight = font getLineHeight()
    }

    size: Vec2 {
        get {
            bounds := font getBounds(value)
            vec2(bounds getWidth(), lineHeight)
        }
    }

    draw: func (dye: DyeContext) {
        dye color(color)

        glPushMatrix()
        glTranslatef(pos x, pos y, 0)
        glScalef(scale, scale, 1.0)
        font render(value)
        glPopMatrix()
    }

    loadFont: static func (fontPath: String, fontSize: Int) -> Font {
        key := "%s-%d" format(fontPath, fontSize)

        if (cache contains?(key)) {
            cache get(key)
        } else {
            logger info("Loading font %s at size %d" format(fontPath, fontSize))
            font := Font new(fontSize, fontSize, fontPath)
            cache put(key, font)
            font
        }
    }

}

