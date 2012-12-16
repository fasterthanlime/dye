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

    set!: func (v: This) {
        x = v x
        y = v y
    }

    set!: func ~twofloats (px, py: Float) {
        x = px
        y = py
    }

    snap: func (size: Int) -> This {
        ix := round(x / size as Float) * size
        iy := round(y / size as Float) * size

        vec2(ix, iy)
    }

    snap!: func (size: Int) {
        set!(snap(size))
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

