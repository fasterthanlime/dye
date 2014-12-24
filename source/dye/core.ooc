
// third-party stuff
use deadlogger
import deadlogger/[Log]

use sdl2
import sdl2/[Core, OpenGL]

// sdk stuff
import structs/ArrayList

// our stuff
use dye
import dye/[input, math, sprite]
import dye/gritty/[fbo, shader]

/**
 * A dye context - ie. a window bound to an OpenGL context,
 * with an associated Input, can has a custom cursor, a list of
 * scenes that can be swapped for one another
 */
DyeContext: class {

    window: SdlWindow
    context: SdlGlContext

    size: Vec2i
    windowSize: Vec2i

    width:  Int { get { size x } }
    height: Int { get { size y } }

    center: Vec2

    mainPass: Pass
    passes := ArrayList<Pass> new()
    windowPass: WindowPass

    input: SdlInput

    scenes := ArrayList<Scene> new()
    currentScene: Scene

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

        version (apple) {
            SDL glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
            SDL glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2)
            SDL glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
        }

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
            windowSize set!(x, y)
        )

        version ((windows || linux || apple) && !android) {
            // we use glew on Desktop
            glewExperimental = true
            glewValue := glewInit()
            if (glewValue != 0) {
                logger error("Failed to initialize glew!", glewValue)
                raise("glew failure")
            }
        }

        initGL()

        setScene(createScene())
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
            windowSize set!(x, y)
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

    poll: func {
        input _poll()
    }

    render: func {
        SDL glMakeCurrent(window, context)

        mainPass group = currentScene
        mainPass render()

        if (!passes empty?()) for (p in passes) {
            p render()
        }

        windowPass render()

        SDL glSwapWindow(window)
    }

    quit: func {
        SDL quit()
        // on Desktop, chances are SDL quit will exit the app.  on mobile,
        // exit(0) is apparently needed.  It can't hurt anyway.
        exit(0)
    }

    initGL: func {
        logger info("OpenGL version: %s" format(glGetString(GL_VERSION)))
        logger info("OpenGL vendor: %s" format(glGetString(GL_VENDOR)))
        logger info("OpenGL renderer: %s" format(glGetString(GL_RENDERER)))
        logger info("GLSL version: %s" format(glGetString(GL_SHADING_LANGUAGE_VERSION)))

        // enable vsync
        SDL glSetSwapInterval(1)

        // // disable vsync
        // SDL glSetSwapInterval(0)

        logger info("Size = %s, Window size = %s", size _, windowSize _)
        mainPass = TexturePass new(Fbo new(size))
        mainPass catchAll = true;
        mainPass clearColor set!(72, 60, 50) // taupe!
        windowPass = WindowPass new(this, mainPass fbo)
    }

    setClearColor: func (c: Color) {
        mainPass clearColor set!(c)
    }

    createScene: func -> Scene {
        Scene new(this)
    }

    setScene: func (scene: Scene) {
        if (currentScene) {
            currentScene input enabled = false
        }

        currentScene = scene
        currentScene input enabled = true
    }

    getScene: func -> Scene {
        currentScene
    }

    add: func (d: GlDrawable) {
        currentScene add(d)
    }

    remove: func (d: GlDrawable) {
        currentScene remove(d)
    }

    clear: func {
        currentScene clear()
    }

}

/**
 * Anything that can be drawn on a context
 */
GlDrawable: abstract class {

    // if null, will be rendered in the main pass
    pass: Pass = null

    // round to nearest pixel for transformation matrices
    round := static false
    // prefix to add to all asset requests
    prefix := static ""

    scale := vec2(1, 1)
    pos := vec2(0, 0)
    angle := 0.0f
    userObject: Object = null // anything you want o/

    visible := true

    // You can use OpenGL calls here
    render: func (pass: Pass, modelView: Matrix4) {
        if (!shouldDraw?(pass)) return

        draw(pass, computeModelView(modelView))
    }

    shouldDraw?: final func (pass: Pass) -> Bool {
        if (!visible) return false

        match (this pass) {
            case null =>
                // render if pass catches all
                pass catchAll
            case =>
                // render if same pass
                this pass == pass
        }
    }

    center!: func (pass: Pass, size: Vec2) {
        pos set!(pass width / 2 - size x / 2, pass height / 2 - size y / 2)
    }

    center!: func ~childCentered (pass: Pass) {
        pos set!(pass width / 2, pass height / 2)
    }

    draw: abstract func (pass: Pass, modelView: Matrix4)

    computeModelView: func (input: Matrix4) -> Matrix4 {
        modelView: Matrix4

        if (input) {
            modelView = input
        } else {
            modelView = Matrix4 newIdentity()
        }

        if (!pos zero?()) {
            modelView = modelView * Matrix4 newTranslate(pos x, pos y, 0.0)
        }

        if (angle != 0.0) {
            modelView = modelView * Matrix4 newRotateZ(angle toRadians())
        }

        if (!scale unit?()) {
            modelView = modelView * Matrix4 newScale(scale x, scale y, 1.0)
        }


        modelView
    }

    free: func {
        // muffin so far
    }

}

/**
 * A group of drawables, that has its own position, scale, and rotation
 */
GlGroup: class extends GlDrawable {

    init: func

    children := ArrayList<GlDrawable> new()

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

    add: func (d: GlDrawable) {
        children add(d)
    }

    remove: func (d: GlDrawable) {
        children remove(d)
    }

    clear: func {
        children clear()
    }

    clearHard: func {
        iter := children iterator()
        while (iter hasNext?()) {
            node := iter next()
            iter remove()
            node free()
        }
    }

}

/**
 * A group of drawables, sorted by y coordinate
 */
GlSortedGroup: class extends GlGroup {

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
GlSpriteLike: abstract class extends GlDrawable {

    color := Color white()
    program: ShaderProgram
    opacity := 1.0f
    effects: ArrayList<GlEffect> = null
    center := true

    init: func

    addEffect: func (e: GlEffect) {
        if (!effects) effects = ArrayList<GlEffect> new()
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
GlEffect: abstract class {

    // here you get a chance to set uniforms
    apply: abstract func (sprite: GlSpriteLike, pass: Pass, modelView: Matrix4)

}


/**
 * Regroups a graphic scene (GlGroup) and some event handling (Input)
 */
Scene: class extends GlGroup {

    dye: DyeContext
    input: Input

    size  : Vec2i { get { dye size } }
    center: Vec2  { get { dye center } }

    init: func (.dye) {
        init(dye, dye input sub())
        input enabled = false
    }

    init: func ~specific (=dye, =input) { }

    sub: func -> This {
        new(dye, input sub())
    }

}

Pass: abstract class {

    identity := static Matrix4 newIdentity()

    // clears before drawing?
    clears := true

    size: Vec2i
    projectionMatrix: Matrix4
    clearColor := Color new(0, 0, 0)
    clearAlpha := 0.0f
    group := GlGroup new()
    fbo: Fbo

    // passes catches all drawables?
    catchAll := false

    // convenience properties
    width:  Int { get { size x } }
    height: Int { get { size y } }

    init: func (=fbo) {
        // muffin!
    }

    _makeProjectionMatrix: func {
        projectionMatrix = Matrix4 newOrtho(0, size x, 0, size y, -1.0, 1.0)
    }

    render: abstract func

    doRender: func {
        if (clears) {
            glEnable(GL_SCISSOR_TEST)
            glScissor(0, 0, size x, size y)
            glClearColor(clearColor R, clearColor G, clearColor B, clearAlpha)
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
            glDisable(GL_SCISSOR_TEST)
        }

        glEnable(GL_BLEND)
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        group render(this, identity)

        glDisable(GL_BLEND)
    }


}

TexturePass: class extends Pass {

    init: func (.fbo) {
        super(fbo)
        size = vec2i(fbo size x, fbo size y)
        _makeProjectionMatrix()
    }

    resize: func (=size) -> Bool {
        resized := false

        _makeProjectionMatrix()
        // fbo too small? resize!
        if (fbo size x < size x || fbo size y < size y) {
            newFboSize := vec2i(_nextPo2(size x), _nextPo2(size y))
            fbo dispose()
            fbo = Fbo new(newFboSize)
            resized = true
        }

        // clear
        fbo bind()
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        fbo unbind()

        resized
    }

    _nextPo2: func (number: Int) -> Int {
        poftwo := 1
        while ((1 << poftwo) < number) {
            poftwo += 1
        }
        1 << poftwo
    }

    render: func {
        fbo bind()
        glViewport(0, 0, size x, size y)
        doRender()
        fbo unbind()
    }

}

WindowPass: class extends Pass {

    dye: DyeContext
    sprite: GlSprite
    targetSize := vec2(-1 , -1)
    targetOffset := vec2(0, 0)
    scale := 1.0

    init: func (=dye, .fbo) {
        super(fbo)
        size = vec2i(dye windowSize x, dye windowSize y)
        sprite = GlSprite new(fbo texture)
        sprite pass = this
        sprite center = false
        group add(sprite)
        _makeProjectionMatrix()
    }

    render: func {
        adjustSprite()
        glViewport(0, 0, dye windowSize x, dye windowSize y)
        doRender()
    }

    adjustSprite: func {
        ratio := fbo size ratio()
        targetRatio := dye windowSize ratio()
        windowSize := vec2(dye windowSize x, dye windowSize y)

        if (targetRatio < ratio) {
            // target thinner than window (pillarbox)
            targetSize x = windowSize y / ratio
            targetSize y = windowSize y
            sprite scale set!(targetRatio / ratio, 1.0f)

            targetOffset x = ((size y / targetRatio) - size x) * 0.5 * sprite scale x
            targetOffset y = 0.0f
        } else {
            // target wider than window (letterbox)
            targetSize x = windowSize x
            targetSize y = windowSize x * ratio
            sprite scale set!(1.0f, ratio / targetRatio)

            targetOffset x = 0.0f
            targetOffset y = ((size x * targetRatio) - size y) * 0.5 * sprite scale y
        }

        sprite pos set!(targetOffset x, targetOffset y)
    }

}

