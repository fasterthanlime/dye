
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
        addText("JackStory", vec2(40, 720 - 50), 40)
    }

    addText: func (fontName: String, pos: Vec2, fontSize: Int) {
        fontPath := "fonts/%s.ttf" format(fontName)
        text = GlText new(fontPath, "", fontSize)
        text color set!(Color white())
        text pos set!(pos)
        dye add(text)
    }

    update: func {
        index += 1
        if (index > 1 && length < source size) {
            index = 0
            length += 1
            text value = source[0..length]
        }

        bounds := text size

        if (text pos y < bounds y) {
            text pos y lerp!(bounds y, 0.1)
        }
    }

}

