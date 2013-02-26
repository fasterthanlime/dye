
use dye
import dye/[core, text]

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := DyeContext new(640, 480, "Dye font example")
  dye setClearColor(Color white())

  text := GlText new("Zentropa.ttf", "Life is short, the art long. - Hippocrates", 42)
  text color set!(Color black())
  text pos set!(20, 60)
  dye add(text)

  "text size = %s" printfln(text size _)

  dye render()
  Time sleepSec(3)

  dye quit()

}

