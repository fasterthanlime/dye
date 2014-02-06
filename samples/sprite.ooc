
use dye
import dye/[core, sprite, math, app]

import os/Time

main: func (argc: Int, argv: CString*) {
    SpriteTest new() run(60.0)
}

SpriteTest: class extends App {

    init: func {
        super("Sprite test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        {
            sprite := GlSprite new("ship.png")
            sprite pos set!(200, 200)
            dye add(sprite)
        }

        {
            sprite := GlSprite new("ship.png")
            sprite pos set!(400, 200)
            sprite color set!(Color green())
            dye add(sprite)
        }
    }

}

