
use dye
import dye/[core, sprite, math, app, primitives, primitives3d]

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    cube: GlCube

    init: func {
        super("Cube test", 1280, 720)
        dye setClearColor(Color new(128, 128, 128))
    }

    setup: func {
        // for (x in 0..12) {
        //     for (y in 0..7) {
        //         sprite := GlSprite new("ship.png")
        //         sprite center = false
        //         sprite pos set!(x * 100, y * 100)
        //         dye add(sprite)
        //     }
        // }

        square := GlRectangle new(vec2(1, 1))
        square scale set!(40, 40)
        square pos set!(dye center sub(120, 0))
        dye add(square)

        cube = GlCube new()
        cube scale set!(40, 40)
        cube pos set!(dye center)
        dye add(cube)
    }

    update: func {
        mp := dye input mousepos
        // factor := 0.01
        // cube rotateX = mp y * factor
        // cube rotateY = mp x * factor
        // s := mp x * 0.3
        // cube angle = s
        // cube pos set!(mp)
    }

}


