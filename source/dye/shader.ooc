
// our stuff
import dye/[math]

// third-party stuff
import sdl2/[OpenGL]

import io/[File, FileReader]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/[ArrayList, HashMap]

/**
 * An OpenGL shader (vertex or fragment)
 */
Shader: class {

    name: String
    code: String
    type: GLenum
    id: Int

    logger := static Log getLogger(This name)

    init: func (=code, =name, =type) {
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
        logger error("Failed to compile shader #{name}: #{message}.\nCode: \n\n#{code}")
        ShaderException new(message) throw()
    }

}

/**
 * An OpenGL vertex shader
 */
VertexShader: class extends Shader {

    init: func (.code, .name) {
        super(code, name, GL_VERTEX_SHADER)
    }

}

/**
 * An OpenGL fragment shader
 */
FragmentShader: class extends Shader {

    init: func (.code, .name) {
        super(code, name, GL_FRAGMENT_SHADER)
    }

}

/**
 * A Shader Program (usually with both Vertex & Fragment shaders attached)
 */
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
        ShaderException new(message) throw()
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

/**
 * Thrown mostly when a shader failed to compile
 */
ShaderException: class extends Exception {

    init: func (.message) {
        super(message)
    }

}

// Loading mechanism

ShaderPair: class {
    vert: String
    frag: String

    init: func (=vert, =frag)
}

builtinCache := static HashMap<String, ShaderPair> new()

/**
 * Shader loader with builtin fallback mechanism, adjustable search paths, etc.
 */
ShaderLoader: class {

    // search paths

    searchPaths := static ArrayList<String> new()

    addSearchPath: static func (path: String) -> VertexShader {
        searchPaths add(0, path)
    }

    // builtins

    addBuiltin: static func (name, vert, frag: String) {
        builtinCache put(name, ShaderPair new(vert, frag))
        Shader logger info("Registered built-in #{name}")
    }

    // program

    load: static func (name: String) -> ShaderProgram {
        vert := loadVertexShader(name)
        frag := loadFragmentShader(name)

        ShaderProgram new(vert, frag)
    }

    _readFileOrBuiltin: static func (name: String, ext: String) -> String {
        path := "#{name}.#{ext}"

        for (searchPath in searchPaths) {
            file := File new(searchPath, path)
            if (file exists?()) {
                Shader logger info("Loading shader from file #{file path}")
                return file read()
            }
        }

        // fall back to builtin

        pair := builtinCache get(name)
        if (pair) {
            Shader logger info("Using built-in shader #{name}")
            match ext {
                case "vert" =>
                    return pair vert
                case "frag" =>
                    return pair frag
                case =>
                    null
            }
        }

        null
    }

    // vertex shaders

    vertexShaderCache := static HashMap<String, VertexShader> new()

    loadVertexShader: static func (name: String) -> VertexShader {
        shader := vertexShaderCache get(name)
        if (!shader) {
            code := _readFileOrBuiltin(name, "vert")
            if (!code) {
                notFound!("Vertex", name)
            }
            shader = VertexShader new(code, name)
            vertexShaderCache put(name, shader)
        }
        shader
    }

    // fragment shaders

    fragmentShaderCache := static HashMap<String, FragmentShader> new()

    loadFragmentShader: static func (name: String) -> FragmentShader {
        shader := fragmentShaderCache get(name)
        if (!shader) {
            code := _readFileOrBuiltin(name, "frag")
            if (!code) {
                notFound!("Fragment", name)
            }
            shader = FragmentShader new(code, name)
            fragmentShaderCache put(name, shader)
        }
        shader
    }

    notFound!: static func (kind: String, name: String) {
        ShaderException new("#{kind} shader not found: #{name}. Search paths: \n#{searchPaths join("\n")}") throw()
    }

}

// Default search paths
ShaderLoader addSearchPath("assets/shaders")
ShaderLoader addSearchPath("shaders")

// Register dye's own built-ins

ShaderLoader addBuiltin("dye/solid_2d",
       slurp("../shaders/dye/solid_2d.vert"),
       slurp("../shaders/dye/solid_2d.frag")
)

ShaderLoader addBuiltin("dye/texture_2d",
       slurp("../shaders/dye/texture_2d.vert"),
       slurp("../shaders/dye/texture_2d.frag")
)

ShaderLoader addBuiltin("dye/solid_3d",
       slurp("../shaders/dye/solid_3d.vert"),
       slurp("../shaders/dye/solid_3d.frag")
)

