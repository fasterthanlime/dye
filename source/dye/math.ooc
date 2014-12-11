
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

    neg: func -> This {
        new(-x, -y)
    }

    squaredNorm: func -> Float {
        x * x + y * y
    }

    normalize!: func {
        n := norm()
        if (n == 0.0) return // better 0 than NaN
        mul!(1.0 / n)
    }

    normalized: func -> This {
        v := clone()
        v normalize!()
        v
    }

    dist: func (v: This) -> Float {
        v sub(this) norm()
    }

    /**
     * Unit vector that has a certain angle - in radians
     */
    fromAngle: static func (radians: Float) -> This {
        new(cos(radians), sin(radians))
    }

    /**
     * Angle this vector makes with (0, 1) - in radians
     */
    angle: func -> Float {
        angle := atan2(y, x) as Float
        if (angle < 0) {
            angle += 2 * PI
        }
        angle
    }

    clone: func -> This { new(x, y) }

    mul: func (f: Float) -> This {
        c := clone()
        c mul!(f)
        c
    }

    mul!: func (f: Float) {
        x *= f
        y *= f
    }

    mul: func ~vec (v: This) -> This {
        c := clone()
        c mul!(v)
        c
    }

    mul!: func ~vec (v: This) {
        x *= v x
        y *= v y
    }

    set!: func ~self (v: This) {
        x = v x
        y = v y
    }

    set!: func (px, py: Float) {
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

    round: func -> Vec2i {
        Vec2i new(x as Int, y as Int)
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

    /// Returns a perpendicular vector. (90 degree rotation)
    perp: func -> This {
        new(-y, x)
    }

    /// Returns a perpendicular vector. (-90 degree rotation)
    rperp: func -> This {
        new(-y, x)
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

    cross: func (v: This) -> Float {
        x * v y - y * v x
    }

    lerp: func (target: This, alpha: Float) -> Vec2 {
        c := clone()
        c lerp!(target, alpha)
        c
    }

    lerp!: func (target: This, alpha: Float) {
        (x, y) = (x * (1 - alpha) + target x * alpha,
                  y * (1 - alpha) + target y * alpha)
    }

    lerpX!: func (target: Float, alpha: Float) {
        x = x * (1 - alpha) + target * alpha
    }

    lerpY!: func (target: Float, alpha: Float) {
        y = y * (1 - alpha) + target * alpha
    }

    clamp: func (bottomLeft, topRight: Vec2) -> This {
        v := vec2(this)
        v clamp!(bottomLeft, topRight)
        v
    }

    clamp!: func (bottomLeft, topRight: Vec2) {
        set!(
            x clamp(bottomLeft x, topRight x),
            y clamp(bottomLeft y, topRight y)
        )
    }

    inside?: func (bottomLeft, topRight: Vec2) -> Bool {
        x > bottomLeft x && \
        x < topRight x && \
        y > bottomLeft y && \
        y < topRight y
    }

    toString: func -> String {
        "(%.2f, %.2f)" format(x, y)
    }

    _: String { get { toString() } }

    equals?: func (v: This, epsilon: Float) -> Bool {
        dx := v x - x
        if (dx < -epsilon || dx > epsilon) return false

        dy := v y - y
        if (dy < -epsilon || dy > epsilon) return false

        true
    }

    /// Check if two vectors are equal. (Be careful when comparing floating point numbers!)
    equals?: func ~exact (v: This) -> Bool {
        x == v x && y == v y
    }

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

    set!: func ~self (v: This) {
        x = v x
        y = v y
        z = v z
    }

    set!: func ~vec2 (v: Vec2) {
        x = v x
        y = v y
    }

    set!: func (px, py, pz: Float) {
        x = px
        y = py
        z = pz
    }

    set!: func ~twofloats (px, py: Float) {
        x = px
        y = py
    }

    lerp!: func (target: This, alpha: Float) {
        (x, y, z) = (x * (1 - alpha) + target x * alpha,
                     y * (1 - alpha) + target y * alpha,
                     z * (1 - alpha) + target z * alpha)
    }

    toString: func -> String {
        "(%.2f, %.2f, %.2f)" format(x, y, z)
    }

    _: String { get { toString() } }

    equals?: func (v: This, epsilon: Float) -> Bool {
        dx := v x - x
        if (dx < -epsilon || dx > epsilon) return false

        dy := v y - y
        if (dy < -epsilon || dy > epsilon) return false

        dz := v z - z
        if (dz < -epsilon || dz > epsilon) return false

        true
    }

}

// cuz I'm lazy (number two)
vec3: func (x, y, z: Float) -> Vec3 { Vec3 new(x, y, z) }

Vec2i: class {

    x, y: Int

    init: func (=x, =y)

    clone: func -> This { new(x, y) }

    equals?: func (v: This) -> Bool {
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

    add!: func ~ints (x, y: Int) {
        this x += x
        this y += y
    }

    add!: func ~vec2i (v: This) {
        this x += v x
        this y += v y
    }

    add: func ~ints (x, y: Int) -> This {
        new(this x + x, this y + y)
    }

    add: func ~vec2i (v: This) -> This {
        new(this x + v x, this y + v y)
    }

    add: func ~vec2 (v: Vec2) -> Vec2 {
        vec2(v x + x as Float, v y + y as Float)
    }

    mul: func (f: Int) -> This {
        c := clone()
        c mul!(f)
        c
    }

    mul!: func (f: Int) {
        x *= f
        y *= f
    }

    mul: func ~vec (v: This) -> This {
        c := clone()
        c mul!(v)
        c
    }

    mul!: func ~vec (v: This) {
        x *= v x
        y *= v y
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

    clamp: func (bottomLeft, topRight: Vec2i) -> This {
        vec2i(
            x clamp(bottomLeft x, topRight x),
            y clamp(bottomLeft y, topRight y)
        )
    }

    _: String { get { toString() } }

}

operator == (v1, v2: Vec2i) -> Bool {
    v1 equals?(v2)
}

vec2i: func ~ints (x, y: Int) -> Vec2i { Vec2i new(x, y) }
vec2i: func ~vec2i (v: Vec2i) -> Vec2i { Vec2i new(v x, v y) }

extend Float {

    toRadians: func -> This {
        this * PI / 180.0
    }

    toDegrees: func -> This {
        this * 180.0 /  PI
    }

    repeat: func (min, max: This) -> This {
        if (max - min < 0) {
            raise("Float repeat(), invalid range: %.2f..%.2f" format(min, max))
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
            raise("Float clamp(), invalid range: %.2f..%.2f" format(min, max))
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

    lerp!: func@ (target, alpha: This) {
        this = this * (1.0 - alpha) + target * alpha
    }

    lerp: func (target, alpha: This) -> This {
        this * (1.0 - alpha) + target * alpha
    }

    lerpDegrees!: func@ (target, alpha: This) {
        a: Float = this
        b: Float = target repeat(0, 360)

        diff := a - b
        if (diff > 180.0 || diff < -180.0) {
            match {
                case (b > a) => a += 360.0
                case         => b += 360.0
            }
        }
        this = (a + ((b - a) as Float) * (alpha as Float)) repeat(0, 360)
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

    repeat!: func@ (min, max: This) {
        this = repeat(min, max)
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

    clamp!: func@ (min, max: This) {
        this = clamp(min, max)
    }

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
            1.0f, 0.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 1.0f
        ])
    }

    /**
     * Create a new translation matrix
     */
    newTranslate: static func (x, y, z: Float) -> This {
        new([
            1.0f,   0.0f,   0.0f,   0.0f,
            0.0f,   1.0f,   0.0f,   0.0f,
            0.0f,   0.0f,   1.0f,   0.0f,
            x,      y,      z,      1.0f
        ])
    }

    /**
     * Create a new rotation matrix around axis (1.0, 0.0, 0.0)
     *
     * :param: a is the angle in radians
     */
    newRotateX: static func (a: Float) -> This {

        /*
         * Source: http://stackoverflow.com/questions/3982418
         *
         * Converted by hand to column-major
         */
        c := a cos()
        s := a sin()

        new([
            1.0f,   0.0f,   0.0f,   0.0f,
            0.0f,   c,      s,      0.0f,
            0.0f,  -s,      c,      0.0f,
            0.0f,   0.0f,   0.0f,   1.0f
        ])
    }

    /**
     * Create a new rotation matrix around axis (0.0, 1.0, 0.0)
     *
     * :param: a is the angle in radians
     */
    newRotateY: static func (a: Float) -> This {

        /*
         * Source: http://stackoverflow.com/questions/3982418
         *
         * Converted by hand to column-major
         */
        c := a cos()
        s := a sin()

        new([
            c,      0.0f,  -s,      0.0f,
            0.0f,   1.0f,   0.0f,   0.0f,
            s,      0.0f,   c,      0.0f,
            0.0f,   0.0f,   0.0f,   1.0f
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
             c,     s,      0.0f,   0.0f,
            -s,     c,      0.0f,   0.0f,
            0.0f,   0.0f,   1.0f,   0.0f,
            0.0f,   0.0f,   0.0f,   1.0f
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
            x,    0.0f, 0.0f, 0.0f
            0.0f, y,    0.0f, 0.0f
            0.0f, 0.0f, z,    0.0f
            0.0f, 0.0f, 0.0f, 1.0f
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
            2.0f / w,       0.0f,            0.0f,          0.0f,
            0.0f,           2.0f / h,        0.0f,          0.0f,
            0.0f,           0.0f,           -2.0f / d,      0.0f,
            ((r + l) / -w), ((t + b) / -h), ((f + n) / -d), 1.0f
        ])
    }

    /**
     * Create a new perspective projection matrix
     *
     * Somehow similar to glOrtho
     */
    newPerspective: static func (left, right, bottom, top, _near, _far: Float) -> This {
        (l, r, b, t) := (left, right, bottom, top)
        (n, f) := (_near, _far)

        d := f - n // depth

        /*
         * Source: http://www.songho.ca/opengl/gl_projectionmatrix.html
         *
         * Converted by hand to column-major
         */
        new([
            n / r,         0.0f,               0.0f,           0.0f,
            0.0f,          n / t,              0.0f,           0.0f,
            0.0f,          0.0f,       (f + n) / -d,          -1.0f,
            0.0f,          0.0f,  -2.0f * f * n / d,           0.0f
        ])
    }

    /**
     * Multiply two matrices.
     *
     * This is a naive, unoptimized, O(n^3) function.
     */
    mul: final func (m2: This) -> This {
        m1 := this

        result := Float[16] new()

        m1v := m1 values data as Float*
        m2v := m2 values data as Float*
        rev := result data as Float*

        for (col in 0..4) {
            fourcol := col * 4
            for (row in 0..4) {
                rev[fourcol + row] = \
                    m1v[     row] * m2v[fourcol    ] + \
                    m1v[ 4 + row] * m2v[fourcol + 1] + \
                    m1v[ 8 + row] * m2v[fourcol + 2] + \
                    m1v[12 + row] * m2v[fourcol + 3]
            }
        }

        new(result)
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

    rowToString: func (i: Int) -> String {
        "[%5.5f, %5.5f, %5.5f, %5.5f]" format(values[i], values[i + 4], values[i + 8],  values[i + 12])
    }

    toString: func -> String {
        a := rowToString(0)
        b := rowToString(1)
        c := rowToString(2)
        d := rowToString(3)
        "#{a}\n#{b}\n#{c}\n#{d}"
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

    round!: func {
        raw := values data as Float*
        raw[12] = raw[12] as Int
        raw[13] = raw[13] as Int
        raw[14] = raw[14] as Int
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

    init: func ~floats (=xMin, =yMin, =xMax, =yMax)

    init: func ~size (width, height: Float) {
        xMin = width * -0.5f
        xMax = width * 0.5f
        yMin = height * -0.5f
        yMax = height * 0.5f
    }

    set!: func ~aabb (other: This) {
        xMin = other xMin
        xMax = other xMax
        yMin = other yMin
        yMax = other yMax
    }

    set!: func ~floats (=xMin, =yMin, =xMax, =yMax)

    add!: func ~vector (v: Vec2) {
        xMin += v x
        yMin += v y
        xMax += v x
        yMax += v y
    }

    add: func ~vectorCopy (v: Vec2) -> This {
        new(
            xMin + v x,
            yMin + v y,
            xMax + v x,
            yMax + v y
        )
    }

    center: func -> Vec2 {
        vec2(xMin + (xMax - xMin) * 0.5f, yMin + (yMax - yMin) * 0.5f)
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

    size: Vec2 { get {
        vec2(width, height)
    } }
}

/**
 * A 2D axis-aligned bounding box - with integers
 */
AABB2i: class {
    xMin, yMin, xMax, yMax: Int

    init: func

    init: func ~values (=xMin, =yMin, =xMax, =yMax)

    set!: func ~aabb (other: This) {
        xMin = other xMin
        xMax = other xMax
        yMin = other yMin
        yMax = other yMax
    }

    add!: func ~vector (v: Vec2i) {
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

    expand!: func ~vec (other: Vec2i) {
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
        "[[%d, %d], [%d, %d]]" format(xMin, yMin, xMax, yMax)
    }

    _: String { get { toString() } }

    width:  Int { get { xMax - xMin } }
    height: Int { get { yMax - yMin } }
}

/**
 * An RGB color
 */
Color: class {

    /* r, g, b = [0, 255] UInt8 */
    r, g, b: UInt8
    init: func (=r, =g, =b)

    /* R, G, B = [0.0, 1.0] Float */
    R: Float { get { r / 255.0f } }
    G: Float { get { g / 255.0f } }
    B: Float { get { b / 255.0f } }

    set!: func ~self (c: This) {
        r = c r
        g = c g
        b = c b
    }

    set!: func (=r, =g, =b)

    black: static func -> This { new(0, 0, 0) }
    white: static func -> This { new(255, 255, 255) }
    red: static func -> This { new(255, 0, 0) }
    green: static func -> This { new(0, 255, 0) }
    blue: static func -> This { new(0, 0, 255) }

    toString: func -> String {
        "(%d, %d, %d)" format(r, g, b)
    }

    _: String { get { toString() } }

    lighten: func (factor: Float) -> This {
        new(r as Float / factor, g as Float / factor, b as Float / factor)
    }

    mul: func (factor: Float) -> This {
        new(r * factor, g * factor, b * factor)
    }

}

PolyUtils: class {

    sanitize: static func (vecs: Vec2*, count: Int) {
        valid := true

        for (i in 0..count) {
            a := vecs[i]
            b := vecs[(i + 1) % count]
            c := vecs[(i + 2) % count]

            if (b sub(a) cross(c sub(a)) > 0.0f) {
                valid = false
                break
            }
        }

        if (!valid) {
            // reveeeeeeeeerse o/
            bytes := Pointer size * count
            copy := gc_malloc(bytes) as Vec2*
            memcpy(copy, vecs, bytes)

            for (i in 0..count) {
                j := count - 1 - i
                vecs[i] = copy[j]
            }
        }
    }

}

