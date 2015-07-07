
use dye
import dye/[core, sprite, math, app]

main: func (argc: Int, argv: CString*) {
    GridSpriteTest new() run(60.0)
}

GridSpriteTest: class extends App {

    sprite: GridSprite
    counter := 0

    init: func {
        super("Grid sprite test", 1280, 720)
    }

    setup: func {
        sprite = GridSprite new("images/grid.png", 4, 4)
        sprite pos = dye center
        sprite center = true
        sprite scale = (10, 10) as Vec2
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
        }
    }

}

