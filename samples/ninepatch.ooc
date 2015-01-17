
use dye
import dye/[core, sprite, math, app]

main: func (argc: Int, argv: CString*) {
    NinePatchTest new() run(60.0)
}

NinePatchTest: class extends App {

    padding := 128
    patch: GlNinePatch
    sprite: GlSprite
    counter := 0

    init: func {
        super("NinePatch test", 1280, 720)
        GlDrawable round = true
        dye setClearColor(Color new(20, 20, 20))
    }

    setup: func {
        patch = GlNinePatch new("object-contour.png")
        patch center = false
        patchSide := 18
        patch top = patchSide
        patch bottom = patchSide
        patch left = patchSide
        patch right = patchSide
        patch outerWidth  = 64
        patch outerHeight = 64
        patch pos set!(padding, padding)
        dye add(patch)

        sprite = GlSprite new("button-patch.png")
        sprite center = false
        sprite pos set!(padding + 256, padding)
        dye add(sprite)
    }

    update: func {
        size := dye input mousepos sub(padding, padding)
        patch outerWidth  = size x
        patch outerHeight = size y

        sprite scale set!(size x / sprite w, size y / sprite h)
    }

}


