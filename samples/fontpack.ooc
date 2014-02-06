
// ours
use dye
import dye/[core, text, primitives, app, math]

// sdk
import io/File

main: func (argc: Int, argv: CString*) {
    FontTest new() run(60.0)
}

FontTest: class extends App {

    testString := File new("theraven.txt") read()

    init: func {
        super("Font packing test", 512, 512)
        dye setClearColor(Color black())
    }

    setup: func {
        addText("classiq-medium", vec2(0, 0), 80)
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text := GlText new(fontPath, testString, fontSize)
        text color set!(0, 0, 0)
        text pos set!(pos)
        dye add(text)
    }

}

