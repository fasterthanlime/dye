
use dye
import dye/[core, font, sprite, input, math]

import os/Time

main: func (argc: Int, argv: CString*) {

    dye := DyeContext new(640, 480, "Dye mouse example")
    dye setShowCursor(false)

    crosshair := GlSprite new("crosshair.png")
    crosshairGroup := GlGroup new()
    crosshairGroup add(crosshair)
    dye add(crosshairGroup)

    input := Input new()

    running := true

    input onMousePress(1, || running = false)

    while (running) {
        input _poll()
        dye render()

        crosshairGroup pos set!(input getMousePos())
        Time sleepMilli(8)
    }

    dye setShowCursor(true)
    dye quit()

}

