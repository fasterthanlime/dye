
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

