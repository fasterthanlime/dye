use dye
import dye/[core, sprite]

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := DyeContext new(640, 480, "Dye example")
  dye setClearColor(Color black())
  sprite := GlSprite new("ship.png")
  sprite pos set!(200, 200)
  dye add(sprite)

  dye render()
  Time sleepSec(1)

  dye quit()

}

