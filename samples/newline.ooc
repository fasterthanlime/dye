
use dye
import dye/[core, text, primitives, app, math]

main: func (argc: Int, argv: CString*) {
    FontTest new() run(2.0)
}

FontTest: class extends App {

    testString := "Well, see, now we need\nto wrap this up quickly."

    init: func {
        super("Font test (Newline)", 1280, 768)
        dye setClearColor(Color white())
    }

    setup: func {
        addText("classiq-medium", vec2(30, 200), 24)
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text := GlText new(fontPath, testString, fontSize)
        text color set!(Color black())
        text pos set!(pos)

        size := text size

        rect := GlRectangle new(vec2(text size x, text size y))
        rect pos set!(text pos sub(0, 2))
        rect color set!(Color new(150, 40, 40))
        rect center = false

        dye add(rect)
        dye add(text)
    }

}

