
// our stuff
import dye/gritty/[shader, vbo, versions]

// third-party stuff
import sdl2/[OpenGL]

// sdk stuff
import structs/[ArrayList]

/**
 * Common class for vertex array object functionality
 */
VAO: abstract class {

    program: ShaderProgram

    new: static func (program: ShaderProgram) -> This {
        version (!android) {
            ver := OpenGLVersion get()
            if (ver gte(3, 0)) {
                return HardVAO new(program)
            }
        }

        return SoftVAO new(program)
    }

    add: func ~friendly (vbo: VBO, name: String, numComponents: Int, type: GLenum,
        normalized: Bool, stride: Int, pointer: Pointer) {

        add(VertexAttribInfo new(program, vbo, name, numComponents, type, normalized, stride, pointer))
    }

    add: abstract func (vai: VertexAttribInfo)
    bind: abstract func
    detach: abstract func
    delete: abstract func

}

version (!android) {
    /**
     * This is VAO code that uses the built-in functionality
     * in OpenGL 3.0+
     */
    HardVAO: class extends VAO {

        id: Int

        init: func (=program) {
            glGenVertexArrays(1, id&)
            bind()
        }

        bind: func {
            glBindVertexArray(id)
        }

        add: func (vai: VertexAttribInfo) {
            bind()
            vai bind()
        }

        detach: func {
            glBindVertexArray(0)
        }

        delete: func {
            glDeleteVertexArrays(1, id&)
        }

    }
}

/**
 * This class is used for pre-3.0 OpenGL platforms,
 * such as OpenGL ES 2.0, where we can't use VAOs and
 * have to remember the vertex attribs instead.
 *
 * Note that since OpenGL 3.2, VAOs are mandatory, so
 * this class will not work at all.
 */
SoftVAO: class extends VAO {

    vertexAttribs := ArrayList<VertexAttribInfo> new()

    init: func (=program)

    add: func (vai: VertexAttribInfo) {
        vertexAttribs add(vai)
    }

    bind: func {
        for (vai in vertexAttribs) {
            vai bind()
        }
    }

    detach: func {
        for (vai in vertexAttribs) {
            vai detach()
        }
    }

    delete: func {
        vertexAttribs clear()
    }

}

/**
 * Where we store the data for a vertex attrib info.
 *
 * If using SoftVAO, it'll be used each time it's bound.
 * If using HardVAO, it'll be used only once, at creation.
 */
VertexAttribInfo: class {

    program: ShaderProgram
    vbo: VBO

    name: String
    id: Int
    numComponents: Int
    type: GLenum
    normalized: Bool
    stride: Int
    pointer: Pointer

    init: func (=program, =vbo, =name, =numComponents, =type, =normalized, =stride, =pointer) {
        id = glGetAttribLocation(program id, name toCString())
        bind()
    }

    bind: func {
        vbo bind()
        glEnableVertexAttribArray(id)
        glVertexAttribPointer(id, numComponents, type, normalized, stride, pointer)
    }

    detach: func {
        glDisableVertexAttribArray(id)
    }

}

