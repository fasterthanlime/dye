
use dye
import dye/[core, app, math, geometry]
import dye/gritty/[texture]

import sdl2/[OpenGL]

main: func (argc: Int, argv: CString*) {
    TriGeomTest new() run(60.0)
}

TriGeomTest: class extends App {

    geom: Geometry
    count := 0
    numQuads := 0

    init: func {
        super("TriGeom test", 1280, 768)
        dye setClearColor(Color black())
    }

    setup: func {
        geom = Geometry new(TextureLoader load("ship.png"))
        geom mode = GL_TRIANGLE_STRIP
        dye add(geom)
    }

    update: func {
        if (count == 0) {
            texture := geom texture

            drawQuad := func (b: GeomBuilder, dx, dy: Float) {
                b vertex(0, 0, dx, dy)
                b vertex(1, 0, dx + texture width, dy)
                b vertex(0, 1, dx, dy + texture height)
                b vertex(1, 1, dx + texture width, dy + texture height)
            }

            numQuads += 1
            geom build(4 * numQuads, |b|
                for (i in 0..numQuads) {
                    if (i % 2 == 0) {
                        drawQuad(b, texture width * i * 0.2,
                                    texture height * i * 0.1)
                    } else {
                        drawQuad(b, texture width * i * 0.1,
                                    texture height * i * 0.2)
                    }
                }
            )
        }
        count = (count + 1) % 15
    }

}


