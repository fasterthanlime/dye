use dye
import dye/core

use sdl, glew, glu

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := DyeContext new(640, 480, "Dye example")
  dye add(GlTriangle new())

  dye render()
  Time sleepSec(1)

  dye quit()

}

