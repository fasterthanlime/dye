
use dye
import dye/[core, input, loop]

use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter, Filter, Level]

/**
 * A simple app that sets up logging, a simple fixed loop and
 * exit events. Use that for short tests, not for serious applications.
 */
App: class {

    dye: DyeContext
    logger: Logger
    title: String

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
            quit()
        )
    }

    setup: func {
        // override
    }

    body: func {
        // override
    }

    run: func (fps: Float) {
        logger info("Welcome to %s, running at 2FPS", title)
        logger info("Press ESC or close the window to exit")

        loop := FixedLoop new(dye, fps)
        loop run(||
            body()
        )
    }

    quit: func {
        dye quit()
        exit(0)
    }

    setupLogging: func {
        console := StdoutHandler new()
        console setFormatter(NiceFormatter new())
        Log root attachHandler(console)

        logger = Log getLogger(title)
    }

}

