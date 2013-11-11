
// our stuff
import dye/[core, math, anim]
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
GlSprite: class extends GlSpriteLike {

    texSize: Vec2
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    texWidth: Float { get { texSize x } }
    texHeight: Float { get { texSize y } }

    texture: Texture
    vao: VAO

    vbo: FloatVBO 
    data: Float[]

    /* Uniforms */
    texLoc, projLoc, modelLoc, colorLoc: Int

    init: func ~fromPath (path: String) {
        init(TextureLoader load(path))
    }
    
    init: func ~fromTex (.texture) {
        vbo = FloatVBO new()
        setTexture(texture)
        setProgram(ShaderLibrary getTexture())
    }

    setProgram: func (.program) {
        if (this program) {
            this program detach()
        }
        this program = program
        program use()

        if (vao) {
            vao delete()
            vao = null
        }

        vao = VAO new(program)
        stride := 4 * Float size
        vao add(vbo, "TexCoordIn", 2, GL_FLOAT, false,
            stride, 0 as Pointer)
        vao add(vbo, "Position", 2, GL_FLOAT, false,
            stride,(2 * Float size) as Pointer)

        texLoc = program getUniformLocation("Texture")
        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
    }

    setTexture: func ~tex (=texture) {
        size = vec2(texture width, texture height)
        texSize = vec2(0, 0)
        texSize set!(size)
        rebuild()
    }

    setTexture: func ~path (path: String) {
        setTexture(TextureLoader load(path))
    }

    render: func (dye: DyeContext, modelView: Matrix4) {
        if (!visible) return

        mv := computeModelView(modelView)

        if (center) {
            mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        }

        draw(dye, mv)
    }

    rebuild: func {
        /*
         * texcoord x, texcoord y,
         * vertex x, vertex y
         */
        data = [
            0.0, 0.0,
            0.0, 0.0,

            1.0, 0.0,
            width, 0.0,

            0.0, 1.0,
            0.0, height,

            1.0, 1.0,
            width, height
        ]

        vbo bind()
        vbo data(data)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        program use()
        vao bind()

        glActiveTexture(GL_TEXTURE0)
        texture bind()
        glUniform1i(texLoc, 0)

        glUniformMatrix4fv(projLoc, 1, false, dye projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        applyEffects(dye, modelView)

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        texture detach()
        vao detach()
        program detach()
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
GlGridSprite: class extends GlSpriteLike implements GlAnimSource {

    xnum, ynum: Int
    x := 0
    y := 0

    texSize: Vec2
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    texture: Texture
    vao: VAO

    vbo: FloatVBO
    data: Float[]

    /* Uniforms */
    texLoc, projLoc, modelLoc, colorLoc, gridLoc: Int

    init: func ~fromPath (path: String, .xnum, .ynum) {
        init(TextureLoader load(path), xnum, ynum)
    }

    init: func ~fromTex (.texture, =xnum, =ynum) {
        vbo = FloatVBO new()
        setTexture(texture)
        setProgram(ShaderLibrary getGridTexture())
    }

    setProgram: func (.program) {
        if (this program) {
            this program detach()
        }
        this program = program
        program use()

        if (vao) {
            vao delete()
            vao = null
        }

        vao = VAO new(program)
        stride := 4 * Float size
        vao add(vbo, "TexCoordIn", 2, GL_FLOAT, false,
            stride, 0 as Pointer)
        vao add(vbo, "Position", 2, GL_FLOAT, false,
            stride, (2 * Float size) as Pointer)

        texLoc = program getUniformLocation("Texture")
        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
        gridLoc = program getUniformLocation("InGrid")
    }

    setTexture: func ~tex (=texture) {
        size = vec2(texture width / xnum, texture height / ynum)
        texSize = vec2(texture width, texture height)
        rebuild()
    }

    setTexture: func ~path (path: String) {
        setTexture(TextureLoader load(path))
    }

    render: func (dye: DyeContext, modelView: Matrix4) {
        if (!visible) return

        mv := computeModelView(modelView)

        if (center) {
            mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        }

        draw(dye, mv)
    }

    rebuild: func {
        /*
         * texcoord x, texcoord y,
         * vertex x, vertex y
         */
        data = [
            0.0, 0.0,
            0.0, 0.0,

            1.0, 0.0,
            width, 0.0,

            0.0, 1.0,
            0.0, height,

            1.0, 1.0,
            width, height
        ]

        vbo bind()
        vbo data(data)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        program use()
        vao bind()

        glActiveTexture(GL_TEXTURE0)
        texture bind()
        glUniform1i(texLoc, 0)

        glUniformMatrix4fv(projLoc, 1, false, dye projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        texCellWidth :=  1.0 / xnum as Float
        texCellHeight := 1.0 / ynum as Float

        glUniform4f(gridLoc, x as Float, (ynum - 1 - y) as Float, texCellWidth, texCellHeight)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        applyEffects(dye, modelView)

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        texture detach()
        vao detach()
        program detach()
    }

    // implement GlAnimSource

    numFrames: func -> Int { xnum }
    getDrawable: func -> GlSpriteLike { this }
    frameOffset: func (offset: Int) {
        setFrame(x + offset)
    }
    setFrame: func (x: Int) {
        this x = x repeat(0, xnum)
    }
    currentFrame: func -> Int { x }

}

