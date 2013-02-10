// libs deps
import math

EPSILON := 0.001

/**
 * A 2-dimensional vector class with a few
 * utility things.
 *
 * I've never been good at math
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

    /* 16 floats, row-major format */
    data: Float[]

    init: func (=data) {
        
    }

    /**
     * Create a new orthographic projection matrix
     *
     * Somehow similar to glOrtho
     */
    ortho: func (left, right, bottom, top, near, far: Float) {
        (l, r, b, t) := (left, right, bottom, top)
        (n, f) := (near, far)

        w := r - l // width
        h := t - b // height
        d := f - n // depth

        /*
         * Source: http://www.songho.ca/opengl/gl_projectionmatrix.html
         */
        new([
            2.0 / w,     0.0,        0.0,      (r + l) / -w,
            0.0,         2.0 / h,    0.0,      (t + b) / -h,
            0.0,         0.0,       -2.0 / d,  (f + n) / -d,
            0.0,         0.0,        0.0,      1.0
        ])
    }

}

