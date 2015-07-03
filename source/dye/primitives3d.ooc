
use sdl2
import sdl2/[OpenGL]

use dye
import dye/[core, math]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

GlCube: class extends GlSpriteLike {

    vao: VAO

    vbo: FloatVBO
    ibo: UIntVBO

    vertices: Float[]

    rotateY := 0.0f

    /* Uniforms */
    projLoc, modelLoc, colorLoc: Int

    init: func {
        vbo = FloatVBO new()
        ibo = UIntVBO new()
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

//         if (center) {
//             mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
//         }

        s := 120.0f
        mv = mv * Matrix4 newScale(s, s, s)
        mv = mv * Matrix4 newRotateY(rotateY)
        // mv = mv * Matrix4 newRotateX(20.0f)

        draw(pass, mv)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        program use()
        vao bind()
        ibo bind()

        glUniformMatrix4fv(projLoc, 1, false, pass projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        glDrawElements(GL_TRIANGLES, 6 * 2 * 3 * 4, GL_UNSIGNED_SHORT, 0 as Pointer)

        vao detach()
        program detach()
    }

    rebuild: func {
        vertices = [
            -1.0, -1.0, -1.0, // v0
             1.0, -1.0, -1.0, // v1
             1.0,  1.0, -1.0, // v2
            -1.0,  1.0, -1.0, // v3

            -1.0, -1.0,  1.0, // v4
             1.0, -1.0,  1.0, // v5
             1.0,  1.0,  1.0, // v6
            -1.0,  1.0,  1.0  // v7
        ]

        vbo upload(vertices)

        indices := [
            // bottom
            0 as UInt, 1, 5,
            0, 5, 4,

            // right
            5, 6, 2,
            5, 2, 1,

            // back
            0, 1, 2,
            0, 2, 3,

            // left
            4, 0, 3,
            4, 3, 7,

            // top
            7, 3, 2,
            7, 2, 6,

            // front
            4, 5, 7,
            7, 5, 6
        ]
        ibo upload(indices)
    }

}

