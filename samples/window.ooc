use dye
import dye

use sdl

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := Dye new(640, 480)

  dye draw()
  Time sleepSec(1)

  dye quit()

}

