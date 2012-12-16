
use freeimage
import freeimage/[FreeImage, Bitmap, ImageFormat]

import dye/[core, math]

use glew
import glew

import structs/HashMap

use deadlogger
import deadlogger/[Log, Logger]

Texture: class {

  id: Int
  width, height: Int
  path: String

  init: func (=id, =width, =height, =path) {
  }

}

TextureLoader: class {

    cache := static HashMap<String, Texture> new()
    logger := static Log getLogger("texture")

    load: static func (path: String) -> Texture {
        if (cache contains?(path)) {
            return cache get(path)
        }

        bitmap := Bitmap new(path)
        bitmap = bitmap convertTo32Bits()

        if (bitmap width == 0 || bitmap height == 0 || bitmap bpp == 0) {
          logger warn("Failed to load %s!" format(path))
          return Texture new(-1, 0, 0, "<missing>")
        }

        logger info("Loading %s, size %dx%d, %d bpp" format(path, bitmap width, bitmap height, bitmap bpp))

        textureID: Int

        glGenTextures(1, textureID&)
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID)

        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
                    0,
                    GL_RGBA,
                    bitmap width,
                    bitmap height,
                    0,
                    GL_BGRA,
                    GL_UNSIGNED_BYTE,
                    bitmap bits())
        texture := Texture new(textureID, bitmap width, bitmap height, path)
        cache put(path, texture)
        texture
    }

}

GlSprite: class extends GlDrawable {

    texture: Texture
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    center := true

    xSwap := false

    init: func (path: String) {
        texture = TextureLoader load(path)
        size = vec2(texture width, texture height)
    }

    render: func (dye: DyeContext) {
        if (center) {
            glPushMatrix()

            glTranslatef(width * -0.5, height * -0.5, 0.0)
            super()

            glPopMatrix()
        } else {
            super()
        }
    }

    draw: func (dye: DyeContext) {
        glColor3f(1.0, 1.0, 1.0)

        dye withTexture(GL_TEXTURE_RECTANGLE_ARB, texture id, ||
            self := this

            if (xSwap) {
                dye begin(GL_QUADS, ||
                    glTexCoord2f(width, 0.0)
                    glVertex2f(0.0, height)

                    glTexCoord2f(0.0, 0.0)
                    glVertex2f(width, height)

                    glTexCoord2f(0.0, height)
                    glVertex2f(width, 0.0)

                    glTexCoord2f(width, height)
                    glVertex2f(0.0, 0.0)
                )
            } else {
                dye begin(GL_QUADS, ||
                    glTexCoord2f(0.0, 0.0)
                    glVertex2f(0.0, height)

                    glTexCoord2f(width, 0.0)
                    glVertex2f(width, height)

                    glTexCoord2f(width, height)
                    glVertex2f(width, 0.0)

                    glTexCoord2f(0.0, height)
                    glVertex2f(0.0, 0.0)
                )
            }
        )
    }

}

GlCroppedSprite: class extends GlSprite {

    /* For cropping purposes. Yes, yes, quite. */
    left, right, top, bottom: Float

    init: func (path: String) {
        super(path)

        left = 0
        right = 0
        top = 0
        bottom = 0
    }

    draw: func (dye: DyeContext) {
        glColor3f(1.0, 1.0, 1.0)

        dye withTexture(GL_TEXTURE_RECTANGLE_ARB, texture id, ||
            self := this

            dye begin(GL_QUADS, ||
                vertices := [
                    vec2(0.0, 0.0)
                    vec2(0.0, height - bottom - top)
                    vec2(width - left - right, height - bottom - top)
                    vec2(width - left - right, 0.0)
                ]

                texCoords := [
                    vec2(left, height - top)
                    vec2(left, bottom)
                    vec2(width - right, bottom)
                    vec2(width - right, height - top)
                ]

                for (i in 0..vertices length) {
                    dye texCoord(texCoords[i])
                    dye vertex(vertices[i])
                }
            )
        )
    }

}


