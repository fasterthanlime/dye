
use ftgl
import ftgl

use glew
import glew

use dye
import dye/[core, math]

GlText: class extends GlDrawable {

    ftgl: Ftgl
    pos := vec2(20, 40)
    color := Color blue()
    value: String

    init: func (fontPath: String, =value) {
        ftgl = Ftgl new(80, 72, fontPath)
    }

    draw: func (dye: DyeContext) {
        dye color(color)
        ftgl render(pos x, pos y, 0.4, true, value)
    }

}

