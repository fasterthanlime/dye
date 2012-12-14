
use devil
import devil

import dye/core

use glew
import glew

TextureLoader: class {

    initialized := static false

    load: static func (path: String) -> Int {
        if (!initialized) {
            ilInit()
            ilutInit()
            initialized = true
        }

        ilutGLLoadImage(path)
    }

}

GlSprite: class extends GlDrawable {

    width, height: Int
    textureID: Int

    init: func (path: String) {
        width = 100
        height = 100

        textureID = TextureLoader load(path)
    }

    draw: func (dye: Dye) {
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

