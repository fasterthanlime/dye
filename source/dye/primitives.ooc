
import sdl2/[OpenGL]

use dye
import dye/[core, math]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

GlSegment: class extends GlDrawable {

    p1, p2: Vec2
    color := Color red()

    init: func (=p1, =p2) {
        raise("GlSegment not quite implemented again yet!")
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
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
    oldSize := vec2(0, 0)

    EPSILON := 0.1

    color := Color green()
    opacity := 1.0

    center := true
    filled := true
    lineWidth := 2.0

    width: Float { get { size x } }
    height: Float { get { size y } }

    program: ShaderProgram
    vao: VAO

    vbo: FloatVBO 
    vertices: Float[]

    outlineIndices := [0, 1, 3, 2]

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func (size := vec2(16, 16)) {
        this size = size clone()
        vbo = FloatVBO new()
        rebuild()
        setProgram(ShaderLibrary getSolidColor())
    }

    setProgram: func (.program) {
        if (this program) {
            this program detach()
        }
        this program = program
        program use()

        if (vao) {
            vao delete()
            vao = null
        }

        vao = VAO new(program)
        vao add(vbo, "Position", 2, GL_FLOAT, false, 0, 0 as Pointer)

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (dye: DyeContext, modelView: Matrix4) {
        if (center) {
            modelView = Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0) * modelView
        }

        super(dye, modelView)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        if (!size equals?(oldSize, EPSILON)) {
            rebuild()
        }

        program use()
        vao bind()

        glUniformMatrix4fv(projLoc, 1, false, dye projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)
        glUniform4f(colorLoc, color R, color G, color B, opacity)

        match filled {
            case true  =>
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)
            case false =>
                glLineWidth(lineWidth)
                glDrawElements(GL_LINE_LOOP, 4, GL_UNSIGNED_INT, outlineIndices data)
        }

        vao detach()
        program detach()

    }

    rebuild: func {
        vertices = [
            0.0, 0.0,
            size x, 0.0,
            0.0, size y,
            size x, size y
        ]
        oldSize set!(size)

        vbo upload(vertices)
    }

}

GlCross: class extends GlDrawable {

    color := Color new(100, 100, 100)
    lineWidth := 1.0

    init: func

    draw: func (dye: DyeContext, modelView: Matrix4) {
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

    draw: func (dye: DyeContext, modelView: Matrix4) {
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

