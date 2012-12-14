use dye
import dye/[core, sprite]

use sdl, glew, glu

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := Dye new(640, 480, "Dye example")
  dye add(GlSprite new("sprite.png"))

  dye render()
  Time sleepSec(1)

  dye quit()

}

