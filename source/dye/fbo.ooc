
// third-party stuff
use deadlogger
import deadlogger/Log

import sdl2/[OpenGL]

// our stuff
use dye
import dye/[core, math, sprite]
import dye/gritty/[texture]

Fbo: class {

    dye: DyeContext

    width, height: Int
    texture: Texture
    sprite: GlSprite
    rboId: Int
    fboId: Int

    targetSize := vec2(-1, -1)
    targetOffset := vec2(0, 0)
    scale := 1.0

    logger := static Log getLogger(This name)

    init: func (=dye, =width, =height) {
        // create a texture object
        texture = Texture new(width, height, "<fbo>")
        texture setMagFilter(TextureFilter NEAREST)
        texture upload(null)

        // create a sprite object
        sprite = GlSprite new(texture)
        sprite center = false

        // create a renderbuffer object to store depth info
        glGenRenderbuffers(1, rboId&)
        glBindRenderbuffer(GL_RENDERBUFFER, rboId)
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height)
        glBindRenderbuffer(GL_RENDERBUFFER, 0)

        // create a framebuffer object
        glGenFramebuffers(1, fboId&)
        bind()

        // attach the texture to FBO color attachment point
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture id, 0)

        // attach the renderbuffer to depth attachment point
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboId)

        // check FBO status
        status := glCheckFramebufferStatus(GL_FRAMEBUFFER)
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            logger warn("FBO status = %d" format(status as Int))
            logger error("FBO (Frame Buffer Objects) not supported, cannot continue")
            raise("fbo problem")
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
	glClearColor(0.0, 0.0, 0.0, 1.0)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        ratio := dye size ratio()
        targetRatio := dye windowSize ratio()

        if (targetRatio < ratio) {
            targetSize y = dye windowSize y
            targetSize x = targetSize y / ratio
        } else {
            targetSize x = dye windowSize x
            targetSize y = targetSize x * ratio
        }

        scale = targetSize x as Float / dye size x as Float

        targetOffset x = dye windowSize x / 2 - targetSize x / 2
        targetOffset y = dye windowSize y / 2 - targetSize y / 2

        sprite pos set!(targetOffset x, targetOffset y)
        //sprite scale set!(scale, scale)

        sprite render(dye, Matrix4 newIdentity())
    }

}

