
/*
use ftgl
import ftgl
*/

import sdl2/[OpenGL]

use dye
import dye/[core, math]

use deadlogger
import deadlogger/[Log, Logger]

import structs/HashMap

GlText: class extends GlDrawable {

    // FIXME
    //cache := static HashMap<String, Font> new()
    logger := static Log getLogger(This name)

    fontPath: String
    // FIXME
    //font: Font
    color := Color white()
    value: String

    lineHeight: Float
    
    fontWidth, fontHeight: Int

    init: func (=fontPath, =value, fontSize := 40) {
        // FIXME
        //font = loadFont(fontPath, fontSize)
        //lineHeight = font getLineHeight()
    }

    size: Vec2 {
        get {
            /*
            bounds := font getBounds(value)
            vec2(bounds getWidth(), lineHeight)
            */

            // FIXME
            vec(0, 0)
        }
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        /*
        dye color(color)
        font render(value)
        */
    }

    // FIXME
    /*
    loadFont: static func (fontPath: String, fontSize: Int) -> Font {
        key := "%s-%d" format(fontPath, fontSize)

        if (cache contains?(key)) {
            cache get(key)
        } else {
            logger debug("Loading font %s at size %d" format(fontPath, fontSize))
            font := Font new(fontSize, fontSize, fontPath)
            cache put(key, font)
            font
        }
    }
    */

}

