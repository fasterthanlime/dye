
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

    size := 0.4
    
    fontWidth, fontHeight: Int

    init: func ~defaultSize (=fontPath, =value) {
        ftgl = Ftgl new(80, 72, fontPath)
    }

    draw: func (dye: DyeContext) {
        dye color(color)
        ftgl render(pos x, pos y, size, true, value)
    }

}

