
use cairo
import cairo/Cairo

import dye/core

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
	cairoDrawable draw(dye, context)	

	drawTexture()
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

