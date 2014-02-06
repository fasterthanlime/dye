
// third-party stuff
use dye
import dye/[core, math, sprite]
import dye/gritty/[texture, rectanglebinpack]

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

    bin: RectangleBinPack
    atlas: GlyphAtlas

    glyphs := HashMap<ULong, Glyph> new()

    fontSize: Float
    fontPath: String
    lineHeight: Float

    color := Color white()

    init: func (=fontSize, =fontPath) {
        if (!_ftInitialized) {
            _ftInitialized = true
            _ft init()
        }

        // create bin
        bin = RectangleBinPack new(512, 512)
        "Initial bin occupancy: #{bin occupancy()}" println()
        atlas = GlyphAtlas new(bin binWidth, bin binHeight)

        // load font
        _ft newFace(fontPath, 0, _face&)

        // set the right size
        dpi := 72
        _face setCharSize((fontSize * 64.0) as Int, 0, dpi, dpi)

        // render the chars we need
        _loadCharset()

        // store metrics
        metrics := _face@ size@ metrics
        lineHeight = metrics height toFloat()

        // free it!
        _face done()
    }

    _loadCharset: func {
        // load all printable ASCII characters for now
        for (i in 32..127) {
            charPoint := i as ULong
            index := _face getCharIndex(charPoint)
            _face loadGlyph(index, FTLoadFlag default_)

            glyph := Glyph new(charPoint, _face@ glyph)
            node := bin insert(bin root, glyph width + 1, glyph rows + 1)
            if (!node) {
                "Couldn't fit glyph!" println()
            } else {
                "glyph size: #{glyph width} x #{glyph rows}, x, y = #{node x}, #{node y}, occupancy: #{bin occupancy()}" println()
                glyph binNode = node
                atlas blit(glyph)
            }

            glyph sprite color = color // make them all point to the same thing
            glyphs put(charPoint, glyph)
        }
        atlas bake()
    }

    getLineHeight: func -> Float {
        lineHeight
    }

    getBounds: func (str: String) -> AABB2 {
        aabb := AABB2 new()
        tempAABB := AABB2 new()

        pen := vec2(0, 0)

        _iterate(str, |charPoint|
            match charPoint {
                case '\n' =>
                    pen x = 0
                    pen y -= getLineHeight()
                case =>
                    glyph := getGlyph(charPoint)

                    tempAABB set!(glyph aabb)
                    tempAABB add!(pen)
                    aabb expand!(tempAABB)

                    pen add!(glyph advance)
            }
        )
        aabb expand!(pen)

        aabb
    }

    renderDebugAtlas: func (pass: Pass, inputModelView: Matrix4) {
        modelView := inputModelView
        atlas sprite render(pass, modelView)
    }

    renderDebug: func (pass: Pass, inputModelView: Matrix4) {
        modelView := inputModelView

        numGlyphs := 0
        glyphs each(|key, glyph|
            if (glyph binNode) {
                numGlyphs += 1
                node := glyph binNode
                modelView = inputModelView * Matrix4 newTranslate(node x, 0.0f - node height - node y, 0.0)
                glyph sprite color set!((key * 12) % 256, 120, 120)
                glyph sprite render(pass, modelView)
            }
        )
    }

    render: func (pass: Pass, inputModelView: Matrix4, text: String,
        color: Color, opacity: Float) {
        // debugging!
        renderDebugAtlas(pass, inputModelView)
        return

        modelView := inputModelView
        this color set!(color)

        pen := vec2(0, 0)

        _iterate(text, |charPoint|
            match charPoint {
                case '\n' =>
                    pen x = 0
                    pen y -= getLineHeight()
                case =>
                    glyph := getGlyph(charPoint)

                    if (!glyph) {
                        return
                    }
                    glyph sprite opacity = opacity
                    glyph sprite render(pass, modelView)
                    pen add!(glyph advance x, glyph advance y)
            }
            modelView = inputModelView * Matrix4 newTranslate(pen x, pen y, 0.0)
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

GlyphAtlas: class {

    // RGBA_8888 texture data
    data: UInt8*

    // OpenGL texture
    texture: Texture

    // used for debug
    sprite: GlSprite
    blitCount := 0

    init: func (width, height: Int) {
        texture = Texture new(width, height, "<glyph atlas>")
        sprite = GlSprite new(texture)
        sprite color set!(128, 64, 0)
        sprite center = false

        // allocate texture memory
        numBytes := 4 * width * height
        data = gc_malloc_atomic(numBytes)
        // clear it
        memset(data, 0, numBytes)
    }

    blit: func (glyph: Glyph) {
        bin := glyph binNode
        if (!bin) {
            raise("node-less glyph!")
        }
        blitCount += 1

        bitmap := (glyph _glyph as FTBitmapGlyph)@ bitmap

        for (srcX in 0..glyph width) {
            dstX := srcX + bin x
            for (srcY in 0..glyph rows) {
                srcIndex := srcX + srcY * glyph width

                dstY := (glyph rows - srcY) + bin y
                dstIndex := dstX + dstY * texture width

                gray := (bitmap buffer[srcIndex]) as UInt8
                data[dstIndex * 4 + 0] = (glyph charPoint * 21) % 256
                data[dstIndex * 4 + 1] = (glyph charPoint * 47) % 256
                data[dstIndex * 4 + 2] = gray
                data[dstIndex * 4 + 3] = gray
            }
        }
    }

    bake: func {
        "baking! blitCount = #{blitCount}" println()
        texture bind()
        texture upload(data)
    }

}

Glyph: class {

    charPoint: ULong
    _glyph: FTGlyph
    binNode: BinNode

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

        /*
        Font logger info("Loaded glyph %c, aabb = %s, advance = %s, texSize = %s",
            charPoint as Char, aabb _, advance _, texSize _)
        Font logger info("left = %d, top = %d, rows = %d, width = %d",
            left, top, rows, width)
        */
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
        // sprite pos set!(left, top - rows)
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

