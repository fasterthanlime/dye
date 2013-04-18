
use dye
import dye/[core, text, primitives, app, math]

main: func (argc: Int, argv: CString*) {
    FontTest new() run(2.0)
}

FontTest: class extends App {

    testString := "apqjkl'a,a"

    init: func {
        super("Font test", 1280, 768)
    }

    setup: func {
        addColumn(20, "classiq-medium")
        addColumn(600, "impact")
    }

    addColumn: func (x: Float, fontName: String) {
        addText(fontName, vec2(x, 580), 45)
        addText(fontName, vec2(x, 470), 38)
        addText(fontName, vec2(x, 380), 29)
        addText(fontName, vec2(x, 300), 25)
        addText(fontName, vec2(x, 240), 21)
        addText(fontName, vec2(x, 180), 18)
        addText(fontName, vec2(x, 130), 16)
        addText(fontName, vec2(x, 60), 14)
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text := GlText new(fontPath, testString, fontSize)
        text color set!(Color white())
        text pos set!(pos)

        size := text size

        rect := GlRectangle new(text size)
        rect pos set!(text pos)
        rect color set!(Color new(40, 40, 40))
        rect center = false

        dye add(rect)
        dye add(text)
    }

}

