
use glew
import glew

use glu
import glu

use dye
import dye/math

Fbo: class {

    width, height: Int
    textureId: Int
    rboId: Int
    fboId: Int

    init: func (=width, =height) {
        // create a texture object
        glGenTextures(1, textureId&)
        glBindTexture(GL_TEXTURE_2D, textureId)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE) // automatic mipmap
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

}

