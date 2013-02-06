
// our stuff
import dye/[core, math, anim]
import dye/gritty/[texture]

// third-party stuff
import sdl2/[OpenGL]

GlGridSprite: class extends GlDrawable implements GlAnimSource {

    texture: Texture
    texSize: Vec2
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    xnum, ynum: Int
    x := 0
    y := 0

    brightness := 1.0
    opacity := 1.0

    init: func (path: String, =xnum, =ynum) {
        texture = TextureLoader load(path)
        texSize = vec2(texture width, texture height)
        size = vec2(texture width / xnum, texture height / ynum)
    }

    draw: func (dye: DyeContext) {
        glColor4f(brightness, brightness, brightness, opacity)

        dye withTexture(GL_TEXTURE_2D, texture id, ||
            self := this
            dye begin(GL_TRIANGLE_STRIP, ||
                rx := x
                ry := (ynum - 1) - y
                xFactor := x as Float / xnum as Float
                yFactor := y as Float / ynum as Float

                glTexCoord2f(rx * xFactor, ry * yFactor)
                glVertex2f(xFactor * -0.5, yFactor * -0.5)

                glTexCoord2f((rx + 1) * xFactor, ry * yFactor)
                glVertex2f(xFactor *  0.5, yFactor * -0.5)

                glTexCoord2f(rx * xFactor, (ry + 1) * yFactor)
                glVertex2f(xFactor * -0.5, yFactor *  0.5)

                glTexCoord2f((rx + 1) * xFactor, (ry + 1) * yFactor)
                glVertex2f(xFactor *  0.5, yFactor *  0.5)
            )
        )
    }

    // implement GlAnimSource

    numFrames: func -> Int { xnum }
    getDrawable: func -> GlDrawable { this }
    frameOffset: func (offset: Int) {
        setFrame(x + offset)
    }
    setFrame: func (x: Int) {
        this x = x repeat(0, xnum)
    }
    currentFrame: func -> Int { x }

}

GlSprite: class extends GlDrawable {

    texture: Texture
    texSize: Vec2
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    texWidth: Float { get { texSize x } }
    texHeight: Float { get { texSize y } }

    center := true

    brightness := 1.0
    opacity := 1.0

    init: func (path: String) {
        texture = TextureLoader load(path)
        size = vec2(texture width, texture height)
        texSize = vec2(0, 0)
        texSize set!(size)
    }

    render: func (dye: DyeContext) {
        if (center) {
            glPushMatrix()

            glTranslatef(width * scale x * -0.5, height * scale y * -0.5, 0.0)
            super()

            glPopMatrix()
        } else {
            super()
        }
    }

    draw: func (dye: DyeContext) {
        glColor4f(brightness, brightness, brightness, opacity)

        dye withTexture(GL_TEXTURE_2D, texture id, ||
            self := this

            dye begin(GL_TRIANGLE_STRIP, ||
                glTexCoord2f(0.0, 0.0)
                glVertex2f(0.0, 0.0)

                glTexCoord2f(1.0, 0.0)
                glVertex2f(width, 0.0)

                glTexCoord2f(0.0, 1.0)
                glVertex2f(0.0, height)

                glTexCoord2f(1.0, 1.0)
                glVertex2f(width, height)
            )
        )
    }

}


