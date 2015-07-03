
use dye
import dye/[core, sprite, math, app, primitives3d]

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    cube: GlCube

    init: func {
        super("Cube test", 1280, 720)
        dye setClearColor(Color new(0, 0, 0))
    }

    setup: func {
        cube = GlCube new()
        cube pos = dye center
        dye add(cube)
    }

    update: func {
        cube rotateY += 0.01f
    }

}


