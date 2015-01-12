
// our stuff
import dye/[core, math, anim, geometry]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

// sdk
import structs/[ArrayList]

// third-party stuff
import sdl2/[OpenGL]

/**
 * A sprite - ie. a texture displayed on a rectangle,
 * with alpha blending, an opacity value, and a color to
 * tint the texture.
 */
GlSprite: class extends Geometry {

    w := 0.0f
    h := 0.0f

    size: Vec2 { get { vec2(w, h) } }

    // adjustments
    texX := 0.0f
    texY := 0.0f
    texW := 1.0f
    texH := 1.0f

    new: static func (path: String) -> This {
        This new(TextureLoader load(path))
    }

    init: func ~fromTex (.texture) {
        super(texture)
        mode = GL_TRIANGLE_STRIP
        setTexture(texture)
    }

    setTexture: func ~tex (=texture) {
        w = texture width
        h = texture height
        rebuild()
    }

    setTexture: func ~path (path: String) {
        setTexture(TextureLoader load(path))
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!shouldDraw?(pass)) return

        mv := computeModelView(modelView)

        if (center) {
            mv = mv * Matrix4 newTranslate(w * -0.5, h * -0.5, 0.0)
        }

        if (round) {
            mv round!()
        }
        draw(pass, mv)
    }

    rebuild: func {
        build(4, |builder|
            builder quadStrip(
                0, 0,
                w, h,
                texX, texY,
                texW, texH 
            )
        )
    }

}

/**
 * A grid sprite - behaves like a sprite except it's divided into cells
 * that are displayed individually.
 *
 * A sprite sheet, if you will. Must specify xnum and ynum which is the
 * number of columns and rows in the sheet. x and y are the column and
 * row you want to display.
 */
GlGridSprite: class extends GlSprite implements GlAnimSource {
    xnum, ynum: Int
    col, row: Int
    _col = -1: Int
    _row = -1: Int

    init: func (path: String, .xnum, .ynum) {
        init(TextureLoader load(path), xnum, ynum)
    }

    init: func ~fromTex (.texture, =xnum, =ynum) {
        super(texture)
        texW = 1.0 / xnum as Float
        texH = 1.0 / ynum as Float
        w = texture width  as Float / xnum as Float
        h = texture height as Float / ynum as Float
        rebuild()
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (col != _col || row != _row) {
           _col = col 
           _row = row 
           texX = texW * _col
           texY = texH * (ynum - 1 - _row)
           rebuild()
        }

        super(pass, modelView)
    }

    // implement GlAnimSource

    numFrames: func -> Int { xnum }
    getDrawable: func -> GlSpriteLike { this }
    frameOffset: func (offset: Int) {
        setFrame(col + offset)
    }
    setFrame: func (col: Int) {
        this col = col repeat(0, xnum)
    }
    currentFrame: func -> Int { col }

}

GlNinePatch: class extends Geometry {
    DEBUG := static false

    outerWidth, outerHeight: Int
    _outerWidth  := -1
    _outerHeight := -1
    innerWidth  : Float { get { outerWidth  * (1 - left - right) } }
    innerHeight : Float { get { outerHeight * (1 - top - bottom) } }

    left   := 8
    right  := 8
    top    := 8
    bottom := 8
    _left   := -1
    _right  := -1
    _top    := -1
    _bottom := -1

    new: static func (path: String) -> This {
        This new(TextureLoader load(path))
    }

    init: func ~fromText (.texture) {
        super(texture)
        mode = GL_TRIANGLE_STRIP
        setTexture(texture)
    }

    setTexture: func ~tex (=texture) {
        rebuild()
    }

    render: func (pass: Pass, modelView: Matrix4) {
        if (!shouldDraw?(pass)) return

        if (outerWidth != _outerWidth || outerHeight != _outerHeight ||
            left != _left || right != _right || top != _top || bottom != _bottom) {
            _outerWidth  = outerWidth
            _outerHeight = outerHeight
            _left   = left  
            _right  = right 
            _top    = top   
            _bottom = bottom
            rebuild()
        }

        mv := computeModelView(modelView)

        if (center) {
            dx := outerWidth * -0.5
            dy := outerHeight * -0.5
            mv = mv * Matrix4 newTranslate(dx, dy, 0.0)
        }

        if (round) {
            mv round!()
        }
        draw(pass, mv)
    }

    rebuild: func {
        tw : Float = texture width
        th : Float = texture height

        L := (left   as Float / tw)
        R := (right  as Float / tw)
        T := (top    as Float / th)
        B := (bottom as Float / th)

        // useful texture coordinates
        tx0 := 0.0
        tx1 := L
        tx2 := 1.0 - R
        tx3 := 1.0

        ty0 := 0.0
        ty1 := B
        ty2 := 1.0 - T
        ty3 := 1.0

        // useful vertex coordinates
        vx0 := 0.0
        vx1 := tx1 * tw
        vx2 := outerWidth  - right
        vx3 := outerWidth

        vy0 := 0.0
        vy1 := ty1 * th
        vy2 := outerHeight - top
        vy3 := outerHeight

        if (round) {
            vx0 = vx0 as Int
            vx1 = vx1 as Int
            vx2 = vx2 as Int
            vx3 = vx3 as Int

            vy0 = vy0 as Int
            vy1 = vy1 as Int
            vy2 = vy2 as Int
            vy3 = vy3 as Int
        }

        if (DEBUG) {
            "tx: #{tx0}, #{tx1}, #{tx2}, #{tx3}" println()
            "ty: #{ty0}, #{ty1}, #{ty2}, #{ty3}" println()
            "vx: #{vx0}, #{vx1}, #{vx2}, #{vx3}" println()
            "vy: #{vy0}, #{vy1}, #{vy2}, #{vy3}" println()
        }

        // external documentation may or may not be found at the following url:
        // https://twitter.com/fasterthanlime/status/554233636250460160
        build(22, |b|
            b vertex(tx0, ty0, vx0, vy0) // 0
            b vertex(tx0, ty1, vx0, vy1) // 1
            b vertex(tx1, ty0, vx1, vy0) // 2
            b vertex(tx1, ty1, vx1, vy1) // 3
            b vertex(tx2, ty0, vx2, vy0) // 4
            b vertex(tx2, ty1, vx2, vy1) // 5
            b vertex(tx3, ty0, vx3, vy0) // 6
            b vertex(tx3, ty1, vx3, vy1) // 7

            b vertex(tx3, ty2, vx3, vy2) // 8
            b vertex(tx2, ty1, vx2, vy1) // 9  = 5
            b vertex(tx2, ty2, vx2, vy2) // 10
            b vertex(tx1, ty1, vx1, vy1) // 11 = 3
            b vertex(tx1, ty2, vx1, vy2) // 12
            b vertex(tx0, ty1, vx0, vy1) // 13 = 1
            b vertex(tx0, ty2, vx0, vy2) // 14

            b vertex(tx0, ty3, vx0, vy3) // 15
            b vertex(tx1, ty2, vx1, vy2) // 16
            b vertex(tx1, ty3, vx1, vy3) // 17
            b vertex(tx2, ty2, vx2, vy2) // 18 = 10
            b vertex(tx2, ty3, vx2, vy3) // 19
            b vertex(tx3, ty2, vx3, vy2) // 20
            b vertex(tx3, ty3, vx3, vy3) // 21
        )
    }

}

