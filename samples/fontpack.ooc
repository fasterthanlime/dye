
// ours
use dye
import dye/[core, text, primitives, app, math]

// sdk
import io/File

main: func (argc: Int, argv: CString*) {
    FontTest new() run(60.0)
}

FontTest: class extends App {

    source := File new("theraven.txt") read()
    //source := "Maybe.\nMaybe not.\nMaybe go fuck yourself."
    index := 0
    length := 0

    text: GlText

    init: func {
        super("Font packing test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        addText("noodle", vec2(40, 720 - 50), 18)
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text = GlText new(fontPath, "", fontSize)
        text color set!(0, 0, 0)
        text pos set!(pos)
        dye add(text)
    }

    update: func {
        index += 1
        if (index > 3 && length < source size) {
            index = 0
            length += 4
            text value = source[0..length]
        }
    }

}

