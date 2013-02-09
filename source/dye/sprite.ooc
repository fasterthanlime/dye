
// our stuff
import dye/[core, math, anim]
import dye/gritty/[shader, texture, vbo]

// third-party stuff
import sdl2/[OpenGL]

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

    draw: func (dye: DyeContext) {
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

    brightness := 1.0
    opacity := 1.0

    texture: Texture
    program: ShaderProgram
    vbo: FloatVBO 
    data: Float[]
    texloc: Int
    colorloc: Int

    init: func (path: String) {
        texture = TextureLoader load(path)
        size = vec2(texture width, texture height)
        texSize = vec2(0, 0)
        texSize set!(size)

        vbo = FloatVBO new()
        rebuild()

        program = loadProgram()

        stride := 4 * Float size
        program vertexAttribPointer("texcoord", 2, GL_FLOAT, false, stride, 0 as Pointer)
        program vertexAttribPointer("position", 2, GL_FLOAT, false, stride, (2 * Float size) as Pointer)

        texloc = glGetUniformLocation(program id, "tex" toCString())
        colorloc = glGetUniformLocation(program id, "inColor" toCString())
        "texloc = %d, colorloc = %d" printfln(texloc, colorloc)
    }

    render: func (dye: DyeContext) {
        // FIXME: transformations
        //if (center) {
        //  glTranslatef(width * scale x * -0.5, height * scale y * -0.5, 0.0)

        super()
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

    draw: func (dye: DyeContext) {
        // FIXME: colors
        // glColor4f(brightness, brightness, brightness, opacity)

        // FIXME: texture
        //dye withTexture(GL_TEXTURE_2D, texture id, ||

        "Drawing" println()

        program use()

        glActiveTexture(GL_TEXTURE0)
        texture bind()
        glUniform1f(texloc, 0)

        vbo bind()
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)
        program vao detach()
    }

    loadProgram: func -> ShaderProgram {
        vertex := "
            #version 130

            in vec2 position;
            in vec2 texcoord;
            out vec2 coord;

            void main()
            {
                coord = texcoord;
                gl_Position = vec4(position * 0.01, 0.0, 1.0);
            }
        "

        fragment := "
            #version 130

            uniform vec4 inColor;
            uniform sampler2D tex;

            in vec2 coord;
            out vec4 outColor;

            void main()
            {
                outColor = texture2D(tex, coord);
            }
        "

        ShaderLoader loadProgram(vertex, fragment)
    }

}


