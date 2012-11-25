
use sdl
import sdl/Core

use cairo
import cairo/Cairo

use glew
import glew

use glu
import glu

import structs/ArrayList

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
    }

    render: func {
	draw()

	glClear(GL_COLOR_BUFFER_BIT)
	SDL glSwapBuffers()
    }

    draw: func {
	for (d in glDrawables) {
	    d draw(this)
	}
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

}

GlDrawable: abstract class {

    // You can use OpenGL calls here
    draw: abstract func (dye: Dye)

}

CairoDrawable: abstract class {

    // You can use any Cairo calls here
    draw: abstract func (dye: Dye, cr: CairoContext)

}

CairoRenderTarget: class extends GlDrawable {

    width, height: Int
    textureID: Int
    cairoDrawable: CairoDrawable
    cairoSurface: CairoSurface
    context: CairoContext

    surfData: UChar*

    init: func (=width, =height, =cairoDrawable) {
	_createCairoContext()
	_createTexture()
    }

    _createCairoContext: func {
	channels := 4
	surfData = gc_malloc(channels * width * height * UChar size)
	if (!surfData) {
	    Exception new("createCairoContext - Couldn't allocate buffer") throw()
	}

	cairoSurface = CairoImageSurface new(surfData, CairoFormat ARGB32,
	    width, height, channels * width)
	if (cairoSurface status() != CairoStatus SUCCESS) {
	    Exception new("createCairoContext - Couldn't create surface") throw()
	}

	context = CairoContext new(cairoSurface)
	if (context status() != CairoStatus SUCCESS) {
	    Exception new("createCairoContext - Couldn't create context") throw()
	}
    }

    _createTexture: func {
	glGenTextures(1, textureID&)
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID);
        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
                      0,   
                      GL_RGBA,
                      width,
                      height,
                      0,   
                      GL_BGRA,
                      GL_UNSIGNED_BYTE,
                      null)
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL)
    }

    update: func {
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID)
	glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
		     0,
		     GL_RGBA,
		     width,
		     height,
		     0,
		     GL_BGRA,
		     GL_UNSIGNED_BYTE,
		     surfData)
    }

    draw: func (dye: Dye) {
	dye begin2D()
	cairoDrawable draw(dye, context)	

	drawTexture()
	dye end2D()
    }

    drawTexture: func {
	glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID)

	glColor3f(1.0, 1.0, 1.0)
	glBegin(GL_QUADS)

	glTexCoord2f(0.0, 0.0)
	glVertex2f(0.0, 0.0)

	glTexCoord2f(width, 0.0)
	glVertex2f(width, 0.0)

	glTexCoord2f(width, height)
	glVertex2f(width, height)

	glTexCoord2f(0.0, height)
	glVertex2f(0.0, height)

	glEnd()
    }

}

