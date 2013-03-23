
// our stuff
import dye/[core, math, anim]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

// third-party stuff
import sdl2/[OpenGL]

use deadlogger
import deadlogger/[Log, Logger]

GlGridSprite: class extends GlDrawable implements GlAnimSource {

    texture: Texture
    texSize: Vec2
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    xnum, ynum: Int
    x := 0
    y := 0

    brightness := 1.0
    opacity := 1.0

    init: func (path: String, =xnum, =ynum) {
        texture = TextureLoader load(path)
        texSize = vec2(texture width, texture height)
        size = vec2(texture width / xnum, texture height / ynum)
    }

    draw: func (dye: DyeContext, modelView: Matrix4) {
        // FIXME: colors
        //glColor4f(brightness, brightness, brightness, opacity)

        // FIXME: drawing
        //dye withTexture(GL_TEXTURE_2D, texture id, ||
        //    self := this
        //    dye begin(GL_TRIANGLE_STRIP, ||
        //        rx := x
        //        ry := (ynum - 1) - y
        //        xFactor := x as Float / xnum as Float
        //        yFactor := y as Float / ynum as Float

        //        glTexCoord2f(rx * xFactor, ry * yFactor)
        //        glVertex2f(xFactor * -0.5, yFactor * -0.5)

        //        glTexCoord2f((rx + 1) * xFactor, ry * yFactor)
        //        glVertex2f(xFactor *  0.5, yFactor * -0.5)

        //        glTexCoord2f(rx * xFactor, (ry + 1) * yFactor)
        //        glVertex2f(xFactor * -0.5, yFactor *  0.5)

        //        glTexCoord2f((rx + 1) * xFactor, (ry + 1) * yFactor)
        //        glVertex2f(xFactor *  0.5, yFactor *  0.5)
        //    )
        //)
    }

    // implement GlAnimSource

    numFrames: func -> Int { xnum }
    getDrawable: func -> GlDrawable { this }
    frameOffset: func (offset: Int) {
        setFrame(x + offset)
    }
    setFrame: func (x: Int) {
        this x = x repeat(0, xnum)
    }
    currentFrame: func -> Int { x }

}

GlSprite: class extends GlDrawable {

    texSize: Vec2
    size: Vec2

    width: Float { get { size x } }
    height: Float { get { size y } }

    texWidth: Float { get { texSize x } }
    texHeight: Float { get { texSize y } }

    center := true

    color := Color white()
    opacity := 1.0

    texture: Texture
    program: ShaderProgram
    vao: VAO

    vbo: FloatVBO 
    data: Float[]

    /* Uniforms */
    texLoc, projLoc, modelLoc, colorLoc: Int

    logger := static Log getLogger(This name)

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
        mv := computeModelView(modelView)

        if (center) {
            mv = mv * Matrix4 newTranslate(width * -0.5, height * -0.5, 0.0)
        }

        draw(dye, mv)
    }

    rebuild: func {
        /*
         * vertex x, vertex y,
         * texcoord x, texcoord y
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
        glUniform4f(colorLoc, color R, color G, color B, opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)

        vao detach()
        program detach()
        texture detach()
    }

}


