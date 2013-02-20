
// our stuff
import dye/[core, math, anim]

// third-party stuff
import sdl2/[OpenGL]

use stb-image

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

        width, height, channels: Int
        data := StbImage fromPath(path, width&, height&, channels&, 4)

        if (width == 0 || height == 0 || channels == 0) {
          logger warn("Failed to load %s!" format(path))
          return Texture new(-1, 0, 0, "<missing>")
        }

        logger debug("Loading %s, size %dx%d, %d bpp" format(path, width, height, channels))

        textureID: Int

        glGenTextures(1, textureID&)
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, textureID)

        _flip(data, width, height)
        _premultiply(data, width, height)

        glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
                    0,
                    GL_RGBA,
                    width,
                    height,
                    0,
                    GL_RGBA,
                    GL_UNSIGNED_BYTE,
                    data)
        texture := Texture new(textureID, width, height, path)
        cache put(path, texture)
        texture
    }

    _premultiply: static func (data: UInt8*, width: Int, height: Int) {
        factor := 1.0 / 255.0
        for (i in 0..(width * height)) {
            b     := data[i * 4 + 0] as Float
            g     := data[i * 4 + 1] as Float
            r     := data[i * 4 + 2] as Float
            alpha := factor * data[i * 4 + 3]

            data[i * 4 + 0] = (b * alpha)
            data[i * 4 + 1] = (g * alpha)
            data[i * 4 + 2] = (r * alpha)
        }

    }

    _flip: static func (data: UInt8*, width: Int, height: Int) {
        pixels := data as UInt32*

        for (y in 0..(height / 2)) {
          y2 := height - 1 - y
          for (x in 0..width) {
            i1 := y  * width + x
            i2 := y2 * width + x

            // flip it!
            tmp := pixels[i1]
            pixels[i1] = pixels[i2]
            pixels[i2] = tmp
          }
        }
    }

}

