
use freeimage
import freeimage/[FreeImage, Bitmap, ImageFormat]

import dye/[core, math]

use glew
import glew

Texture: class {

  id: Int
  width, height: Int
  path: String

  init: func (=id, =width, =height, =path) {
  }

}

TextureLoader: class {

    load: static func (path: String) -> Texture {
        bitmap := Bitmap new(path)
        bitmap = bitmap convertTo32Bits()

        if (bitmap width == 0 || bitmap height == 0 || bitmap bpp == 0) {
          "Failed to load %s!" printfln(path)
          return Texture new(-1, 0, 0, "<missing>")
        }

        "Loaded %s, size %dx%d, %d bpp" printfln(path, bitmap width, bitmap height, bitmap bpp)

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
        Texture new(textureID, bitmap width, bitmap height, path)
    }

}

GlSprite: class extends GlDrawable {

    texture: Texture
    width, height: Int

    init: func (path: String) {
        texture = TextureLoader load(path)
        width = texture width
        height = texture height
    }

    draw: func (dye: DyeContext) {
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture id)

        glColor3f(1.0, 1.0, 1.0)
        glBegin(GL_QUADS)

        glTexCoord2f(0.0, 0.0)
        glVertex2f(0.0, height)

        glTexCoord2f(width, 0.0)
        glVertex2f(width, height)

        glTexCoord2f(width, height)
        glVertex2f(width, 0.0)

        glTexCoord2f(0.0, height)
        glVertex2f(0.0, 0.0)

        glEnd()
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
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture id)

        glColor3f(1.0, 1.0, 1.0)
        glBegin(GL_QUADS)

        vertices := [
            vec2(0.0, 0.0)
            vec2(0.0, height - bottom - top)
            vec2(width - left - right, height - bottom - top)
            vec2(width - left - right, 0.0)
        ]

        texcoords := [
            vec2(left, height - top)
            vec2(left, bottom)
            vec2(width - right, bottom)
            vec2(width - right, height - top)
        ]

        for (i in 0..vertices length) {
            t := texcoords[i]
            glTexCoord2f (t x, t y)

            v := vertices[i]
            glVertex2f   (v x, v y)
        }

        glEnd()
    }

}


