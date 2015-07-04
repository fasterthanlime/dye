
// our stuff
import dye/[shader]
import vbo

// third-party stuff
import sdl2/[OpenGL]

// sdk stuff
import structs/[ArrayList]

/**
 * OpenGL 3.0+ wrapper around Vertex Attribute Objects (bind together
 * VBOs, EBOs, attributes, etc.)
 */
VAO: class {

    program: ShaderProgram
    id: UInt

    init: func (=program) {
        glGenVertexArrays(1, id&)
        bind()
        gc_register_finalizer(this, finalize as Pointer, null, null, null)
    }

    finalize: func {
        glDeleteVertexArrays(1, id&)
    }

    bind: func {
        glBindVertexArray(id)
    }

    add: func (vbo: VBO, name: String, numComponents: Int, type: GLenum,
        normalized: Bool, stride: Int, pointer: Pointer) {

        add(VertexAttribInfo new(program, vbo, name, numComponents, type, normalized, stride, pointer))
    }

    add: func ~vai (vai: VertexAttribInfo) {
        bind()
        vai bind()
    }

    detach: func {
        glBindVertexArray(0)
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
    id: UInt
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

