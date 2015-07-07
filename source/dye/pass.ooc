
import dye/[core, math, fbo, sprite]
import sdl2/OpenGL

/**
 * A render pass
 */
Pass: abstract class {

    identity := static Matrix4 newIdentity()

    // clears before drawing?
    clears := true

    size: Vec2i
    projectionMatrix: Matrix4
    clearColor := Color new(0, 0, 0)
    clearAlpha := 0.0f
    group := Group new()
    fbo: Fbo

    // convenience properties
    width:  Int { get { size x } }
    height: Int { get { size y } }

    init: func (=size, =fbo) {
        computeProjection()
    }

    /**
     * Recompute projection matrix
     */
    computeProjection: func {
        projectionMatrix = Matrix4 newOrtho(
            0, size x,
            0, size y,
            -1000.0,
            1000.0)
    }

    render: abstract func

    doRender: func {
        if (clears) {
            doClear()
        }

        glEnable(GL_BLEND)
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        group render(this, identity)

        glDisable(GL_BLEND)
    }

    doClear: func {
        glClearColor(clearColor R, clearColor G, clearColor B, clearAlpha)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    }


}

/**
 * A pass that renders to a texture
 */
TexturePass: class extends Pass {

    init: func (=size) {
        super(size, Fbo new(size))
    }

    resize: func (=size) -> Bool {
        resized := false

        computeProjection()
        // fbo too small? resize!
        if (fbo size x < size x || fbo size y < size y) {
            newFboSize := vec2i(_nextPo2(size x), _nextPo2(size y))
            fbo dispose()
            fbo = Fbo new(newFboSize)
            resized = true
        }

        // clear
        fbo bind()
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        fbo unbind()

        resized
    }

    doClear: func {
        glEnable(GL_SCISSOR_TEST)
        glScissor(0, 0, size x, size y)
        super()
        glDisable(GL_SCISSOR_TEST)
    }

    _nextPo2: func (number: Int) -> Int {
        poftwo := 1
        while ((1 << poftwo) < number) {
            poftwo += 1
        }
        1 << poftwo
    }

    render: func {
        fbo bind()
        glViewport(0, 0, size x, size y)
        doRender()
        fbo unbind()
    }

}

/**
 * A pass that renders directly to a window
 */
WindowPass: class extends Pass {

    dye: Context
    sprite: Sprite
    targetSize := vec2(-1 , -1)
    targetOffset := vec2(0, 0)
    scale := 1.0

    init: func (=dye, .fbo) {
        super(vec2i(dye windowSize x, dye windowSize y), fbo)

        sprite = Sprite new(fbo texture)
        sprite center = false

        group add(sprite)
    }

    render: func {
        adjustSprite()
        glViewport(0, 0, dye windowSize x, dye windowSize y)
        doRender()
    }

    adjustSprite: func {
        ratio := fbo size ratio()
        targetRatio := dye windowSize ratio()
        windowSize := vec2(dye windowSize x, dye windowSize y)

        if (targetRatio < ratio) {
            // target thinner than window (pillarbox)
            targetSize x = windowSize y / ratio
            targetSize y = windowSize y
            sprite scale = (targetRatio / ratio, 1.0f) as Vec2

            targetOffset x = ((size y / targetRatio) - size x) * 0.5 * sprite scale x
            targetOffset y = 0.0f
        } else {
            // target wider than window (letterbox)
            targetSize x = windowSize x
            targetSize y = windowSize x * ratio
            sprite scale = (1.0f, ratio / targetRatio) as Vec2

            targetOffset x = 0.0f
            targetOffset y = ((size x * targetRatio) - size y) * 0.5 * sprite scale y
        }

        sprite pos = targetOffset
    }

}

