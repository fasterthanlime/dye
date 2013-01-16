
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

    cache := static HashMap<String, Ftgl> new()
    logger := static Log getLogger(This name)

    fontPath: String
    ftgl: Ftgl
    pos := vec2(20, 40)
    color := Color white()
    value: String

    scale := 1.0
    
    fontWidth, fontHeight: Int

    init: func (=fontPath, =value, fontSize := 20) {
        ftgl = loadFont(fontPath, fontSize)
    }

    size: Vec2 {
        get {
            bb := ftgl getFontBBox(value)
            vec2(bb urx - bb llx, bb ury - bb lly)
        }
    }

    draw: func (dye: DyeContext) {
        dye color(color)
        ftgl render(pos x, pos y, scale, true, value)
    }

    loadFont: static func (fontPath: String, fontSize: Int) -> Ftgl {
        key := "%s-%d" format(fontPath, fontSize)

        if (cache contains?(key)) {
            cache get(key)
        } else {
            logger info("Loading font %s at size %d" format(fontPath, fontSize))
            ftgl := Ftgl new(fontSize, fontSize, fontPath)
            cache put(key, ftgl)
            ftgl
        }
    }

}

