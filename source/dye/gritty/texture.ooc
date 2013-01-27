
// our stuff
import dye/[core, math, anim]

// third-party stuff
use glew
import glew

use freeimage
import freeimage/[FreeImage, Bitmap, ImageFormat]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/HashMap

/**
 * This class represents a texture
 */
Texture: class {

  id: Int
  width, height: Int
  path: String

  init: func (=id, =width, =height, =path) {
  }

}

/**
 * This is a texture loader with built-in cache
 */
TextureLoader: class {

    cache := static HashMap<String, Texture> new()
    logger := static Log getLogger(This name)

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

        logger debug("Loading %s, size %dx%d, %d bpp" format(path, bitmap width, bitmap height, bitmap bpp))

        textureID: Int

        glGenTextures(1, textureID&)
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID)

        data: UInt8* = bitmap bits()

        factor := 1.0 / 255.0
        for (i in 0..(bitmap width * bitmap height)) {
            b     := data[i * 4 + 0] as Float
            g     := data[i * 4 + 1] as Float
            r     := data[i * 4 + 2] as Float
            alpha := factor * data[i * 4 + 3]

            data[i * 4 + 0] = (b * alpha)
            data[i * 4 + 1] = (g * alpha)
            data[i * 4 + 2] = (r * alpha)
        }

        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
                    0,
                    GL_RGBA,
                    bitmap width,
                    bitmap height,
                    0,
                    GL_BGRA,
                    GL_UNSIGNED_BYTE,
                    data)
        texture := Texture new(textureID, bitmap width, bitmap height, path)
        cache put(path, texture)
        texture
    }

}

