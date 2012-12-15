
use ftgl
import ftgl

use dye
import dye/core

GlText: class extends GlDrawable {

    ftgl: Ftgl
    x, y: Int
    text: String

    init: func (fontPath: String, =text) {
        ftgl = Ftgl new(80, 72, fontPath)
        x = 20
        y = 40
    }

    draw: func (dye: DyeContext) {
        ftgl render(x, y, 0.4, true, text)
    }

}

