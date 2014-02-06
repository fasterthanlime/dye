
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
        texture upload(surfData)
        super~fromTex(texture)
    }

    // internal cuisine

    _createCairoContext: func {
        channels := 4
        numBytes := channels * width * height
        surfData = gc_malloc_atomic(numBytes)
        memset(surfData, 0, numBytes)
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
        texture update(surfData, 0, 0, width, height)
        super(pass, modelView)
    }

    // draw stuff

    paint: func {
        context paint()
    }

    setLineWidth: func (width: Float) {
        context setLineWidth(width)
    }

    setSourceRGB: func (r, g, b: Float) {
        context setSourceRGB(r, g, b)
    }

    setSourceRGBA: func (r, g, b, a: Float) {
        context setSourceRGBA(r, g, b, a)
    }

    moveTo: func (x, y: Float) {
        context moveTo(x, y)
    }

    lineTo: func (x, y: Float) {
        context lineTo(x, y)
    }

    stroke: func {
        context stroke()
    }

    closePath: func {
        context closePath()
    }

}

