
// our stuff
import dye/gritty/[shader, versions]

// sdk stuff
import structs/[HashMap]

ShaderLibrary: class {

    cache := static HashMap<String, ShaderProgram> new()

    getSolidColor: static func -> ShaderProgram { 
        target := getTarget()

        match target {
            case ShaderVersion GLSL_100 =>
                getSolidColor100()
            case ShaderVersion GLSL_130 =>
                getSolidColor130()
            case ShaderVersion GLSL_150 =>
                getSolidColor150()
        }
    }

    getTexture: static func -> ShaderProgram { 
        target := getTarget()

        match target {
            case ShaderVersion GLSL_100 =>
                getTexture100()
            case ShaderVersion GLSL_130 =>
                getTexture130()
            case ShaderVersion GLSL_150 =>
                // FIXME: write a GLSL 1.5 shader for that
                getTexture130()
            case =>
                Exception new("No texture shader for your target yet!") throw()
                null
        }
    }

    getTarget: static func -> ShaderVersion {
        ver := OpenGLVersion get()

        if (ver es?() && ver eq(2, 0)) {
            return ShaderVersion GLSL_100
        }

        if (ver gte(3, 2)) {
            return ShaderVersion GLSL_150
        }

        ShaderVersion GLSL_130
    }

    getProgram: static func (name: String, vertex, fragment: String) -> ShaderProgram {
        if (cache contains?(name)) {
            return cache get(name)
        }

        program := ShaderLoader load(vertex, fragment)
        cache put(name, program)
        program
    }

    getSolidColor100: static func -> ShaderProgram {
        vertex := "
            #version 100

            uniform mat4 Projection;
            attribute vec2 position;

            void main()
            {
                gl_Position = Projection * vec4(position, 0.0, 1.0);
            }
        "

        fragment := "
            #version 100

            void main()
            {
                gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
            }
        "

        getProgram("solid100", vertex, fragment)
    }

    getSolidColor130: static func -> ShaderProgram {
        vertex := "
            #version 130

            uniform mat4 Projection;
            in vec2 position;

            void main()
            {
                gl_Position = Projection * vec4(position, 0.0, 1.0);
            }
        "

        fragment := "
            #version 130

            out vec4 outColor;

            void main()
            {
                outColor = vec4(1.0, 1.0, 1.0, 1.0);
            }
        "

        getProgram("solid130", vertex, fragment)
    }

    getSolidColor150: static func -> ShaderProgram {
        vertex := "
            #version 150

            uniform mat4 Projection;
            in vec2 position;

            void main()
            {
                gl_Position = Projection * vec4(position, 0.0, 1.0);
            }
        "

        fragment := "
            #version 150

            out vec4 outColor;

            void main()
            {
                outColor = vec4(1.0, 1.0, 1.0, 1.0);
            }
        "

        getProgram("solid150", vertex, fragment)
    }

    getTexture100: static func -> ShaderProgram {
        vertex := "
            #version 100

            uniform mat4 Projection;

            attribute vec2 Position;
            attribute vec2 TexCoordIn;
            varying vec2 TexCoordOut;

            void main()
            {
                TexCoordOut = TexCoordIn;
                gl_Position = Projection * vec4(Position, 0.0, 1.0);
            }
        "

        fragment := "
            #version 100

            uniform sampler2D Texture;
            varying mediump vec2 TexCoordOut;

            void main()
            {
                gl_FragColor = texture2D(Texture, TexCoordOut);
            }
        "

        getProgram("tex100", vertex, fragment)
    }

    getTexture130: static func -> ShaderProgram {
        vertex := "
            #version 130

            uniform mat4 Projection;

            in vec2 Position;
            in vec2 TexCoordIn;
            out vec2 TexCoordOut;

            void main()
            {
                TexCoordOut = TexCoordIn;
                gl_Position = Projection * vec4(Position, 0.0, 1.0);
            }
        "

        fragment := "
            #version 130

            uniform sampler2D Texture;

            in vec2 TexCoordOut;
            out vec4 OutColor;

            void main()
            {
                OutColor = texture2D(Texture, TexCoordOut);
            }
        "

        getProgram("tex130", vertex, fragment)
    }

}

