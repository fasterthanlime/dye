
use dye
import dye/[core, text, primitives]

import os/Time

main: func (argc: Int, argv: CString*) {

    dye := DyeContext new(640, 480, "Dye font example")
    dye setClearColor(Color white())

    text := GlText new("Zentropa.ttf", "Life is short, the art long. - Hippocrates", 42)
    text color set!(Color black())
    text pos set!(20, 60)

    size := text size
    "text size = %s" printfln(text size _)

    rect := GlRectangle new(text size)
    rect pos set!(text pos)
    rect color set!(Color new(20, 20, 20))
    rect filled = false
    rect center = false

    dye add(rect)
    dye add(text)

    dye render()
    Time sleepSec(3)

    dye quit()

}

