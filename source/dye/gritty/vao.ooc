
// our stuff
import dye/gritty/[shader]

// third-party stuff
import sdl2/[OpenGL]

// sdk stuff
import structs/[ArrayList]

//VAO: class {
//
//    id: Int
//
//    init: func {
//        glGenVertexArrays(1, id&)
//        bind()
//    }
//
//    bind: func {
//        glBindVertexArray(id)
//    }
//
//}

FakeVAO: class {

    vertexAttribs := ArrayList<VertexAttribInfo> new()

    init: func {

    }

    add: func (vai: VertexAttribInfo) {
        vertexAttribs add(vai)
    }

    use: func {
        for (vai in vertexAttribs) {
            vai use()
        }
    }

    detach: func {
        for (vai in vertexAttribs) {
            vai detach()
        }
    }

}

VertexAttribInfo: class {

    program: ShaderProgram
    name: String
    id: Int
    numComponents: Int
    type: GLenum
    normalized: Bool
    stride: Int
    pointer: Pointer

    init: func (=program, =name, =numComponents, =type, =normalized, =stride, =pointer) {
        id = glGetAttribLocation(program id, name toCString())
        use()
    }

    use: func {
        /*
        "VAI: name %s, id %d, and numComponents %d, type %d, norm %d, stride %d, pointer %p" printfln(
            name, id, numComponents, type as Int, normalized, stride, pointer)
        */

        glEnableVertexAttribArray(id)
        glVertexAttribPointer(id, numComponents, type, normalized, stride, pointer)
    }

    detach: func {
        glDisableVertexAttribArray(id)
    }

}

