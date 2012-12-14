
use dye
import dye/[core, font]

use sdl, glew, glu, ftgl

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := Dye new(640, 480, "Dye font example")

  text := GlText new("Sansation_Regular.ttf", "Dye with text o/")
  dye add(text)

  dye render()
  Time sleepSec(1)

  dye quit()

}

