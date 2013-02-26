
// libs deps
import math

EPSILON := 0.001

/**
 * A 2-dimensional floating point vector
 */
Vec2: class {

    x, y: Float

    init: func (=x, =y)

    norm: func -> Float {
        sqrt(squaredNorm())
    }

    squaredNorm: func -> Float {
        x * x + y * y
    }

    normalized: func -> This {
        n := norm()
        if (n == 0) return this // better 0 than NaN...
        mul(1.0 / n)
    }

    dist: func (v: This) -> Float {
        v sub(this) norm()
    }

    angle: func -> Double {
        atan2(y, x)
    }

    clone: func -> This { new(x, y) }

    mul: func (f: Float) -> This {
        new(x * f, y * f)
    }

    mul!: func (f: Float) -> This {
        set!(mul(f))
    }

    set!: func (v: This) {
        x = v x
        y = v y
    }

    set!: func ~twofloats (px, py: Float) {
        x = px
        y = py
    }

    zero?: func -> Bool {
        x == 0.0 && y == 0.0
    }

    unit?: func -> Bool {
        x == 1.0 && y == 1.0
    }

    snap: func (size: Int) -> This {
        ix := ceil(- 0.5 + (x / size as Float)) * size
        iy := ceil(- 0.5 + (y / size as Float)) * size

        vec2(ix, iy)
    }

    snap!: func (size: Int) {
        set!(snap(size))
    }

    snap: func ~rect (size: This, gridSize: Int) -> This {
        halfSize := vec2(size x * 0.5, - size y * 0.5)
        vec2(this sub(halfSize) snap(gridSize) add(halfSize))
    }

    getColRow: func (gridSize: Int) -> Vec2i {
        col := ceil(- 0.5 + (x / gridSize as Float))
        row := ceil(- 0.5 + (y / gridSize as Float))
        vec2i(col, row)
    }

    sub: func (v: This) -> This {
        new(x - v x, y - v y)
    }

    sub!: func (v: This) {
        x -= v x
        y -= v y
    }

    sub!: func ~floats (px, py: Float) {
        x -= px
        y -= py
    }

    add: func (v: This) -> This {
        new(x + v x, y + v y)
    }

    add: func ~floats (px, py: Float) -> This {
        new(x + px, y + py)
    }

    sub: func ~floats (px, py: Float) -> This {
        new(x - px, y - py)
    }

    add!: func (v: This) {
        x += v x
        y += v y
    }

    add!: func ~floats (px, py: Float) {
    x += px
    y += py
    }

    perp: func -> This {
        new(y, -x)
    }

    projected: func (v: This) -> This {
        p := clone()
        p project!(v)
        p
    }
   
    project!: func (v: This) {
        v = v normalized()
        d := dot(v)
        (x, y) = (v x * d, v y * d)
    }

    dot: func (v: This) -> Float {
        x * v x + y * v y
    }

    interpolate!: func (target: This, alpha: Float) {
        (x, y) = (x * (1 - alpha) + target x * alpha,
                  y * (1 - alpha) + target y * alpha)
    }

    interpolateX!: func (target: Float, alpha: Float) {
        x = x * (1 - alpha) + target * alpha
    }

    isubnterpolateY!: func (target: Float, alpha: Float) {
        y = y * (1 - alpha) + target * alpha
    }
    toString: func -> String {
        "(%.2f, %.2f)" format(x, y)
    }

    _: String { get { toString() } }

}

// cuz I'm lazy
vec2: func (x, y: Float) -> Vec2 { Vec2 new(x, y) }
vec2: func ~square (xy: Float) -> Vec2 { Vec2 new(xy, xy) }
vec2: func ~clone (v: Vec2) -> Vec2 { Vec2 new(v x, v y) }
vec: func ~two (x, y: Float) -> Vec2 { Vec2 new(x, y) }

/**
 * A 3-dimensional vector class with a few
 * utility things.
 *
 * I've never been good at math
 */
Vec3: class {

    x, y, z: Float

    init: func (=x, =y, =z)

    norm: func -> Float {
        sqrt(squaredNorm())
    }

    squaredNorm: func -> Float {
        x * x + y * y + z * z
    }

    set!: func (v: This) {
        x = v x
        y = v y
        z = v z
    }

    set!: func ~vec2 (v: Vec2) {
        x = v x
        y = v y
    }

    set!: func ~threefloats (px, py, pz: Float) {
        x = px
        y = py
        z = pz
    }

    set!: func ~twofloats (px, py: Float) {
        x = px
        y = py
    }

    interpolate: func (target: This, alpha: Float) {
        (x, y, z) = (x * (1 - alpha) + target x * alpha,
                     y * (1 - alpha) + target y * alpha,
                     z * (1 - alpha) + target z * alpha)
    }

    toString: func -> String {
        "(%.2f, %.2f, %.2f)" format(x, y, z)
    }

    _: String { get { toString() } }

}

// cuz I'm lazy (number two)
vec3: func (x, y, z: Float) -> Vec3 { Vec3 new(x, y, z) }

Vec2i: class {

    x, y: Int

    init: func (=x, =y) {
    }

    equals: func (v: This) -> Bool {
        (x == v x && y == v y)
    }

    set!: func ~twoints (x, y: Int) {
        this x = x
        this y = y
    }

    set!: func ~vec2i (v: This) {
        this x = v x
        this y = v y
    }

    div: func (i: Int) -> This {
        new(x / i, y / i)
    }

    add: func ~vec2 (v: Vec2) -> Vec2 {
        vec2(v x + x as Float, v y + y as Float)
    }

    toString: func -> String {
        "(%d, %d)" format(x, y)
    }

    toVec2: func -> Vec2 {
        vec2(x, y)
    }

    /**
     * :return: the y / x ratio, as Float
     */
    ratio: func -> Float {
        y as Float / x as Float
    }

    _: String { get { toString() } }

}

operator == (v1, v2: Vec2i) -> Bool {
    v1 equals(v2)
}

vec2i: func (x, y: Int) -> Vec2i { Vec2i new(x, y) }

extend Float {

    toRadians: func -> This {
        this * PI / 180.0
    }

    toDegrees: func -> This {
        this * 180.0 /  PI
    }

}

extend Int {

    repeat: func (min, max: This) -> This {
        if (max - min < 0) {
            Exception new("Int repeat(), invalid range: %d..%d" format(min, max)) throw()
        }

        number := this
        if (number < min) {
            number += (max - min)
        }

        if (number >= max) {
            number -= (max - min)
        }
        number
    }

    clamp: func (min, max: This) -> This {
        if (max - min < 0) {
            Exception new("Int clamp(), invalid range: %d..%d" format(min, max)) throw()
        }

        number := this
        if (number < min) {
            number = min
        }

        if (number > max) {
            number = max
        }
        number
    }

}


/**
 * A 4x4 matrix, mostly used for transformations
 */
Matrix4: class {

    /** 16 floats, column-major format */
    values: Float[]

    /**
     * Initialize from a 16-floats array
     */
    init: func (=values) {
        _checkSize(values)
    }

    transpose: func -> This {
        new([
            values[ 0], values[ 4], values[ 8], values[12]
            values[ 1], values[ 5], values[ 9], values[13]
            values[ 2], values[ 6], values[10], values[14]
            values[ 3], values[ 7], values[11], values[15]
        ])
    }

    get: func (column, row: Int) -> Float {
        values[column * 4 + row]
    }

    set: func (column, row: Int, value: Float) {
        values[column * 4 + row] = value
    }

    /**
     * Create a new identity matrix
     */
    newIdentity: static func -> This {
        new([
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0
        ])
    }

    /**
     * Create a new translation matrix
     */
    newTranslate: static func (x, y, z: Float) -> This {
        new([
            1.0,    0.0,    0.0,    0.0,
            0.0,    1.0,    0.0,    0.0,
            0.0,    0.0,    1.0,    0.0,
            x,      y,      z,      1.0 
        ])
    }

    /**
     * Create a new rotation matrix around axis (0.0, 0.0, 1.0)
     * 
     * :param: a is the angle in radians
     */
    newRotateZ: static func (a: Float) -> This {

        /*
         * Source: http://stackoverflow.com/questions/3982418
         *
         * Converted by hand to column-major
         */
        c := a cos()
        s := a sin()

        new([
             c,  s,   0,   0,
            -s,  c,   0,   0,
            0,   0,   1,   0,
            0,   0,   0,   1
        ])
    }

    /**
     * Create a new scaling matrix
     */
    newScale: static func (x, y, z: Float) -> This {
        /*
         * Source: http://en.wikipedia.org/wiki/Transformation_matrix#Scaling
         * 
         * Beautiful, it's the same in row-major and column-major :D
         * ie. m transposed() == m
         */

        new([
            x, 0, 0, 0
            0, y, 0, 0
            0, 0, z, 0
            0, 0, 0, 1
        ])
    }

    /**
     * Create a new orthographic projection matrix
     *
     * Somehow similar to glOrtho
     */
    newOrtho: static func (left, right, bottom, top, _near, _far: Float) -> This {
        (l, r, b, t) := (left, right, bottom, top)
        (n, f) := (_near, _far)

        w := r - l // width
        h := t - b // height
        d := f - n // depth

        /*
         * Source: http://www.songho.ca/opengl/gl_projectionmatrix.html
         *
         * Converted by hand to column-major
         */
        new([
            2.0 / w,        0.0,             0.0,           0.0,
            0.0,            2.0 / h,         0.0,           0.0,
            0.0,            0.0,            -2.0 / d,       0.0,
            ((r + l) / -w), ((t + b) / -h), ((f + n) / -d), 1.0
        ])
    }

    /**
     * Multiply two matrices.
     *
     * This is a naive, unoptimized, O(n^3) function.
     */
    mul: func (m2: This) -> This {
        m1 := this
        res := Float[16] new()

        for (row in 0..4) {
            for (col in 0..4) {
                product := 0.0

                for (inner in 0..4) {
                    product += m1 values[inner * 4 + row] * m2 values[col * 4 + inner]
                }
                res[col * 4 + row] = product
            }
        }

        new(res)
    }

    /**
     * Return a pointer to the raw data - suitable to be passed
     * as an OpenGL uniform, for example.
     */
    pointer: Float* {
        get {
            values data
        }
    }

    toString: func -> String {
"[[%5.5f], [%5.5f], [%5.5f], [%5.5f] 
 [%5.5f], [%5.5f], [%5.5f], [%5.5f] 
 [%5.5f], [%5.5f], [%5.5f], [%5.5f] 
 [%5.5f], [%5.5f], [%5.5f], [%5.5f]]" format(
         values[0], values[4], values[8],  values[12], 
         values[1], values[5], values[9],  values[13], 
         values[2], values[6], values[10], values[14], 
         values[3], values[7], values[11], values[15])
    }

    _: String {
        get {
            toString()
        }
    }

    _checkSize: static func (m: Float[]) {
        if (m length != 16) {
            MatrixException new(This name, "Matrix4 initializers should take 16 floats, not %d" \
                format(m length)) throw()
        }
    }

}

operator * (m1, m2: Matrix4) -> Matrix4 {
    m1 mul(m2) 
}

MatrixException: class extends Exception {

    init: func (origin: String, msg: String) {
        super(origin, msg)
    }

}

/**
 * A 2D axis-aligned bounding box.
 */
AABB2: class {
    xMin, yMin, xMax, yMax: Float

    init: func
    
    init: func ~values (=xMin, =yMin, =xMax, =yMax)

    set!: func ~aabb (other: AABB2) {
        xMin = other xMin
        xMax = other xMax
        yMin = other yMin
        yMax = other yMax
    }

    add!: func ~vector (v: Vec2) {
        xMin += v x
        yMin += v y
        xMax += v x
        yMax += v y
    }

    expand!: func ~aabb (other: This) {
        if (other xMin < xMin) {
            xMin = other xMin
        }

        if (other yMin < yMin) {
            yMin = other yMin
        }

        if (other xMax > xMax) {
            xMax = other xMax
        }

        if (other yMax > yMax) {
            yMax = other yMax
        }
    }

    expand!: func ~vec (other: Vec2) {
        if (other x < xMin) {
            xMin = other x
        }

        if (other y < yMin) {
            yMin = other y
        }

        if (other x > xMax) {
            xMax = other x
        }

        if (other y > yMax) {
            yMax = other y
        }
    }

    toString: func -> String {
        "[[%.2f, %.2f], [%.2f, %.2f]]" format(xMin, yMin,
            xMax, yMax)
    }

    _: String { get { toString() } }

    width:  Float { get { xMax - xMin } }
    height: Float { get { yMax - yMin } }
}

extend Int {

    nextPowerOfTwo: func -> This {
        in := this - 1

        in |= in >> 16
        in |= in >> 8
        in |= in >> 4
        in |= in >> 2
        in |= in >> 1

        in + 1
    }

}

