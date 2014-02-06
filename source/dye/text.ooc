
// our stuff
use dye
import dye/[core, math, geometry]
import dye/gritty/[font, rectanglebinpack]

// third-party stuff
import sdl2/[OpenGL]

use deadlogger
import deadlogger/[Log, Logger]

// sdk stuff
import structs/HashMap

GlText: class extends Geometry {

    // static stuff
    cache := static HashMap<String, Font> new()
    logger := static Log getLogger(This name)

    // our font
    fontPath: String
    font: Font

    // textual values
    value: String
    _cachedValue := ""

    init: func (fontPathBase: String, =value, fontSize := 40) {
        fontPath = prefix + fontPathBase
        font = loadFont(fontPath, fontSize)
        super(font atlas texture)
        rebuild()
    }

    /*
     * METRICS
     */

    lineHeight: Float {
        get {
            font lineHeight
        }
    }

    size: Vec2 {
        get {
            bounds := getBounds(value)
            vec2(bounds width, bounds height)
        }
    }

    getBounds: func (str: String) -> AABB2 {
        aabb := AABB2 new()
        tempAABB := AABB2 new()

        pen := vec2(0, 0)

        _iterate(str, |charPoint|
            match charPoint {
                case '\n' =>
                    pen x = 0
                    pen y -= lineHeight
                case =>
                    glyph := font getGlyph(charPoint)

                    tempAABB set!(glyph aabb)
                    tempAABB add!(pen)
                    aabb expand!(tempAABB)

                    pen add!(glyph advance)
            }
        )

        pen x = 0
        pen y -= lineHeight
        aabb expand!(pen)

        aabb
    }

    /*
     * LOADING
     */

    loadFont: static func (fontPath: String, fontSize: Int) -> Font {
        key := "%s-%d" format(fontPath, fontSize)

        if (cache contains?(key)) {
            cache get(key)
        } else {
            logger debug("Loading font %s at size %d" format(fontPath, fontSize))
            font := Font new(fontSize, fontPath)
            cache put(key, font)
            font
        }
    }

    /*
     * RENDERING
     */

    render: func (pass: Pass, modelView: Matrix4) {
        if (_cachedValue != value) {
            rebuild()
        }
        super(pass, modelView)
    }

    rebuild: func {
        _cachedValue = value clone()

        glyphCount := 0
        _iterate(_cachedValue, |charPoint|
            glyphCount += 1
        )

        pen := vec2(0, 0)

        build(6 * glyphCount, |builder|
            _iterate(_cachedValue, |charPoint|
                match charPoint {
                    case '\n' =>
                        pen x = 0
                        pen y -= lineHeight
                    case =>
                        glyph := font getGlyph(charPoint)

                        if (!glyph || !glyph binNode) {
                            return
                        }
                        node := glyph binNode
                        builder quad6(
                            pen x + glyph left,
                            pen y + glyph top - glyph rows,
                            node width  - 1,
                            node height - 1,
                            node x as Float / font bin binWidth as Float,
                            node y as Float / font bin binHeight as Float,
                            (node width  - 1) as Float / font bin binWidth as Float,
                            (node height - 1) as Float / font bin binHeight as Float
                        )

                        pen add!(glyph advance x, glyph advance y)
                }
            )
        )
    }

    /*
     * TEXT HANDLING
     */

    _iterate: func (str: String, f: Func (ULong)) {
        // TODO: UTF-8 support using utf8proc, I guess
        for (c in str) {
            f(c as ULong)
        }
    }

}

