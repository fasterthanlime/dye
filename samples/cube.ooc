
use dye
import dye/[core, sprite, math, app, primitives3d]

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    cube: GlCube

    init: func {
        super("Cube test", 1280, 720)
        dye setClearColor(Color new(255, 255, 255))
    }

    setup: func {
        cube = GlCube new()
        cube pos = dye center
        dye add(cube)
    }

    update: func {
        mp := dye input mousepos
        factor := 0.01
        cube rotateX = mp x * factor
        cube rotateY = mp y * factor
    }

}


