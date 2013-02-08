
import sdl2/[OpenGL]

use dye
import dye/[core, math]
import dye/gritty/[shader, texture]

GlSegment: class extends GlDrawable {

    p1, p2: Vec2
    color := Color red()

    init: func (=p1, =p2) {
    }

    draw: func (dye: DyeContext) {
        // FIXME: colors
        //dye color(color)
        // glLineWidth(2.5)

        // FIXME: drawing
        // dye begin(GL_LINES, ||
        //     dye vertex(p1)
        //     dye vertex(p2)
        // )
    }

}

GlRectangle: class extends GlDrawable {

    size := vec2(16, 16)
    color := Color green()
    center := true
    filled := true
    lineWidth := 2.0

    width: Float { get { size x } }
    height: Float { get { size y } }

    init: func {
    }

    draw: func (dye: DyeContext) {
        // FIXME: color
        // dye color(color)
        
        // FIXME: drawing
        // if (!filled) {
        //     glLineWidth(lineWidth)
        // }

        // if (center) {
        //     halfX := size x * 0.5
        //     halfY := size y * 0.5

        //     dye begin(filled ? GL_QUADS : GL_LINE_LOOP, ||
        //         glVertex2f(-halfX, -halfY)
        //         glVertex2f( halfX, -halfY)
        //         glVertex2f( halfX,  halfY)
        //         glVertex2f(-halfX,  halfY)
        //     )
        // } else {
        //     dye begin(filled ? GL_QUADS : GL_LINE_LOOP, ||
        //         glVertex2f(0.0, 0.0)
        //         glVertex2f(size x, 0.0)
        //         glVertex2f(size x, size y)
        //         glVertex2f(0.0, size y)
        //     )
        // }
    }

}

GlTriangle: class extends GlDrawable {

    draw: func (dye: DyeContext) {
        // FIXME: drawing & color
        //dye begin(GL_TRIANGLES, ||
        //    glColor3f(1.0, 0.0, 0.0)
        //    glVertex2f(-10.0, 0.0)

        //    glColor3f(0.0, 1.0, 0.0)
        //    glVertex2f(10.0, 0.0)

        //    glColor3f(0.0, 0.0, 1.0)
        //    glVertex2f(0.0, 10.0)
        //)
    }

}

GlCross: class extends GlDrawable {

    color := Color new(100, 100, 100)
    lineWidth := 1.0

    init: func

    draw: func (dye: DyeContext) {
        infinity := 1_000_000.0

        // FIXME: drawing & color
        //dye color(color)
        //glLineWidth(lineWidth)
        //dye begin(GL_LINES, ||
        //    glVertex2f(-infinity, 0)
        //    glVertex2f( infinity, 0)

        //    glVertex2f(0, -infinity)
        //    glVertex2f(0,  infinity)
        //)
    }

}

GlGrid: class extends GlDrawable {

    color := Color new(100, 100, 100)
    lineWidth := 1.0

    width := 16.0
    num := 30

    init: func {
    }

    draw: func (dye: DyeContext) {
        infinity := 1_000_000.0

        // FIXME: drawing and color
        //dye color(color)
        //glLineWidth(lineWidth)

        //offset := num * 0.5 * width

        //dye begin(GL_LINES, ||
        //    for (i in 0..(num + 1)) for (j in 0..(num + 1)) {
        //        x := i * width - offset
        //        y := j * width - offset

        //        glVertex2f(-offset, y)
        //        glVertex2f( offset, y)

        //        glVertex2f(x, -offset)
        //        glVertex2f(x,  offset)
        //    }
        //)
    }

}

