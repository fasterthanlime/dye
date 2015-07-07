
use dye
import dye/[core, app, math, text, sprite, input, fbo, pass]

main: func (argc: Int, argv: CString*) {
    ResizeFbo new() run(60.0)
}

ResizeFbo: class extends App {
    counter := 0
    fbo: Fbo
    fboSprite: Sprite
    text: Text
    pass: TexturePass

    init: func {
        super("FBO resizing test", 1280, 768)
        dye setClearColor(45, 128, 71)
    }

    setup: func {
        pass = TexturePass new((400, 400) as Vec2i)
        fbo := pass fbo
        pass clearColor = Color red

        fboSprite = Sprite new(fbo texture)
        fboSprite center = false
        dye add(fboSprite)

        text = Text new("fonts/impact.ttf", "I am in an FBO.", 80)
        text pos = (20, 20) as Vec2
        text color = Color white
        pass group add(text)

        dye input onMouseMove(|ev|
            resize(ev pos)
        )
    }

    resize: func(pos: Vec2) {
        size := vec2i(pos x, pos y)
        if (pass resize(size)) {
            fboSprite setTexture(pass fbo texture)
        }
        pass render()
    }

    smallCounter := 0

    update: func {
        smallCounter += 1
        if (smallCounter > 60) {
            smallCounter = 0
            counter += 1
            text value = "On the #{counter}th day of christmas.";

            pass render()
        }
    }

}


