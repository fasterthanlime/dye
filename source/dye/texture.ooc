
// ours
import dye/[core, math]
import dye/base/[io]

// third
import sdl2/[OpenGL]

use stb-image

use deadlogger
import deadlogger/[Log, Logger]

// sdk
import structs/HashMap
import io/File

TextureFilter: enum {
    nearest = GL_NEAREST
    linear  = GL_LINEAR
}

WrapMode: enum {
    clamp          = GL_CLAMP_TO_EDGE
    mirroredRepeat = GL_MIRRORED_REPEAT
    repeat         = GL_REPEAT
}

/**
 * This class represents an RGBA OpenGL texture
 */
Texture: class {

    id: UInt
    width, height: Int
    path: String
    _data: UInt8*

    filter: TextureFilter
    wrap: WrapMode

    target := GL_TEXTURE_2D
    internalFormat := GL_RGBA
    format := GL_RGBA

    init: func (=width, =height, =path,
        filter := TextureFilter linear, wrap := WrapMode clamp) {

        glGenTextures(1, id&)
        bind()

        this filter = filter
        this wrap = wrap
        version (!android) {
            internalFormat = GL_RGBA8
        }

        setup()
    }

    setup: func {
        setMinFilter(filter)
        setMagFilter(filter)
        setWrapS(wrap)
        setWrapT(wrap)
    }

    setWrapS: func (wrap: WrapMode) {
        glTexParameteri(target, GL_TEXTURE_WRAP_S, wrap as GLint)
    }

    setWrapT: func (wrap: WrapMode) {
        glTexParameteri(target, GL_TEXTURE_WRAP_T, wrap as GLint)
    }

    setMinFilter: func (filter: TextureFilter) {
        glTexParameteri(target, GL_TEXTURE_MIN_FILTER, filter as GLint)
    }

    setMagFilter: func (filter: TextureFilter) {
        glTexParameteri(target, GL_TEXTURE_MAG_FILTER, filter as GLint)
    }

    upload: func (data: UInt8*) {
        _data = data
        glTexImage2D(target,
                    0,
                    internalFormat,
                    width,
                    height,
                    0,
                    format,
                    GL_UNSIGNED_BYTE,
                    data
        )
    }

    update: func (data: UInt8*, xOffset := 0, yOffset := 0, updateWidth := 0, updateHeight := 0) {
        bind()

        if (updateWidth == 0) {
            updateWidth = width
        }

        if (updateHeight == 0) {
            updateHeight = height
        }

        glTexSubImage2D(target,  // target
                    0,                  // level
                    xOffset,            // xoffset
                    yOffset,            // yoffset
                    updateWidth,        // width
                    updateHeight,       // height
                    format,             // format
                    GL_UNSIGNED_BYTE,   // type
                    data                // data
        )
    }

    bind: func {
        glBindTexture(target, id)
    }

    detach: func {
        glBindTexture(target, 0)
    }

    dispose: func {
        glDeleteTextures(1, id&)
    }

}

/**
 * This is a texture loader with built-in cache
 */
TextureLoader: class {

    cache := static HashMap<String, Texture> new()
    logger := static Log getLogger(This name)

    _placeholder: static Texture

    load: static func (path: String) -> Texture {
        if (cache contains?(path)) {
            return cache get(path)
        }

        width, height, channels: Int

        reader: RWopsReader

        try {
            reader = RWopsReader new(path)
        } catch (rwe: RWException) {
            logger warn("Failed to read %s. Reason: %s", path, rwe message)
            return _getPlaceholder()
        }
        cb := StbIo callbacks()

        data := StbImage fromCb(cb&, reader, width&, height&, channels&, 4)
        reader close()

        if (width == 0 || height == 0 || channels == 0) {
            failureReason := StbImage failureReason() toString()
            logger warn("Failed to load %s! Failure reason: %s" format(path, failureReason))
            return _getPlaceholder()
        }

        logger debug("Loading %s, size %dx%d, %d bpp" format(path, width, height, channels))

        // we used to detect the number of channels here, but
        // as it turns out stb_image does the right thing and converts
        // from RGB or Grayscale to RGBA for us, since we requested 4 channels.
        // Which is great!

        texture := Texture new(width, height, path)

        _flip(data, width, height)
        _premultiply(data, width, height)
        texture upload(data)

        cache put(path, texture)

        texture
    }

    _colorize: static func (data: UInt8*, width, height: Int, r, g, b: Int) {
        if (!data) return

        R := r / 255.0f
        G := g / 255.0f
        B := b / 255.0f

        // "Colorizing to #{r}, #{g}, #{b}" println()
        numPixels := width * height
        for (i in 0..numPixels) {
            data[i * 4 + 0] = r
            data[i * 4 + 1] = g
            data[i * 4 + 2] = b
        }
    }

    _getPlaceholder: static func -> Texture {
        if (!_placeholder) {
            _placeholder = Texture new(0, 0, "<missing>")
        }
        _placeholder
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

