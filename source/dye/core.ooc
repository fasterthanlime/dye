
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

    black: static func -> This { new(0, 0, 0) }
    white: static func -> This { new(255, 255, 255) }

}

DyeContext: class {

    screen: SdlSurface*
    clearColor := Color new(72, 60, 50)

    width, height: Int

    logger := static Log getLogger("dye")

    glDrawables := ArrayList<GlDrawable> new()

    init: func (=width, =height, title: String) {
	SDL init(SDL_INIT_EVERYTHING)

	SDL wmSetCaption(title, null)

	SDL glSetAttribute(SDL_GL_RED_SIZE, 5)
	SDL glSetAttribute(SDL_GL_GREEN_SIZE, 6)
	SDL glSetAttribute(SDL_GL_BLUE_SIZE, 5)
	SDL glSetAttribute(SDL_GL_DEPTH_SIZE, 16)
	SDL glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

	screen = SDL setMode(width, height, 0, SDL_OPENGL)

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
	glClearColor(clearColor R, clearColor G, clearColor B, 0.0)
    }

    initGL: func {
	logger info("OpenGL version: %s" format(glGetString (GL_VERSION)))
	logger info("OpenGL vendor: %s" format(glGetString (GL_VENDOR)))
	logger info("OpenGL renderer: %s" format(glGetString (GL_RENDERER)))

        setClearColor(clearColor)
	glDisable(GL_DEPTH_TEST)
	glEnable(GL_BLEND)
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
	glEnable(GL_TEXTURE_RECTANGLE_ARB)

	reshape()
    }

    reshape: func {
	glViewport(0, 0, width, height)
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

    add: func (d: GlDrawable) {
	glDrawables add(d)
    }

    remove: func (d: GlDrawable) {
	glDrawables remove(d)
    }

}

GlDrawable: abstract class {

    scale := vec2(1, 1)
    pos := vec2(0, 0)
    angle := 0.0

    // You can use OpenGL calls here
    render: func (dye: DyeContext) {
        glPushMatrix()

        glScalef(scale x, scale y, 1.0)
        glRotatef(angle, 0.0, 0.0, 1.0) 
        glTranslatef(pos x, pos y, 0.0)

        draw(dye)

        glPopMatrix()
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
            c draw(dye)
        }
    }

    add: func (d: GlDrawable) {
        children add(d)
    }

    remove: func (d: GlDrawable) {
        children remove(d)
    }

}

GlTriangle: class extends GlDrawable {

    draw: func (dye: DyeContext) {
	glBegin(GL_TRIANGLES)

	glColor3f(1.0, 0.0, 0.0)
	glVertex2f(0.0, 0.0)

	glColor3f(0.0, 1.0, 0.0)
	glVertex2f(dye width, 0.0)

	glColor3f(0.0, 0.0, 1.0)
	glVertex2f(0.0, dye height)

	glEnd()
    }

}

