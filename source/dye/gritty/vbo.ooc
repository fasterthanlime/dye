
// third-party stuff
import sdl2/[OpenGL]

VBO: abstract class {

    id: UInt
    target := GL_ARRAY_BUFFER // most common VBO type
    usage := GL_STATIC_DRAW

    init: func {
        glGenBuffers(1, id&)
        bind()
        gc_register_finalizer(this, finalize as Pointer, null, null, null)
    }

    finalize: func {
        glDeleteBuffers(1, id&)
    }

    bind: func {
        glBindBuffer(target, id)
    }

    detach: func {
        glBindBuffer(target, 0)
    }

    _data: func ~raw (numBytes: GLsizeiptr, data: Pointer) {
        bind()
        glBufferData(target, numBytes, data, usage)
    }

}

FloatVBO: class extends VBO {

    init: func {
        super()
    }

    upload: func ~array (array: Float[]) {
        upload(array length, array data)
    }

    upload: func ~pointer (numElements: Int, data: Float*) {
        numBytes := (numElements * Float size) as GLsizeiptr
        _data(numBytes, data)
    }

}

UShortVBO: class extends VBO {

    init: func {
        super()

        // UShortVBOs are usually used for indices
        target = GL_ELEMENT_ARRAY_BUFFER
    }

    upload: func ~array (array: Short[]) {
        upload(array length, array data)
    }

    upload: func ~pointer (numElements: Int, data: Short*) {
        numBytes := (numElements * Short size) as GLsizeiptr
        _data(numBytes, data)
    }

}

UIntVBO: class extends VBO {

    init: func {
        super()

        // UIntVBOs are usually used for indices
        target = GL_ELEMENT_ARRAY_BUFFER
    }

    upload: func ~array (array: Int[]) {
        upload(array length, array data)
    }

    upload: func ~pointer (numElements: Int, data: Int*) {
        numBytes := (numElements * Int size) as GLsizeiptr
        _data(numBytes, data)
    }

}

