
// ours
use dye
import dye/[core, input, loop]

// third party
use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter, Filter, Level]

// sdk
import io/File

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
    loop: FixedLoop

    // adjustable things
    escQuits? := true

    init: func (=title, width := 800, height := 600, fullscreen := false, windowWidth := -1, windowHeight := -1) {
        setupLogging()

        dye = DyeContext new(width, height, title, fullscreen, windowWidth, windowHeight)
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

        loop = FixedLoop new(dye, fps)
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

        file := File new("app.log")
        file write("")

        fileHandler := FileHandler new(file path)
        fileHandler setFormatter(NiceFormatter new())
        Log root attachHandler(fileHandler)

        logger = Log getLogger(title)
    }

}

