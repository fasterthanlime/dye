
// ours
import dye/[core, math, sprite]
import dye/gritty/[texture]

use cairo
import cairo/Cairo

use sdl2
import sdl2/[OpenGL]

/**
 * Something on which you can draw with cairo
 */
Canvas: class extends GlSprite {

    width, height: Int
    cairoSurface: CairoSurface
    context: CairoContext

    surfData: UInt8*

    init: func (=width, =height) {
        center = false
        _createCairoContext()

        texture = Texture new(width, height, "<cairo canvas>")
        texture format = GL_BGRA
        super(texture)
    }

    // internal cuisine

    _createCairoContext: func {
        channels := 4
        surfData = gc_malloc_atomic(channels * width * height * UChar size)
        if (!surfData) {
            raise("Canvas - could not allocate buffer")
        }

        cairoSurface = CairoImageSurface new(surfData as UChar*, CairoFormat ARGB32,
            width, height, channels * width)
        if (cairoSurface status() != CairoStatus SUCCESS) {
            raise("Canvas - could not create surface")
        }

        context = CairoContext new(cairoSurface)
        if (context status() != CairoStatus SUCCESS) {
            raise("Canvas - could not create context")
        }
    }

    render: func (pass: Pass, modelView: Matrix4) {
        texture upload(surfData)
        super(pass, modelView)
    }

}

