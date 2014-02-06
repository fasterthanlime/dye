
// our stuff
import dye/[core, math, anim]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

// third-party stuff
import sdl2/[OpenGL]

/**
 * Generic 2D geometry class, VBO-backed, textured.
 */
Geometry: class extends GlSpriteLike {

    // number of bytes we can store
    capacity: Int

    // number of vertices
    numVertices: Int

    // 4 * numVertices - texcoord x, texcoord y, vertex x, vertex y
    data: Float*

    // opengl vertex buffer object
    vbo: FloatVBO

    // opengl vertex array object
    vao: VAO

    // opengl texture
    texture: Texture

    // shader uniforms
    texLoc, projLoc, modelLoc, colorLoc: Int

    // draw mode - triangles by default
    mode := GL_TRIANGLES

    init: func (=texture) {
        vbo = FloatVBO new()
        setProgram(ShaderLibrary getTexture())
    }

    setProgram: func (.program) {
        if (this program) {
            this program detach()
        }
        this program = program
        program use()

        if (vao) {
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

    build: func (.numVertices, cb: Func (GeomBuilder)) {
        upload(numVertices, |data|
            builder := GeomBuilder new(numVertices, data)
            cb(builder)
        )
    }

    upload: func (=numVertices, cb: Func (Float*)) {
        numBytes := numVertices * 4 * Float size

        if (capacity < numBytes) {
            capacity = numBytes
            if (data) {
                gc_free(data)
            }
            data = gc_malloc_atomic(numBytes)
            memset(data, 0, capacity)
        }
        cb(data)

        numElements := numVertices * 4
        vbo upload(numElements, data)
    }

    draw: func (pass: Pass, modelView: Matrix4) {
        program use()
        vao bind()

        glActiveTexture(GL_TEXTURE0)
        texture bind()
        glUniform1i(texLoc, 0)

        glUniformMatrix4fv(projLoc, 1, false, pass projectionMatrix pointer)
        glUniformMatrix4fv(modelLoc, 1, false, modelView pointer)

        // premultiply color by opacity
        glUniform4f(colorLoc,
            opacity * color R,
            opacity * color G,
            opacity * color B,
            opacity)

        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA)

        applyEffects(pass, modelView)

        glDrawArrays(mode, 0, numVertices)

        // texture detach()
        // vao detach()
        // program detach()
    }

}

GeomBuilder: class {

    numElements: Int
    index := 0
    data: Float*

    init: func (numVertices: Int, =data) {
        numElements = numVertices * 4
    }

    vec: func (x, y: Float) {
        if (index + 2 > numElements) {
            raise("GeomBuilder Overflow!")
        }
        data[index    ] = x
        data[index + 1] = y
        index += 2
    }

    vertex: func (texX, texY, vertX, vertY: Float) {
        if (index + 4 > numElements) {
            raise("GeomBuilder Overflow!")
        }
        data[index    ] = texX
        data[index + 1] = texY
        data[index + 2] = vertX
        data[index + 3] = vertY
        index += 4
    }

    quad6: func (quadX, quadY, quadWidth, quadHeight, texX, texY, texWidth, texHeight: Float) {
        vertex(texX           , texY            , quadX            , quadY)
        vertex(texX + texWidth, texY            , quadX + quadWidth, quadY)
        vertex(texX           , texY + texHeight, quadX            , quadY + quadHeight)

        vertex(texX + texWidth, texY + texHeight, quadX + quadWidth, quadY + quadHeight)
        vertex(texX + texWidth, texY            , quadX + quadWidth, quadY)
        vertex(texX           , texY + texHeight, quadX            , quadY + quadHeight)
    }

}

