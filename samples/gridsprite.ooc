
use dye
import dye/[core, sprite, math, app]

main: func (argc: Int, argv: CString*) {
    GridSpriteTest new() run(60.0)
}

GridSpriteTest: class extends App {

    sprite: GlGridSprite
    counter := 0

    init: func {
        super("Grid sprite test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        sprite = GlGridSprite new("grid.png", 4, 4)
        sprite pos set!(dye center)
        sprite center = true
        sprite scale set!(10, 10)
        dye add(sprite)
    }

    update: func {
        counter += 1
        if (counter > 5) {
            counter = 0

            if (sprite col >= sprite xnum - 1) {
                sprite col = 0
                if (sprite row >= sprite ynum - 1) {
                    sprite row = 0
                } else {
                    sprite row += 1
                }
            } else {
                sprite col += 1
            }

            "sprite texX/Y = #{sprite texX}, #{sprite texY}, width height = #{sprite w}, #{sprite h}" println()
        }
    }

}

