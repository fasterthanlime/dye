
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
        text := GlText new("font.ttf", "Life is short, the art long. - Hippocrates", 42)
        text color set!(Color white())
        text pos set!(20, 60)

        size := text size
        "text size = %s" printfln(text size _)

        rect := GlRectangle new(text size)
        rect pos set!(text pos)
        rect color set!(Color new(20, 20, 20))
        rect center = false

        dye add(rect)
        dye add(text)
    }

}

