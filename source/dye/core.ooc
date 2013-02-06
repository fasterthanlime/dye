
use deadlogger
import deadlogger/[Log]

use sdl2
import sdl2/[Core, OpenGL]

import structs/ArrayList

use dye
import dye/[input, math, fbo, sprite]

Color: class {

    /* r, g, b = [0, 255] UInt8 */
    r, g, b: UInt8
    init: func (=r, =g, =b)

    toSDL: func (format: SdlPixelFormat*) -> UInt {
	SDL mapRgb(format, r, g, b)
    }

    /* R, G, B = [0.0, 1.0] Float */
    R: Float { get { r / 255.0 } }
    G: Float { get { g / 255.0 } }
    B: Float { get { b / 255.0 } }

    set!: func (c: This) {
        r = c r
        g = c g
        b = c b
    }

    set!: func ~floats (r, g, b: Float) {
        this r = r
        this g = g
        this b = b
    }

    black: static func -> This { new(0, 0, 0) }
    white: static func -> This { new(255, 255, 255) }
    red: static func -> This { new(255, 0, 0) }
    green: static func -> This { new(0, 255, 0) }
    blue: static func -> This { new(0, 0, 255) }

    toString: func -> String {
        "(%d, %d, %d)" format(r, g, b)
    }

    _: String { get { toString() } }

    lighten: func (factor: Float) -> This {
        new(r as Float / factor, g as Float / factor, b as Float / factor)
    }

    mul: func (factor: Float) -> This {
        new(r * factor, g * factor, b * factor)
    }

}

DyeContext: class {

    window: SdlWindow
    context: SdlGlContext
    clearColor := Color new(72, 60, 50)

    size: Vec2i
    windowSize: Vec2i

    width:  Int { get { size x } }
    height: Int { get { size y } }

    center: Vec2

    logger := static Log getLogger("dye")
    fbo: Fbo

    input: SdlInput

    scenes := ArrayList<Scene> new()
    currentScene: Scene

    // cursor sprite to use instead of the real mouse cursor
    cursorSprite: GlGridSprite
    cursorOffset := vec2(0, 0)
    cursorNumStates := 0

    init: func (width, height: Int, title: String, fullscreen := false,
            windowWidth := -1, windowHeight := -1) {
        size = vec2i(width, height)

        center = vec2(width / 2, height / 2)

	SDL init(SDL_INIT_EVERYTHING)

        version (apple) {
            SDL glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2)
            SDL glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1)
            SDL glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
        }

	SDL glSetAttribute(SDL_GL_RED_SIZE, 5)
	SDL glSetAttribute(SDL_GL_GREEN_SIZE, 6)
	SDL glSetAttribute(SDL_GL_BLUE_SIZE, 5)
	SDL glSetAttribute(SDL_GL_DEPTH_SIZE, 16)
	SDL glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

        input = SdlInput new(this)

        flags := SDL_WINDOW_OPENGL
        if (fullscreen) {
            version (apple) {
                flags |= SDL_WINDOW_FULLSCREEN
            }
            
            version (!apple) {
                flags |= SDL_WINDOW_BORDERLESS
                flags |= SDL_WINDOW_MAXIMIZED
            }

            rect: SdlRect
            SDL getDisplayBounds(0, rect&)
            windowSize = vec2i(rect w, rect h)
        } else {
            windowSize = vec2i(size x, size y)

            if (windowWidth  != -1) windowSize x = windowWidth
            if (windowHeight != -1) windowSize y = windowHeight
        }

	window = SDL createWindow(title,
            SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
            windowSize x, windowSize y, flags)
        context = SDL glCreateContext(window) 
        SDL glMakeCurrent(window, context)

        input onWindowSizeChange(|x, y|
            windowSize set!(x, y)
        )

	initGL()

        setScene(createScene())
    }

    setShowCursor: func (visible: Bool) {
        SDL showCursor(visible)
    }

    setCursorOffset: func (v: Vec2) {
        cursorOffset set!(v)
    }

    setCursorSprite: func (path: String, numStates: Int) {
        SDL setRelativeMouseMode(true)

        cursorSprite = GlGridSprite new(path, numStates, 1)
        cursorNumStates = numStates
        setShowCursor(false)
    }

    setCursorState: func (state: Int) {
        if (!cursorSprite) { return }

        if (state >= 0 && state < cursorNumStates) {
           cursorSprite x = state
        }
    }

    poll: func {
        input _poll()
    }

    render: func {
        SDL glMakeCurrent(window, context)

        fbo bind()
        glViewport(0, 0, size x, size y)
	glClearColor(clearColor R, clearColor G, clearColor B, 1.0)
	glClear(GL_COLOR_BUFFER_BIT)
	draw()
        fbo unbind()

        glViewport(0, 0, windowSize x, windowSize y)
        fbo render()

	SDL glSwapWindow(window)
    }

    draw: func {
	begin2D(size)
        currentScene render(this)
        renderCursor()
	end2D()
    }

    renderCursor: func {
        if (!cursorSprite) { return }

        cursorSprite pos set!(input getMousePos() add(cursorOffset))
        cursorSprite render(this)
    }

    quit: func {
	SDL quit()
    }

    setClearColor: func (c: Color) {
        clearColor set!(c)
    }

    initGL: func {
	logger info("OpenGL version: %s" format(glGetString (GL_VERSION)))
	logger info("OpenGL vendor: %s" format(glGetString (GL_VENDOR)))
	logger info("OpenGL renderer: %s" format(glGetString (GL_RENDERER)))

        setClearColor(clearColor)
        fbo = Fbo new(this, size x, size y)
    }

    begin2D: func (canvasSize: Vec2i) {
        //(left, right, bottom, top) := (0, canvasSize x, 0, canvasSize y)
        //(near, far) := (-1, 1)
	//glOrtho(left, right, bottom, top, near, far)
    }

    end2D: func {
	glEnable(GL_DEPTH_TEST)
	glDisable(GL_BLEND)
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

GlDrawable: abstract class {

    scale := vec2(1, 1)
    pos := vec2(0, 0)
    angle := 0.0

    visible := true

    // You can use OpenGL calls here
    render: func (dye: DyeContext) {
        if (!visible) return

        // FIXME: transformations
        // glPushMatrix()

        // glTranslatef(pos x, pos y, 0.0)
        // glRotatef(angle, 0.0, 0.0, 1.0) 
        // glScalef(scale x, scale y, 1.0)

        draw(dye)

        // FIXME: transformations
        // glPopMatrix()
    }

    center!: func (dye: DyeContext, size: Vec2) {
        pos set!(dye width / 2 - size x / 2, dye height / 2 - size y / 2)
    }

    center!: func ~childCentered (dye: DyeContext) {
        pos set!(dye width / 2, dye height / 2)
    }

    draw: abstract func (dye: DyeContext)

}

GlGroup: class extends GlDrawable {

    children := ArrayList<GlDrawable> new()

    draw: func (dye: DyeContext) {
        drawChildren(dye)
    }
    
    drawChildren: func (dye: DyeContext) {
        for (c in children) {
            c render(dye)
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

