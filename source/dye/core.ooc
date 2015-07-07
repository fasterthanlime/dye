
// third-party stuff
use deadlogger
import deadlogger/[Log]

use sdl2
import sdl2/[Core, OpenGL]

// sdk stuff
import structs/ArrayList

// our stuff
use dye
import dye/[input, math, sprite, fbo, shader, pass]

/**
 * A dye context - ie. a window bound to an OpenGL context,
 * with an associated Input, can have a custom cursor, a list of
 * scenes that can be swapped for one another
 */
Context: class {

    window: SdlWindow
    context: SdlGlContext

    size: Vec2i
    windowSize: Vec2i

    width:  Int { get { size x } }
    height: Int { get { size y } }

    center: Vec2

    mainPass: Pass
    windowPass: WindowPass

    input: SdlInput

    fullscreen := false

    logger := static Log getLogger(This name)

    init: func (width, height: Int, title: String, fullscreen := false,
            windowWidth := -1, windowHeight := -1) {

        size = vec2i(width, height)
        if (windowWidth == -1)  windowWidth  = size x
        if (windowHeight == -1) windowHeight = size y

        center = vec2(width / 2, height / 2)

        SDL init(SDL_INIT_EVERYTHING)

        ver: SdlVersion
        SDL getCompiledVersion(ver&)
        logger info("Compiled against SDL v#{ver major}.#{ver minor}.#{ver patch}")

        SDL getLinkedVersion(ver&)
        logger info("Linked against SDL v#{ver major}.#{ver minor}.#{ver patch}")

        SDL glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
        SDL glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2)
        SDL glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)

        SDL glSetAttribute(SDL_GL_RED_SIZE, 5)
        SDL glSetAttribute(SDL_GL_GREEN_SIZE, 6)
        SDL glSetAttribute(SDL_GL_BLUE_SIZE, 5)
        SDL glSetAttribute(SDL_GL_DEPTH_SIZE, 16)
        SDL glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

        flags := SDL_WINDOW_OPENGL
        flags |= SDL_WINDOW_RESIZABLE
        this fullscreen = fullscreen
        if (fullscreen) {
            flags |= SDL_WINDOW_FULLSCREEN_DESKTOP

            rect: SdlRect
            SDL getDisplayBounds(0, rect&)
            windowSize = vec2i(rect w, rect h)
        } else {
            windowSize = vec2i(windowWidth, windowHeight)
        }

        window = SDL createWindow(
                    title,
                    SDL_WINDOWPOS_CENTERED,
                    SDL_WINDOWPOS_CENTERED,
                    windowSize x,
                    windowSize y,
                    flags
                )
        if (!window) {
            logger error("Couldn't create SDL window: %s" format(SDL getError()))
            raise("sdl failure")
        }

        context = SDL glCreateContext(window)
        if (!context) {
            logger error("Couldn't initialize OpenGL Context: %s" format(SDL getError()))
            raise("opengl initialization failure")
        }

        makeCurrentStatus := SDL glMakeCurrent(window, context)
        if (makeCurrentStatus != 0) {
            logger error("Invalid OpenGL context created: %s" format(SDL getError()))
            raise("opengl context failure")
        }

        input = SdlInput new(this)
        input onWindowSizeChange(|x, y|
            windowSize = vec2i(x, y)
        )

        initGL()
    }

    hideWindow: func {
        SDL hideWindow(window)
    }

    showWindow: func {
        SDL showWindow(window)
    }

    minimizeWindow: func {
        SDL minimizeWindow(window)
    }

    maximizeWindow: func {
        SDL maximizeWindow(window)
    }

    setFullscreen: func (=fullscreen) {
        SDL setWindowFullscreen(window, fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0)

        if (fullscreen) {
            x, y: Int
            SDL getWindowSize(window, x&, y&)
            windowSize = (x, y) as Vec2i
            setShowCursor(false)
        } else {
            SDL setWindowSize(window, size x, size y)
            setShowCursor(true)
        }
    }

    setTitle: func (title: String) {
        SDL setWindowTitle(window, title)
    }

    setWindowPosition: func (x, y: Int) {
        SDL setWindowPosition(window, x, y)
    }

    setIcon: func (path: String) {
        surface := SDL loadBMP(path)
        SDL setWindowIcon(window, surface)
    }

    setShowCursor: func (visible: Bool) {
        SDL showCursor(visible)
    }

    setRelativeMouse: func (enabled: Bool) {
        SDL setRelativeMouseMode(enabled)
    }

    /**
     * Poll the input devices
     */
    poll: func {
        input _poll()
    }

    render: func {
        SDL glMakeCurrent(window, context)

        mainPass render()
        windowPass render()

        SDL glSwapWindow(window)
    }

    quit: func {
        SDL quit()
    }

    initGL: func {
        // we use glew on Desktop
        glewExperimental = true
        glewValue := glewInit()
        if (glewValue != 0) {
            logger error("Failed to initialize glew!", glewValue)
            raise("glew failure")
        }

        logger info("OpenGL version: %s" format(glGetString(GL_VERSION)))
        logger info("OpenGL vendor: %s" format(glGetString(GL_VENDOR)))
        logger info("OpenGL renderer: %s" format(glGetString(GL_RENDERER)))
        logger info("GLSL version: %s" format(glGetString(GL_SHADING_LANGUAGE_VERSION)))

        maxSize: Int
        glGetIntegerv(GL_MAX_TEXTURE_SIZE, maxSize&)
        logger info("Max texture size: %dx%d" format(maxSize, maxSize));

        // enable vsync
        SDL glSetSwapInterval(1)

        // // disable vsync
        // SDL glSetSwapInterval(0)

        logger info("Size = %s, Window size = %s", size _, windowSize _)
        mainPass = TexturePass new(size)
        mainPass clearColor set!(72, 60, 50) // taupe!
        windowPass = WindowPass new(this, mainPass fbo)
    }

    setClearColor: func (r, g, b: Int) {
        mainPass clearColor set!(r, g, b)
    }

    setClearColor: func ~color (c: Color) {
        mainPass clearColor set!(c)
    }

    add: func (d: Drawable) {
        mainPass group add(d)
    }

    remove: func (d: Drawable) {
        mainPass group remove(d)
    }

    clear: func {
        mainPass group clear()
    }

}

/**
 * Anything that can be drawn on a context
 */
Drawable: abstract class {

    // round to nearest pixel for transformation matrices
    round := static false

    // transformations
    scale := vec2(1, 1)
    pos := vec2(0, 0)
    angle := 0.0f

    visible := true

    // Override to add additional transformations
    render: func (pass: Pass, modelView: Matrix4) {
        if (!visible) return

        mv := computeModelView(modelView)

        draw(pass, mv)
    }

    // Right place to bind / set up uniforms / use programs / draw whatever you need
    draw: abstract func (pass: Pass, modelView: Matrix4)

    /**
     * Recompute modelView matrix
     */
    computeModelView: func (input: Matrix4) -> Matrix4 {
        modelView: Matrix4

        if (input) {
            modelView = input
        } else {
            modelView = Matrix4 newIdentity()
        }

        if (pos x != 0.0 || pos y != 0.0) {
            modelView = modelView * Matrix4 newTranslate(pos x, pos y, 0.0)
        }

        if (angle != 0.0) {
            modelView = modelView * Matrix4 newRotateZ(angle toRadians())
        }

        if (scale x != 1.0 || scale y != 1.0) {
            modelView = modelView * Matrix4 newScale(scale x, scale y, 1.0)
        }

        modelView
    }

}

/**
 * A group of drawables, that has its own position, scale, and rotation
 */
Group: class extends Drawable {

    init: func

    children := ArrayList<Drawable> new()

    render: func (pass: Pass, modelView: Matrix4) {
        if (!visible) return

        draw(pass, computeModelView(modelView))
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        drawChildren(pass, modelView)
    }

    drawChildren: func (pass: Pass, modelView: Matrix4) {
        for (c in children) {
            c render(pass, modelView)
        }
    }

    add: func (d: Drawable) {
        children add(d)
    }

    remove: func (d: Drawable) {
        children remove(d)
    }

    clear: func {
        children clear()
    }

}

/**
 * A group of drawables, sorted by y coordinate
 */
SortedGroup: class extends Group {

    init: func {
        super()
    }

    drawChildren: func (pass: Pass, modelView: Matrix4) {
        children sort(|a, b| a pos y < b pos y)
        super(pass, modelView)
    }

}

/**
 * Base class for all things sprite - has a color
 * and an opacity so we can tint and make them transparent.
 */
SpriteLike: abstract class extends Drawable {

    color := Color white()
    program: ShaderProgram
    opacity := 1.0f
    effects: ArrayList<Effect> = null
    center := true

    init: func

    addEffect: func (e: Effect) {
        if (!effects) effects = ArrayList<Effect> new()
        effects add(e)
    }

    applyEffects: func (pass: Pass, modelView: Matrix4) {
        if (!effects) return
        for (e in effects) {
            e apply(this, pass, modelView)
        }
    }

    setProgram: func (=program)

}

/**
 * Create your own effects and stuff
 */
Effect: abstract class {

    // here you get a chance to set uniforms
    apply: abstract func (sprite: SpriteLike, pass: Pass, modelView: Matrix4)

}

