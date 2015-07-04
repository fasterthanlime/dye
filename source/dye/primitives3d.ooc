
use sdl2
import sdl2/[OpenGL]

use dye
import dye/[core, pass, math, shader, texture]
import dye/base/[vbo, vao]

Cube: class extends Drawable {

    program: ShaderProgram
    color := Color new(255, 0, 0)
    opacity := 1.0

    vao: VAO

    vbo: FloatVBO
    ebo: UIntVBO

    vertices: Float[]
    indices: UInt[]

    rotateX := 0.0f
    rotateY := 0.0f

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func {
        vbo = FloatVBO new()
        ebo = UIntVBO new()
        rebuild()
        setProgram(ShaderLoader load("dye/solid_3d"))
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
        stride := 3 * Float size
        vao add(vbo, "Position", 3, GL_FLOAT, false, stride, 0 as Pointer)
        ebo bind()

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!visible) return

        mv := computeModelView(modelView)

        // if (center) {
        //     mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        // }

        mv = mv * Matrix4 newRotateX(rotateX)
        mv = mv * Matrix4 newRotateY(rotateY)

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

        glEnable(GL_DEPTH_TEST)
        glDrawElements(GL_TRIANGLES, indices length, GL_UNSIGNED_INT, 0 as Pointer)
        glDisable(GL_DEPTH_TEST)

        vao detach()
        program detach()
    }

    rebuild: func {
        vertices = [
            -1.0, -1.0,  1.0, // v0 // front
             1.0, -1.0,  1.0, // v1
             1.0,  1.0,  1.0, // v2
            -1.0,  1.0,  1.0, // v3

            -1.0, -1.0, -1.0, // v4 // back
             1.0, -1.0, -1.0, // v5
             1.0,  1.0, -1.0, // v6
            -1.0,  1.0, -1.0, // v7
        ]
        vbo upload(vertices)

        indices = [
            // front
            0, 1, 2,
            2, 3, 0,

            // top
            3, 2, 6,
            6, 7, 3,

            // back
            7, 6, 5,
            5, 4, 7,

            // bottom
            4, 5, 1,
            1, 0, 4,

            // left
            4, 0, 3,
            3, 7, 4,

            // right
            1, 5, 6,
            6, 2, 1,
        ]
        ebo upload(indices)
    }

}

