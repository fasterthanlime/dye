
use freeimage
import freeimage/[FreeImage, Bitmap, ImageFormat]

import dye/core

use glew
import glew

Texture: class {

  id: Int
  width, height: Int

  init: func (=id, =width, =height)

}

TextureLoader: class {

    load: static func (path: String) -> Texture {
        bitmap := Bitmap new(path)
        bitmap = bitmap convertTo32Bits()

        if (bitmap width == 0 || bitmap height == 0 || bitmap bpp == 0) {
          "Failed to load %s!" printfln(path)
          return Texture new(-1, 0, 0)
        }

        "Loaded %s, size %dx%d, %d bpp" printfln(path, bitmap width, bitmap height, bitmap bpp)

        textureID: Int

        glGenTextures(1, textureID&)
        glBindTexture(GL_TEXTURE_2D, textureID)
        
        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB, 0, GL_RGBA, bitmap width, bitmap height, 0, GL_BGRA, GL_UNSIGNED_BYTE, bitmap bits())
        Texture new(textureID, bitmap width, bitmap height)
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

    draw: func (dye: Dye) {
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

