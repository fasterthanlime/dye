
use dye
import dye/[core, sprite, math, app]

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    init: func {
        super("Sprite test", 1280, 720)
    }

    setup: func {
        {
            sprite := Sprite new("images/ship.png")
            sprite pos = vec2(200, 200)
            dye add(sprite)
        }

        {
            sprite := Sprite new("images/ship.png")
            sprite pos = vec2(400, 200)
            sprite color = Color green
            dye add(sprite)
        }
    }

}

