
use dye
import dye/[core, app, math, geometry]
import dye/gritty/[texture]

import sdl2/[OpenGL]

main: func (argc: Int, argv: CString*) {
    TriGeomTest new() run(60.0)
}

TriGeomTest: class extends App {

    init: func {
        super("TriGeom test", 1280, 768)
        dye setClearColor(Color black())
    }

    setup: func {
        texture := TextureLoader load("ship.png")
        geom := TriGeom new(texture)
        geom mode = GL_TRIANGLE_STRIP

        geom upload(4, |data|
            i := 0

            data[i + 0] = 0.0f
            data[i + 1] = 0.0f
            data[i + 2] = 0.0f
            data[i + 3] = 0.0f
            i += 4

            data[i + 0] = 1.0f
            data[i + 1] = 0.0f
            data[i + 2] = texture width
            data[i + 3] = 0.0f
            i += 4

            data[i + 0] = 0.0f
            data[i + 1] = 1.0f
            data[i + 2] = 0.0f
            data[i + 3] = texture height
            i += 4

            data[i + 0] = 1.0f
            data[i + 1] = 1.0f
            data[i + 2] = texture width
            data[i + 3] = texture height
            i += 4
        )
        dye add(geom)
    }

}


