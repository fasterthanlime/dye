
use dye, dye-cairo
import dye/[core, math, app, cairo]

import cairo/Cairo
import math

CairoStarTest: class extends App {

    canvas: Canvas

    init: func {
        super("Cairo star test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    }

    update: func {
        cr := canvas context

        cr setSourceRGB(0, 0, 0)
        cr paint()

	    cr setLineWidth(12)
	    cr setSourceRGB(0.9, 0.1, 0.1)
        cr drawStar(300, 300, 5, 200, 0.5)
        cr fill()

	    cr setSourceRGB(0.8, 0.4, 0.1)
        cr drawStar(300, 300, 5, 200, 0.5)
        cr stroke()
    }

}

extend CairoContext {

    drawStar: func (x, y, pikes: Int, radius, ratio: Float) {
        inside := true

        angle := 0.
        TWOPI := const 6.28

        moveTo(x + cos(angle) * radius, y + sin(angle) * radius)

        steps := pikes * 2
        while(angle < TWOPI) {
            angle += TWOPI / steps
            inside = !inside
            if (inside)
                lineTo(x + cos(angle) * radius, y + sin(angle) * radius)
            else
                lineTo(x + cos(angle) * radius * ratio, y + sin(angle) * radius * ratio)
        }

        closePath()
    }

}

main: func {
    CairoStarTest new() run(60.0)
}


