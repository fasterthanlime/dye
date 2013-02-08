
// third-party stuff
import sdl2/[OpenGL]

VBO: class {

    id: Int

    init: func {
        glGenBuffers(1, id&)
        bind()
    }
    
    bind: func {
        glBindBuffer(GL_ARRAY_BUFFER, id)
    }

    detach: func {
        glBindBuffer(GL_ARRAY_BUFFER, 0)
    }

}

FloatVBO: class extends VBO {

    init: func {
        super()
    }

    data: func ~array (array: Float[], type := GL_STATIC_DRAW) {
        data(array length, array data, type)
    }

    data: func ~pointer (numElements: Int, data: Float*, type := GL_STATIC_DRAW) {
        numBytes := (numElements * Float size)
        "Passing glBufferData with GL_ARRAY_BUFFER, %d bytes, data at %p and a GL_STATIC_DRAW type" printfln(
            numBytes, data)
            
        glBufferData(GL_ARRAY_BUFFER, numBytes as GLsizeiptr, data, type)
    }

}

