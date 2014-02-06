
// our stuff
import dye/[core, math, anim]
import dye/gritty/[shader, shaderlibrary, texture, vbo, vao]

// third-party stuff
import sdl2/[OpenGL]

/**
 * Generic 2D geometry class, VBO-backed, textured.
 */
TriGeom: class extends GlSpriteLike {

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

    upload: func (=numVertices, cb: Func (Float*)) {
        numBytes := numVertices * 4 * Float size

        if (capacity < numBytes) {
            capacity = numBytes
            if (data) {
                gc_free(data)
            }
            data = gc_malloc_atomic(numBytes)
            memset(data, 0, capacity)
            "just reallocated to #{capacity}B capacity" println()
        }
        cb(data)

        numElements := numVertices * 4
        vbo upload(numElements, data)

        "uploaded, #{numVertices} vertices, #{numElements} elements, data[0] = #{data[0]}" println()
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

