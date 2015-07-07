
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

    add: func (vbo: VBO, name: String, size: Int, type: GLenum,
        normalized: Bool, stride: Int, pointer: Pointer) {

        add(VertexAttribFInfo new(program, vbo, name, size, type, normalized, stride, pointer))
    }

    addI: func (vbo: VBO, name: String, size: Int, type: GLenum,
        stride: Int, pointer: Pointer) {

        add(VertexAttribIInfo new(program, vbo, name, size, type, stride, pointer))
    }

    add: func ~vai (vai: VertexAttribInfo) {
        bind()
        vai bind()
    }

    detach: func {
        glBindVertexArray(0)
    }
}

VertexAttribInfo: abstract class {

    program: ShaderProgram
    vbo: VBO
    name: String
    id: UInt

    init: func (=program, =vbo, =name) {
        id = glGetAttribLocation(program id, name toCString())
        bind()
    }

    bind: func {
        vbo bind()
        glEnableVertexAttribArray(id)
    }

    detach: func {
        glDisableVertexAttribArray(id)
    }

}

/**
 * Where we store the data for a vertex attrib info.
 */
VertexAttribFInfo: class extends VertexAttribInfo {

    size: Int
    type: GLenum
    normalized: Bool
    stride: Int
    pointer: Pointer

    init: func (.program, .vbo, .name,
            =size, =type, =normalized, =stride, =pointer) {
        super(program, vbo, name)
    }

    bind: func {
        super()
        glVertexAttribPointer(id, size, type, normalized, stride, pointer)
    }

}

/**
 * Where we store the data for a vertex attrib info.
 */
VertexAttribIInfo: class extends VertexAttribInfo {

    size: Int
    type: GLenum
    stride: Int
    pointer: Pointer

    init: func (.program, .vbo, .name,
            =size, =type, =stride, =pointer) {
        super(program, vbo, name)
    }

    bind: func {
        super()
        glVertexAttribIPointerEXT(id, size, type, stride, pointer)
    }

}

