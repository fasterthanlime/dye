
use deadlogger
import deadlogger/[Log]

use sdl
import sdl/Core

use glew
import glew

use glu
import glu

import structs/ArrayList

use dye
import dye/math

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

}

DyeContext: class {

    screen: SdlSurface*
    clearColor := Color new(72, 60, 50)

    size: Vec2i

    width:  Int { get { size x } }
    height: Int { get { size y } }

    center: Vec2

    logger := static Log getLogger("dye")

    glDrawables := ArrayList<GlDrawable> new()

    init: func (width, height: Int, title: String, fullscreen := false) {
        size = vec2i(width, height)
        center = vec2(width / 2, height / 2)

	SDL init(SDL_INIT_EVERYTHING)

	SDL wmSetCaption(title, null)

	SDL glSetAttribute(SDL_GL_RED_SIZE, 5)
	SDL glSetAttribute(SDL_GL_GREEN_SIZE, 6)
	SDL glSetAttribute(SDL_GL_BLUE_SIZE, 5)
	SDL glSetAttribute(SDL_GL_DEPTH_SIZE, 16)
	SDL glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

        flags := SDL_OPENGL
        if (fullscreen) {
            flags |= SDL_FULLSCREEN
        }

	screen = SDL setMode(width, height, 0, flags)

	initGL()
    }

    setShowCursor: func (visible: Bool) {
        SDL showCursor(visible)
    }

    render: func {
	glClear(GL_COLOR_BUFFER_BIT)
	draw()
	SDL glSwapBuffers()
    }

    draw: func {
	begin2D()
	for (d in glDrawables) {
	    d render(this)
	}
	end2D()
    }

    quit: func {
	SDL quit()
    }

    setClearColor: func (c: Color) {
        clearColor set!(c)
	glClearColor(clearColor R, clearColor G, clearColor B, 1.0)
    }

    initGL: func {
	logger info("OpenGL version: %s" format(glGetString (GL_VERSION)))
	logger info("OpenGL vendor: %s" format(glGetString (GL_VENDOR)))
	logger info("OpenGL renderer: %s" format(glGetString (GL_RENDERER)))

        setClearColor(clearColor)
	glDisable(GL_DEPTH_TEST)
	glEnable(GL_BLEND)
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

	reshape()
    }

    reshape: func {
	glViewport(0, 0, size x, size y)
    }

    begin2D: func {
	glDisable(GL_DEPTH_TEST)
	glEnable(GL_BLEND)
	glMatrixMode(GL_PROJECTION)
	glPushMatrix()
	glLoadIdentity()

	gluOrtho2D(0, width, height, 0)
	glMatrixMode(GL_MODELVIEW)
	glPushMatrix()
	glLoadIdentity()
    }

    end2D: func {
	glMatrixMode(GL_PROJECTION)
	glPopMatrix()
	glMatrixMode(GL_MODELVIEW)
	glPopMatrix()

	glEnable(GL_DEPTH_TEST)
	glDisable(GL_BLEND)
    }

    color: func (color: Color) {
        glColor4f(color R, color G, color B, 1.0)
    }

    texCoord: func (v: Vec2) {
        glTexCoord2f(v x, v y)
    }

    vertex: func (v: Vec2) {
        glVertex2f(v x, v y)
    }

    pushMatrix: func (f: Func) {
        glPushMatrix()
        f()
        glPopMatrix()
    }

    begin: func (type: GLenum, f: Func) {
        glBegin(type)
        f()
        glEnd()
    }

    withTexture: func (textureType: GLenum, textureID: GLuint, f: Func) {
	glEnable(textureType)
        glBindTexture(textureType, textureID)
        f()
        glBindTexture(textureType, 0) // unbind it for later draw operations
	glDisable(textureType)
    }

    add: func (d: GlDrawable) {
	glDrawables add(d)
    }

    remove: func (d: GlDrawable) {
	glDrawables remove(d)
    }

    clear: func {
        glDrawables clear()
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

        glPushMatrix()

        glTranslatef(pos x, pos y, 0.0)
        glRotatef(angle, 0.0, 0.0, 1.0) 
        glScalef(scale x, scale y, 1.0)

        draw(dye)

        glPopMatrix()
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

