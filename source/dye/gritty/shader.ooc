
// our stuff
import dye/gritty/vao

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

    getDefaultProgram: static func -> ShaderProgram {
        if (!_default) {
            version (android) {
                // TODO: detect by glGetString instead!
                _default = loadProgram(DEFAULT_VERTEX_SHADER_100, DEFAULT_FRAGMENT_SHADER_100)
            }
            
            version (!android) {
                version (apple) {
                    // TODO: detect by glGetString instead!
                    _default = loadProgram(DEFAULT_VERTEX_SHADER_150, DEFAULT_FRAGMENT_SHADER_150)
                }
                version (!apple) {
                    _default = loadProgram(DEFAULT_VERTEX_SHADER_130, DEFAULT_FRAGMENT_SHADER_130)
                }
            }
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

    vao: VAO

    init: func (=vertex, =fragment) {
        id = glCreateProgram()
        vao = VAO new()

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

    vertexAttribPointer: func (name: String, numComponents: Int, type: GLenum,
        normalized: Bool, stride: Int, pointer: Pointer) {

        vao add(VertexAttribInfo new(this, name, numComponents, type, normalized, stride, pointer))
    }

    use: func {
        glUseProgram(id)
        vao bind()
    }

    detach: func {
        vao detach()
        glUseProgram(0)
    }

}

ShaderException: class extends Exception {

    init: func (origin: Class, message: String) {
        super(origin, message)
    }

}

// Default shaders follow:

DEFAULT_VERTEX_SHADER_100 := "
#version 100

attribute vec2 position;

void main()
{
    gl_Position = vec4( position, 0.0, 1.0 );
}
"

DEFAULT_FRAGMENT_SHADER_100 := "
#version 100

void main()
{
    gl_FragColor = vec4( 0.0, 1.0, 0.0, 1.0 );
}
"


DEFAULT_VERTEX_SHADER_130 := "
#version 130

in vec2 position;

void main()
{
    gl_Position = vec4( position, 0.0, 1.0 );
}
"

DEFAULT_FRAGMENT_SHADER_130 := "
#version 130

out vec4 outColor;

void main()
{
    outColor = vec4( 0.0, 1.0, 0.0, 1.0 );
}
"

DEFAULT_VERTEX_SHADER_150 := "
#version 150

in vec2 position;

void main()
{
    gl_Position = vec4( position, 0.0, 1.0 );
}
"

DEFAULT_FRAGMENT_SHADER_150 := "
#version 150

out vec4 outColor;

void main()
{
    outColor = vec4( 0.0, 1.0, 0.0, 1.0 );
}
"

