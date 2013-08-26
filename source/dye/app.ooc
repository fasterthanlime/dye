
use dye
import dye/[core, input, loop]

use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter, Filter, Level]

/**
 * Class: App
 *
 * A simple app that sets up logging, a simple fixed loop and
 * exit events. Use that for short tests, not for serious applications.
 */
App: class {

    dye: DyeContext
    logger: Logger
    title: String

    // adjustable things
    escQuits? := true

    init: func (=title, width := 800, height := 600) {
        setupLogging()

        dye = DyeContext new(width, height, title)
        dye setClearColor(Color black())

        initEvents()
        setup()
    }

    initEvents: func {
        dye input onExit(||
            quit()
        )

        dye input onKeyPress(KeyCode ESC, |kp|
            if (escQuits?) {
                quit()
            }
        )
    }

    setup: func {
        // override
    }

    update: func {
        // override
    }

    run: func (fps: Float) {
        logger info("Welcome to %s, running at %.2fFPS", title, fps)
        logger info("Press ESC or close the window to exit")

        loop := FixedLoop new(dye, fps)
        loop run(||
            update()
        )
    }

    quit: func {
        dye quit()
        exit(0)
    }

    setupLogging: func {
        console := StdoutHandler new()
        console setFormatter(ColoredFormatter new(NiceFormatter new()))
        Log root attachHandler(console)

        logger = Log getLogger(title)
    }

}

