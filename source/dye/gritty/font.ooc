
// third-party stuff
use dye
import dye/[core, math]

use freetype2
import freetype2

// sdk stuff
import structs/[HashMap]

Font: class {

    _ftInitialized := static false
    _ft: static FTLibrary
    _face: FTFace

    glyphs := HashMap<ULong, Glyph> new()

    fontSize: Float
    fontPath: String

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
        charset := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ"

        // TODO: load glyphs here
        _iterate(charset, |charPoint|
            index := _face getCharIndex(charPoint)
            _face loadGlyph(index, FTLoadFlag default)

            glyph := Glyph new(_face@ glyph)
            glyphs put(charPoint, glyph)
        )
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

            if (!glyph) {
                "Ignored unknown glyph %c" printfln(charPoint)
                return
            }

            tempAABB set!(glyph aabb)
            tempAABB add!(position)
            aabb expand!(tempAABB)

            position add!(glyph advance)
        )

        aabb expand!(position)

        aabb
    }

    render: func (dye: DyeContext, text: String) {
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

    _glyph: FTGlyph

    aabb: AABB2
    advance: Vec2

    init: func (slot: FTGlyphSlot) {
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

        "Loaded a glyph, aabb = %s, advance = %s" printfln(aabb _, advance _)
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

