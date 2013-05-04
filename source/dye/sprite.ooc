
// our stuff
import dye/[core, math, anim]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

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

    center := true

    texture: Texture
    program: ShaderProgram
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
        program = ShaderLibrary getTexture()

        vao = VAO new(program)
        stride := 4 * Float size
        vao add("TexCoordIn", 2, GL_FLOAT, false, stride, 0 as Pointer)
        vao add("Position", 2, GL_FLOAT, false, stride, (2 * Float size) as Pointer)

        texLoc = program getUniformLocation("Texture")
        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")

        setTexture(texture)
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
        vbo bind()
        program use()
        vao bind()

        glActiveTexture(GL_TEXTURE0)
        texture bind()
        glUniform1f(texLoc, 0)

        glUniformMatrix4fv(projLoc, 1, false, dye projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        vao detach()
        program detach()
        texture detach()
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

    center := true

    texture: Texture
    program: ShaderProgram
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
        program = ShaderLibrary getGridTexture()

        vao = VAO new(program)
        stride := 4 * Float size
        vao add("TexCoordIn", 2, GL_FLOAT, false, stride, 0 as Pointer)
        vao add("Position", 2, GL_FLOAT, false, stride, (2 * Float size) as Pointer)

        texLoc = program getUniformLocation("Texture")
        projLoc = program getUniformLocation("Projection")
        modelLoc = program getUniformLocation("ModelView")
        colorLoc = program getUniformLocation("InColor")
        gridLoc = program getUniformLocation("InGrid")

        setTexture(texture)
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
        vbo bind()
        program use()
        vao bind()

        glActiveTexture(GL_TEXTURE0)
        texture bind()
        glUniform1f(texLoc, 0)

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

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        vao detach()
        program detach()
        texture detach()
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

