
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
        geom mode = GL_TRIANGLES
        dye add(geom)
    }

    update: func {
        if (count == 0) {
            texture := geom texture

            numQuads += 1
            geom build(6 * numQuads, |b|
                for (i in 0..numQuads) {
                    if (i % 2 == 0) {
                        b quad6(i * 40, i * 20, texture width, texture height, 0, 0, 1, 1)
                    } else {
                        b quad6(i * 20, i * 40, texture width, texture height, 0, 0, 1, 1)
                    }
                }
            )
        }
        count = (count + 1) % 10
    }

}


