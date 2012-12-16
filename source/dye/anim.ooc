
GlAnim: class extends GlGroup {

    current := 0

    frameDuration, counter: Int

    init: func (frameDuration := 4) {
        super()

        this frameDuration = frameDuration
        this counter = frameDuration
    }

    update: func (ticks := 1) {
        counter -= ticks

        if (counter <= 0) {
            current = (current + 1) % children size
            counter += frameDuration
        }
    }

    drawChildren: func {
        children get(current) render(dye)
    }

}

