use dye
import dye/[core, sprite]

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := DyeContext new(640, 480, "Dye example")
  dye add(GlSprite new("ship.png"))

  dye render()
  Time sleepSec(1)

  dye quit()

}

