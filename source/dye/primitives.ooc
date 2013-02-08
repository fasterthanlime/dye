
import sdl2/[OpenGL]

use dye
import dye/[core, math]
import dye/gritty/[shader, texture, vbo]

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

    size: Vec2
    color := Color green()
    center := true
    filled := true
    lineWidth := 2.0

    width: Float { get { size x } }
    height: Float { get { size y } }
    program: ShaderProgram
    vbo: FloatVBO 
    vertices: Float[]

    init: func (size := vec2(16, 16)) {
        this size = size clone()
        vbo = FloatVBO new()
        rebuild()

        program = ShaderLoader getDefaultProgram()
        program vertexAttribPointer("position", 2, GL_FLOAT, false, 0, 0 as Pointer)
    }

    draw: func (dye: DyeContext) {
        vbo bind()
        program use()
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)
        program vao detach()
    }

    rebuild: func {
        vertices = [
            0.0, 0.0,
            size x, 0.0,
            0.0, size y,
            size x, size y
        ]

        if (center) {
            halfX := size x * 0.5
            halfY := size y * 0.5

            for (i in 0..4) {
                vertices[i * 2]     = vertices[i * 2]     - halfX
                vertices[i * 2 + 1] = vertices[i * 2 + 1] - halfY
            }
        } else {
        }
        vbo data(vertices)
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

