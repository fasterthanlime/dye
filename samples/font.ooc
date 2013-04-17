
use dye
import dye/[core, text, primitives, app]

main: func (argc: Int, argv: CString*) {
    FontTest new() run(2.0)
}

FontTest: class extends App {

    init: func {
        super("Font test")
    }

    setup: func {
        text := GlText new("fonts/classiq-medium.ttf", "Life is short, the art long. - Hippocrates", 42)
        text color set!(Color white())
        text pos set!(20, 60)

        size := text size

        rect := GlRectangle new(text size)
        rect pos set!(text pos)
        rect color set!(Color new(40, 40, 40))
        rect center = false

        dye add(rect)
        dye add(text)
    }

}

