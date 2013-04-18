
// third-party stuff
use dye
import dye/[core, math, sprite]
import dye/gritty/[texture]

use freetype2
import freetype2

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/[HashMap]

Font: class {

    logger := static Log getLogger(This name)

    _ftInitialized := static false
    _ft: static FTLibrary
    _face: FTFace

    glyphs := HashMap<ULong, Glyph> new()

    fontSize: Float
    fontPath: String

    color := Color white()

    init: func (=fontSize, =fontPath) {
        if (!_ftInitialized) {
            _ft init()
        }

        _ft newFace(fontPath, 0, _face&)

        dpi := 72
        _face setCharSize((fontSize * 64.0) as Int, 0, dpi, dpi)

        _loadCharset()
    }

    _loadCharset: func {
        // load all printable ASCII characters for now
        for (i in 32..127) {
            charPoint := i as ULong
            index := _face getCharIndex(charPoint)
            _face loadGlyph(index, FTLoadFlag default)

            glyph := Glyph new(charPoint, _face@ glyph)
            glyph sprite color = color // make them all point to the same thing
            glyphs put(charPoint, glyph)
        }
    }

    getLineHeight: func -> Float {
        (_face@ height as Float) / 64.0
    }

    getBounds: func (str: String) -> AABB2 {
        aabb := AABB2 new()
        tempAABB := AABB2 new()

        position := vec2(0, 0)

        _iterate(str, |charPoint|
            glyph := getGlyph(charPoint)

            tempAABB set!(glyph aabb)
            tempAABB add!(position)
            aabb expand!(tempAABB)

            position add!(glyph advance)
        )

        aabb expand!(position)

        aabb
    }

    render: func (dye: DyeContext, inputModelView: Matrix4, text: String, color: Color, opacity: Float) {
        modelView := inputModelView
        this color set!(color)

        _iterate(text, |c|
            glyph := getGlyph(c)

            if (!glyph) {
                return
            }
            glyph sprite opacity = opacity
            glyph sprite render(dye, modelView)

            modelView = Matrix4 newTranslate(glyph advance x, glyph advance y, 0.0) * modelView
        )
    }

    _iterate: func (str: String, f: Func (ULong)) {
        // TODO: UTF-8 support using utf8proc, I guess
        for (c in str) {
            f(c as ULong)
        }
    }

    getGlyph: func (charPoint: ULong) -> Glyph {
        glyphs get(charPoint)
    }

}

Glyph: class {

    charPoint: ULong
    _glyph: FTGlyph

    aabb: AABB2
    advance: Vec2

    // bitmap/texture related stuff
    top, left: Int
    rows, width: Int

    texSize: Vec2i
    texture: Texture
    sprite: GlSprite

    init: func (=charPoint, slot: FTGlyphSlot) {
        slot getGlyph(_glyph&)
        _glyph toBitmap(FTRenderMode normal, null, false)

        cbox: FTBBox
        _glyph getCBox(FTGlyphBBoxMode unscaled, cbox&)

        aabb = AABB2 new()
        aabb set!(cbox)

        advance = vec2(
            slot@ advance x toFloat(),
            slot@ advance y toFloat()
        )

        bitmapGlyph := _glyph as FTBitmapGlyph
        left  = bitmapGlyph@ left
        top   = bitmapGlyph@ top
        rows  = bitmapGlyph@ bitmap rows
        width = bitmapGlyph@ bitmap width

        texSize = vec2i(
             width nextPowerOfTwo(),
             rows  nextPowerOfTwo()
        )
        _createTexture(bitmapGlyph@ bitmap)

        Font logger info("Loaded glyph %c, aabb = %s, advance = %s, texSize = %s",
            charPoint as Char, aabb _, advance _, texSize _)
        Font logger info("left = %d, top = %d, rows = %d, width = %d",
            left, top, rows, width)
    }

    _createTexture: func (bitmap: FTBitmap) {
        texture = Texture new(texSize x, texSize y, "<font-glyph>")

        // create an RGBA texture from the shades-of-grey freetype data
        data := gc_malloc(4 * texture width * texture height) as UInt8*

        for (x in 0..width) {
            for (y in 0..rows) {
                srcIndex := x + y * width

                dstY := y + texSize y - rows
                dstIndex := x + dstY * texture width

                gray := (bitmap buffer[srcIndex]) as UInt8
                data[dstIndex * 4 + 0] = gray
                data[dstIndex * 4 + 1] = gray
                data[dstIndex * 4 + 2] = gray
                data[dstIndex * 4 + 3] = gray
            }
        }

        TextureLoader _flip(data, texture width, texture height)
        texture upload(data)
        sprite = GlSprite new(texture)
        sprite center = false
        sprite pos set!(left, 0)
    }

}

// Mix up dye's AABB2 and freetype
extend AABB2 {

    set!: func ~freetype (cbox: FTBBox) {
        xMin = cbox xMin toFloat()
        yMin = cbox yMin toFloat()
        xMax = cbox xMax toFloat()
        yMax = cbox yMax toFloat()
    }

}

