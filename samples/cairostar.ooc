
use dye, dye-cairo
import dye/[core, math, app, sprite]
import dye/ext/cairo

use cairo
import cairo/Core

import math

CairoStarTest: class extends App {

    angle := 0.0f
    red := 0.0f
    redDelta := 0.01f
    x := 150.0f
    xdelta := 2.0f

    canvas: Canvas

    init: func {
        super("Cairo star test", 1280, 720)
        dye setClearColor(Color black())
    }

    setup: func {
        sprite := Sprite new("images/ship.png")
        sprite pos = (10, 10) as Vec2
        dye add(sprite)

        canvas = Canvas new(dye width, dye height)
        dye add(canvas)
    }

    update: func {
        angle += 0.08f / (PI * 2.0f)

        red += redDelta
        if (red > 1.0f | red < 0.0f) {
            redDelta *= -1.0f
        }

        x += xdelta 
        if (x > dye width - 150.0f | x < 150.0f) {
            xdelta *= -1.0f
        }

        cr := canvas context

        cr setSourceRGBA(0, 0, 0, 0)
        cr paint()

        cr save()
        cr translate(x, 300)
        cr rotate(angle)

        cr drawStar(5, 200, 0.5)

	    cr setLineWidth(12)
	    cr setSourceRGB(0.8, 0.4, 0.1)
        cr fillPreserve()

	    cr setSourceRGB(red, 0.1, 0.1)
        cr stroke()

        cr restore()
    }

}

extend CairoContext {

    drawStar: func (pikes: Int, radius, ratio: Float) {
        inside := false

        angle := 0.0f
        TWOPI := 2.0f * PI

        steps := pikes * 2
        for (i in 0..steps) {
            angle += TWOPI / (steps as Float)
            if (i == 0) {
                moveTo(cos(angle) * radius, sin(angle) * radius)
            } else {
                if (inside) {
                    lineTo(cos(angle) * radius * ratio, sin(angle) * radius * ratio)
                } else {
                    lineTo(cos(angle) * radius, sin(angle) * radius)
                }
            }
            inside = !inside
        }

        closePath()
    }

}

main: func {
    CairoStarTest new() run(60.0)
}


