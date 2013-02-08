
// third-party stuff
import sdl2/[OpenGL]

import io/[File, FileReader]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/HashMap

ShaderLoader: class {

    _default: static ShaderProgram

    loadProgram: static func (vertexCode: String, fragmentCode: String) -> ShaderProgram {
        vertex := VertexShader new(vertexCode)
        fragment := FragmentShader new(fragmentCode)

        ShaderProgram new(vertex, fragment)
    }

    getDefaultProgram: func -> ShaderProgram {
        if (!_default) {
            _default = loadProgram(DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER)
        }

        _default
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

}

ShaderException: class extends Exception {

    init: func (origin: Class, message: String) {
        super(origin, message)
    }

}

// Default shaders follow:

DEFAULT_VERTEX_SHADER := "
#version 150

in vec2 position;

void main()
{
    gl_Position = vec4( position, 0.0, 1.0 );
}
"

DEFAULT_FRAGMENT_SHADER := "
#version 150

out vec4 outColor;

void main()
{
    outColor = vec4( 1.0, 1.0, 1.0, 1.0 );
}
"

