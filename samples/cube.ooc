
use dye
import dye/[core, sprite, math, app, primitives, primitives3d]

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    cube: Cube

    init: func {
        super("Cube test", 1280, 720)
    }

    setup: func {
        sprite := Sprite new("images/ship.png")
        sprite center = false
        sprite pos = dye center add(120, 0)
        sprite center = true
        dye add(sprite)

        square := Rectangle new(1, 1)
        square scale = (80, 80) as Vec2
        square pos = dye center sub(120, 0)
        square center = true
        dye add(square)

        cube = Cube new()
        cube scale = (40, 40) as Vec2
        cube pos = dye center
        dye add(cube)
    }

    update: func {
        mp := dye input mousepos
        factor := 0.01
        cube rotateX = -mp y * factor
        cube rotateY = -mp x * factor
    }

}


