
use sdl2
import sdl2/[OpenGL]

use dye
import dye/[core, math]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

/**
 * Plain, monochrome, non-textured rectangle
 */
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
            vao = null
        }

        vao = VAO new(program)
        vao add(vbo, "Position", 2, GL_FLOAT, false, 0, 0 as Pointer)

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!shouldDraw?(pass)) return

        mv := computeModelView(modelView)

        if (center) {
            mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        }

        draw(pass, mv)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        if (!size equals?(oldSize, EPSILON)) {
            rebuild()
        }

        program use()
        vao bind()

        glUniformMatrix4fv(projLoc, 1, false, pass projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

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

/**
 * Plain, monochrome, non-textured convex polygon
 */
GlPoly: class extends GlDrawable {

    points: Vec2*
    count: Int

    EPSILON := 0.1

    color := Color green()
    opacity := 1.0

    program: ShaderProgram
    vao: VAO

    vbo: FloatVBO
    vertices: Float[]

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func (=points, =count) {
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
            vao = null
        }

        vao = VAO new(program)
        vao add(vbo, "Position", 2, GL_FLOAT, false, 0, 0 as Pointer)

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!shouldDraw?(pass)) return

        mv := computeModelView(modelView)
        draw(pass, mv)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        program use()
        vao bind()

        glUniformMatrix4fv(projLoc, 1, false, pass projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)


        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        glDrawArrays(GL_TRIANGLES, 0, vertices length / 2)

        vao detach()
        program detach()

    }

    rebuild: func {
        numTris := count - 2
        numVerts := numTris * 3
        numFloats := numVerts * 2

        vertices = Float[numFloats] new()
        vi := 0

        p0 := points[0]
        for (i in 2..count) {
            p1 := points[i - 1]
            p2 := points[i]

            vertices[vi] = p0 x; vi += 1
            vertices[vi] = p0 y; vi += 1

            vertices[vi] = p1 x; vi += 1
            vertices[vi] = p1 y; vi += 1

            vertices[vi] = p2 x; vi += 1
            vertices[vi] = p2 y; vi += 1
        }

        vbo upload(vertices)
    }

}

