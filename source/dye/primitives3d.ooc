
use sdl2
import sdl2/[OpenGL]

use dye
import dye/[core, math]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

GlCube: class extends GlSpriteLike {

    vao: VAO

    vbo: FloatVBO
    ebo: UShortVBO

    vertices: Float[]

    rotateY := 0.0f

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func {
        vbo = FloatVBO new()
        ebo = UShortVBO new()
        rebuild()
        setProgram(ShaderLoader loadFromRepo("shaders", "cube"))
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
        vao add(vbo, "Position", 3, GL_FLOAT, false, 0, 0 as Pointer)

        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!shouldDraw?(pass)) return

        mv := computeModelView(modelView)

        // if (center) {
        //     mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        // }

        s := 20.0f
        mv = mv * Matrix4 newScale(s, s, s)
        mv = mv * Matrix4 newRotateX(rotateY)

        draw(pass, mv)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        program use()
        vao bind()
        ebo bind()

        glUniformMatrix4fv(projLoc, 1, false, pass projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        glDrawElements(GL_TRIANGLES, 6 * 2 * 3, GL_UNSIGNED_SHORT, 0 as Pointer)

        vao detach()
        program detach()
    }

    rebuild: func {
        vertices = [
            // front
            -1.0, -1.0,  1.0,
            1.0, -1.0,  1.0,
            1.0,  1.0,  1.0,
            -1.0,  1.0,  1.0,
            // back
            -1.0, -1.0, -1.0,
            1.0, -1.0, -1.0,
            1.0,  1.0, -1.0,
            -1.0,  1.0, -1.0,
        ]
        vbo upload(vertices)

        indices := [
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

