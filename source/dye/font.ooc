
use ftgl
import ftgl

use glew
import glew

use dye
import dye/[core, math]

GlText: class extends GlDrawable {

    fontPath: String
    ftgl: Ftgl
    pos := vec2(20, 40)
    color := Color blue()
    value: String

    scale := 1.0
    
    fontWidth, fontHeight: Int

    init: func (=fontPath, =value, fontSize := 20) {
        ftgl = Ftgl new(fontSize, fontSize, fontPath)
    }

    draw: func (dye: DyeContext) {
        dye color(color)
        ftgl render(pos x, pos y, scale, true, value)
    }

}

