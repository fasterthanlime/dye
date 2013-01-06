
use glew
import glew

use glu
import glu

use dye
import dye/[core, math]

Fbo: class {

    dye: DyeContext

    width, height: Int
    textureId: Int
    rboId: Int
    fboId: Int

    init: func (=dye, =width, =height) {
        // create a texture object
        glGenTextures(1, textureId&)
        glBindTexture(GL_TEXTURE_2D, textureId)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null)
        glBindTexture(GL_TEXTURE_2D, 0) 

        // create a renderbuffer object to store depth info
        glGenRenderbuffers(1, rboId&)
        glBindRenderbuffer(GL_RENDERBUFFER, rboId)
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height)
        glBindRenderbuffer(GL_RENDERBUFFER, 0)

        // create a framebuffer object
        glGenFramebuffers(1, fboId&)
        bind()

        // attach the texture to FBO color attachment point
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureId, 0)

        // attach the renderbuffer to depth attachment point
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboId)

        // check FBO status
        status := glCheckFramebufferStatus(GL_FRAMEBUFFER)
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            "Can't use FBO" println()
            //fboUsed = false
        }

        // switch back to window-system-provided framebuffer
        unbind()
    }

    bind: func {
        glBindFramebuffer(GL_FRAMEBUFFER, fboId)
    }

    unbind: func {
        glBindFramebuffer(GL_FRAMEBUFFER, 0)
    }

    render: func {
        dye begin2D(dye windowSize)
	glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        glEnable(GL_TEXTURE_2D)
        glBindTexture(GL_TEXTURE_2D, textureId)
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        ratio := dye size y as Float / dye size x as Float
        realRatio := dye windowSize y as Float / dye windowSize x as Float

        realWidth, realHeight: Float

        if (realRatio < ratio) {
            realHeight = dye windowSize y as Float
            realWidth = realHeight / ratio
        } else {
            realWidth = dye windowSize x as Float
            realHeight = realWidth * ratio
        }

        glPushMatrix()
        glTranslatef(dye windowSize x / 2 - realWidth / 2, dye windowSize y/ 2 - realHeight / 2, 0)

        glColor4f(1, 1, 1, 1)
        glBegin(GL_QUADS)
            glTexCoord2f(0.0, 1.0)
            glVertex2f(0, 0)

            glTexCoord2f(1.0, 1.0)
            glVertex2f(realWidth, 0)

            glTexCoord2f(1.0, 0.0)
            glVertex2f(realWidth, realHeight)

            glTexCoord2f(0.0, 0.0)
            glVertex2f(0, realHeight)
        glEnd()

        glPopMatrix()

        glBindTexture(GL_TEXTURE_2D, 0)
        glDisable(GL_TEXTURE_2D)

        dye end2D()
    }

}

