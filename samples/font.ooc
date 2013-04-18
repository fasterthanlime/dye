
use dye
import dye/[core, text, primitives, app, math]

main: func (argc: Int, argv: CString*) {
    FontTest new() run(2.0)
}

FontTest: class extends App {

    testString := "The 'quick' brown fox: jumps over, the lazy dog;"

    init: func {
        super("Font test", 1280, 768)
        dye setClearColor(Color white())
    }

    setup: func {
        addColumn(5, "classiq-medium")
        addColumn(600, "impact")
    }

    addColumn: func (x: Float, fontName: String) {
        initialSize := 32
        getSize := func -> Int {
            value := initialSize
            initialSize -= 1
            value
        }

        initialHeight := 740
        getHeight := func -> Int {
            value := initialHeight
            initialHeight -= 42
            value
        }

        for (i in 0..18) {
            addText(fontName, vec2(x, getHeight()), getSize())
        }
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text := GlText new(fontPath, testString, fontSize)
        text color set!(Color black())
        text pos set!(pos)

        size := text size

        rect := GlRectangle new(vec2(text size x, 2))
        rect pos set!(text pos sub(0, 2))
        rect color set!(Color new(150, 40, 40))
        rect center = false

        dye add(rect)
        dye add(text)
    }

}

