
use dye
import dye/[core, sprite, input, math, app, loop]

main: func (argc: Int, argv: CString*) {
    MouseTest new() run(60.0)
}

MouseTest: class extends App {

    crosshair: Sprite

    init: func {
        super("Mouse demo", 640, 480)
        dye setShowCursor(false)
        dye setClearColor(Color new(30, 30, 30))

        dye input onMousePress(1, |mp|
            loop running = false
        )

        crosshair = Sprite new("images/crosshair.png")
        dye add(crosshair)
    }

    update: func {
        crosshair pos set!(dye input mousepos)
    }

}

