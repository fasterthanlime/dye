use dye
import dye/[core, primitives]

import os/Time

main: func (argc: Int, argv: CString*) {

  dye := DyeContext new(640, 480, "Dye example")
  dye setClearColor(Color black())

  triangle := GlTriangle new()
  triangle scale set!(10, 10)
  triangle pos set!(dye width / 2, dye height / 2)
  dye add(triangle)

  dye render()
  Time sleepSec(o)

  dye quit()

}

