
// our stuff
import dye/[math]

// third-party stuff
import sdl2/[OpenGL]

import io/[File, FileReader]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/HashMap

ShaderLoader: class {

    load: static func (vertexCode: String, fragmentCode: String) -> ShaderProgram {
        vertex := VertexShader new(vertexCode)
        fragment := FragmentShader new(fragmentCode)

        ShaderProgram new(vertex, fragment)
    }

}

Shader: class {

    code: String
    type: GLenum
    id: Int

    logger := static Log getLogger(This name)

    init: func (=code, =type) {
        id = glCreateShader(type)

        cCode := code toCString()
        glShaderSource(id, 1, cCode&, null)
        glCompileShader(id)

        status: Int
        glGetShaderiv(id, GL_COMPILE_STATUS, status&)

        if (status != GL_TRUE) {
            logCompileStatus()
        }
    }

    logCompileStatus: func {
        BUFFER_SIZE := 512
        buffer := gc_malloc(BUFFER_SIZE) as CString
        glGetShaderInfoLog(id, BUFFER_SIZE, null, buffer)

        message := buffer toString()
        logger error("Failed to compile shader: %s", message)
        ShaderException new(class, message) throw()
    }

}

FragmentShader: class extends Shader {

    init: func (code: String) {
        super(code, GL_FRAGMENT_SHADER)
    }

}

VertexShader: class extends Shader {

    init: func (code: String) {
        super(code, GL_VERTEX_SHADER)
    }

}

ShaderProgram: class {

    logger := static Log getLogger(This name)
    
    fragment: FragmentShader
    vertex: VertexShader

    id: Int

    init: func (=vertex, =fragment) {
        id = glCreateProgram()

        attach(vertex)
        attach(fragment)

        link()
        use()
    }

    attach: func (shader: Shader) {
        glAttachShader(id, shader id)
    }

    link: func {
        glLinkProgram(id)

        status: Int
        glGetProgramiv(id, GL_LINK_STATUS, status&)

        if (status != GL_TRUE) {
            logLinkStatus()
        }
    }

    logLinkStatus: func {
        BUFFER_SIZE := 512
        buffer := gc_malloc(BUFFER_SIZE) as CString
        glGetProgramInfoLog(id, BUFFER_SIZE, null, buffer)

        message := buffer toString()
        logger error("Failed to link program: %s", message)
        ShaderException new(class, message) throw()
    }

    use: func {
        glUseProgram(id)
    }

    detach: func {
        glUseProgram(0)
    }

    getUniformLocation: func (name: String) -> Int {
        glGetUniformLocation(id, name toCString())
    }

    // uniforms

    uniform: func ~vec2 (location: Int, v: Vec2) {
        glUniform2f(location, v x, v y)
    }

    uniform: func ~int (location: Int, i: Int) {
        glUniform1i(location, i)
    }

}

ShaderException: class extends Exception {

    init: func (origin: Class, message: String) {
        super(origin, message)
    }

}

