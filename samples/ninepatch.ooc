
use dye
import dye/[core, sprite, math, app]

main: func (argc: Int, argv: CString*) {
    NinePatchTest new() run(60.0)
}

NinePatchTest: class extends App {

    padding := 128
    patch: NinePatch
    sprite: Sprite
    counter := 0

    init: func {
        super("NinePatch test", 1280, 720)
        Drawable round = true
        dye setClearColor(Color new(20, 20, 20))
    }

    setup: func {
        patch = NinePatch new("images/object-contour.png")
        patch center = false
        patchSide := 18
        patch top = patchSide
        patch bottom = patchSide
        patch left = patchSide
        patch right = patchSide
        patch outerWidth  = 64
        patch outerHeight = 64
        patch pos = (padding, padding) as Vec2
        dye add(patch)

        sprite = Sprite new("images/button-patch.png")
        sprite center = false
        sprite pos = (padding + 256, padding) as Vec2
        dye add(sprite)
    }

    update: func {
        size := dye input mousepos sub(padding, padding)
        patch outerWidth  = size x
        patch outerHeight = size y

        sprite scale = (size x / sprite w, size y / sprite h) as Vec2
    }

}


