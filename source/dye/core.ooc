
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

    r, g, b: UInt8
    init: func (=r, =g, =b)

    toSDL: func (format: SdlPixelFormat*) -> UInt {
	SDL mapRgb(format, r, g, b)
    }

}

Dye: class {

    screen: SdlSurface*
    bgColor := Color new(72, 60, 50)

    width, height: Int

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
	    d draw(this)
	}
	end2D()
    }

    quit: func {
	SDL quit()
    }

    initGL: func {
	"OpenGL version: %s" printfln(glGetString (GL_VERSION))
	"OpenGL vendor: %s" printfln(glGetString (GL_VENDOR))
	"OpenGL renderer: %s" printfln(glGetString (GL_RENDERER))

	glClearColor(0.0, 0.0, 0.0, 0.0)
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

    // You can use OpenGL calls here
    draw: abstract func (dye: Dye)

}

GlGroup: class extends GlDrawable {

    children := ArrayList<GlDrawable> new()

    draw: func (dye: Dye) {
        drawChildren(dye)
    }
    
    drawChildren: func (dye: Dye) {
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

GlTransformGroup: class extends GlGroup {

    pos := vec3(0, 0, 0)
    angle := 0.0

    draw: func (dye: Dye) {
        glPushMatrix()

        glRotatef(angle, 0.0, 0.0, 1.0) 
        glTranslatef(pos x, pos y, pos z)

        drawChildren(dye)

        glPopMatrix()
    }

}

GlTriangle: class extends GlDrawable {

    draw: func (dye: Dye) {
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

