
use dye
import dye/[core, text, primitives, app, math]

main: func (argc: Int, argv: CString*) {
    FontTest new() run(60.0)
}

FontTest: class extends App {

    testString := "{The 'quick' brown fox: jumps over, the lazy dog;)"

    init: func {
        super("Font packing test", 1024, 512)
        dye setClearColor(Color white())
    }

    setup: func {
        addText("classiq-medium", vec2(0, 512), 130)
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text := GlText new(fontPath, testString, fontSize)
        text color set!(0, 0, 0)
        text pos set!(pos)
        dye add(text)
    }

}

