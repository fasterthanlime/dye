
// third-party stuff
import sdl2/[OpenGL]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import text/StringTokenizer
import structs/[List, ArrayList]

ShaderVersion: enum {
    GLSL_100
    GLSL_130
    GLSL_150

    toString: func -> String {
        match this {
            case This GLSL_100 => "100"
            case This GLSL_130 => "130"
            case This GLSL_150 => "150"
            case => "unknown"
        }
    }
}

OpenGLProfile: enum {
    DESKTOP
    ES
}

OpenGLVersion: class {

    string: String
    major, minor: Int
    profile: OpenGLProfile
    shader := ShaderVersion GLSL_100

    cached: static This
    logger := static Log getLogger(This name)

    ES_PREFIX := "OpenGL ES "

    init: func ~direct (=major, =minor, =profile) {
        logger info("Detected OpenGL version: " + toString()) 

        if (es?() && eq(2, 0)) {
            shader = ShaderVersion GLSL_100
        } else if (gte(3, 2)) {
            shader = ShaderVersion GLSL_150
        } else if (gte(3, 0)) {
            shader = ShaderVersion GLSL_130
        }
        logger info("Detected GLSL version: " + shader toString())
    }

    init: func ~fromString (ver: String) {
        // Android:
        // OpenGL ES 2.0 1403843

        // Linux, i965 (Mesa DRI)
        // 3.0 Mesa 8.0.5

        // Linux, nVidia driver
        // 4.2.0 NVIDIA 304.64

        // Windows, nVidia
        // 4.2.0

        // Virtualbox, Ubuntu 12.04
        // 2.1 Chromium 1.9

        profile := OpenGLProfile DESKTOP
        //logger debug("ver string = %s", ver)

        if (ver startsWith?(ES_PREFIX)) {
            profile = OpenGLProfile ES
            ver = ver[ES_PREFIX size..-1]
            //logger debug("got ES, now = %s", ver)
        }

        numberString := ver split(" ")[0]
        //logger debug("numberString = %s", numberString)

        numbers := numberString split(".") map(|x| x toInt())
        //logger debug("elements in numbers = %d", numbers size)

        (major, minor) := (numbers[0], numbers[1])

        init(major, minor, profile)
    }

    get: static func -> This {
        if (cached) {
            return cached
        }

        // there are separate functions to get numbers for
        // the major and minor versions, but those are only
        // for OpenGL 3.0+ so.. no luck here.
        ver: CString = glGetString(GL_VERSION)
        if (!ver) {
            logger error("Got null version, the GL context is probably garbage.")
            raise("opengl version detection problem")
        }

        cached = This new(ver toString())
        cached
    }

    es?: func -> Bool {
        profile == OpenGLProfile ES
    }

    eq: func (maj, min: Int) -> Bool {
        major == maj && min == min
    }

    lt: func (maj, min: Int) -> Bool {
        if (major == maj) {
            return minor < min
        }

        major < maj
    }

    gte: func (maj, min: Int) -> Bool {
        if (major == maj) {
            return minor >= min
        }

        major >= maj
    }

    toString: func -> String {
        "%s %d.%d" format(match profile {
            case OpenGLProfile ES =>
                "OpenGL ES"  
            case =>
                "OpenGL"  
        }, major, minor)
    }

}

