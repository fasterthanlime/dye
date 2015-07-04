
use dye
import dye/[core, sprite, math, app, primitives, primitives3d]

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    cube: Cube

    init: func {
        super("Cube test", 1280, 720)
        dye setClearColor(Color new(0, 0, 0))
    }

    setup: func {
        sprite := Sprite new("ship.png")
        sprite center = false
        sprite pos set!(dye center add(120, 0))
        sprite center = true
        dye add(sprite)

        square := Rectangle new(vec2(1, 1))
        square scale set!(80, 80)
        square pos set!(dye center sub(120, 0))
        square center = true
        dye add(square)

        cube = Cube new()
        cube scale set!(40, 40)
        cube pos set!(dye center)
        dye add(cube)
    }

    update: func {
        mp := dye input mousepos
        factor := 0.01
        cube rotateX = -mp y * factor
        cube rotateY = -mp x * factor

        // s := mp x * 0.3
        // cube angle = s
        // cube pos set!(mp)
    }

}


