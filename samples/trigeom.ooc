
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
        geom := Geometry new(texture)
        geom mode = GL_TRIANGLE_STRIP

        geom build(4, |b|
            b vertex(0, 0, 0, 0)
            b vertex(1, 0, texture width, 0)
            b vertex(0, 1, 0, texture height)
            b vertex(1, 1, texture width, texture height)
        )
        dye add(geom)
    }

}


