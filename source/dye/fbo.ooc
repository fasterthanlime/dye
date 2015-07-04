
// third-party stuff
use deadlogger
import deadlogger/Log

import sdl2/[OpenGL]

// our stuff
use dye
import dye/[core, math, sprite, texture]

/*
 * Frame buffer object support
 */
Fbo: class {

    size: Vec2i
    texture: Texture
    rboId: Int
    fboId: Int

    logger := static Log getLogger(This name)
    CORE := true

    init: func (=size) {
        // create a texture object
        texture = Texture new(size x, size y, "<fbo %p>" format(this))
        texture upload(null)

        if (!glGenFramebuffers) {
            // damn you, GLEW!
            CORE = false
        }

        if (CORE) {
            // create a renderbuffer object to store depth info
            glGenRenderbuffers(1, rboId&)
            glBindRenderbuffer(GL_RENDERBUFFER, rboId)
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, size x, size y)
            glBindRenderbuffer(GL_RENDERBUFFER, 0)

            // create a framebuffer object
            glGenFramebuffers(1, fboId&)
        } else {
            // create a renderbuffer object to store depth info
            glGenRenderbuffersEXT(1, rboId&)
            glBindRenderbufferEXT(GL_RENDERBUFFER, rboId)
            glRenderbufferStorageEXT(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, size x, size y)
            glBindRenderbufferEXT(GL_RENDERBUFFER, 0)

            // create a framebuffer object
            glGenFramebuffersEXT(1, fboId&)
        }

        bind()

        if (CORE) {
            // attach the texture to FBO color attachment point
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture id, 0)

            // attach the renderbuffer to depth attachment point
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboId)
        } else {
            // attach the texture to FBO color attachment point
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture id, 0)

            // attach the renderbuffer to depth attachment point
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboId)
        }

        status: Int

        // check FBO status
        if (CORE) {
            status = glCheckFramebufferStatus(GL_FRAMEBUFFER)
        } else {
            status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER)
        }

        if(status != GL_FRAMEBUFFER_COMPLETE) {
            logger warn("FBO status = %d" format(status as Int))
            logger error("FBO (Frame Buffer Objects) not supported, cannot continue")
            raise("fbo problem")
        }

        // zeroes buffer
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        // switch back to window-system-provided framebuffer
        unbind()
    }

    bind: func {
        if (CORE) {
            glBindFramebuffer(GL_FRAMEBUFFER, fboId)
        } else {
            glBindFramebufferEXT(GL_FRAMEBUFFER, fboId)
        }
    }

    unbind: func {
        if (CORE) {
            glBindFramebuffer(GL_FRAMEBUFFER, 0)
        } else {
            glBindFramebufferEXT(GL_FRAMEBUFFER, 0)
        }
    }

    dispose: func {
        texture dispose()

        if (CORE) {
            glDeleteRenderbuffers(1, rboId&)
            glDeleteFramebuffers(1, fboId&)
        } else {
            glDeleteRenderbuffersEXT(1, rboId&)
            glDeleteFramebuffersEXT(1, fboId&)
        }
    }

}

