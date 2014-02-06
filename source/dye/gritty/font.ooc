
// third-party stuff
use dye
import dye/[core, math]
import dye/gritty/[texture, rectanglebinpack]

// debug
import dye/[primitives]

use freetype2
import freetype2

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/[ArrayList, HashMap]

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
        list := ArrayList<Glyph> new()

        // load all printable ASCII characters for now
        for (i in 32..127) {
            charPoint := i as ULong
            index := _face getCharIndex(charPoint)
            _face loadGlyph(index, FTLoadFlag default_)

            glyph := Glyph new(charPoint, _face@ glyph)
            glyphs put(charPoint, glyph)
            list add(glyph)
        }

        // create bin
        poftwo := 6 // start with 64x64
        bin = RectangleBinPack new(1 << poftwo, 1 << poftwo)
        fit := false

        while (!fit) {
            fit = true

            for (glyph in list) {
                node := bin insert(bin root, glyph width + 2, glyph rows + 2)
                if (node) {
                    glyph binNode = node
                } else {
                    "Couldn't fit glyph! #{glyph width + 1}x#{glyph rows + 1}, occupancy = #{bin occupancy()}" println()
                    fit = false
                    break
                }
            }

            if (!fit) {
                poftwo += 1
                bin = RectangleBinPack new(1 << poftwo, 1 << poftwo)
                "Re-trying with a #{bin root width}x#{bin root height} bin" println()
            }
        }

        atlas = GlyphAtlas new(bin binWidth, bin binHeight)
        for(glyph in list) { atlas blit(glyph) }
        atlas bake()
        "Final bin occupancy: #{bin occupancy()}" println()
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
    blitCount := 0

    init: func (width, height: Int) {
        texture = Texture new(width, height, "<glyph atlas>")

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
                memset(data + dstIndex * 4, gray, 4)
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

