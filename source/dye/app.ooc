
// ours
use dye
import dye/[core, math, input, loop]

// third party
use deadlogger
import deadlogger/[Log, Logger, Handler, Formatter, Filter, Level]

// sdk
import io/File

/**
 * A simple app that sets up logging, a simple fixed loop and
 * exit events. Use that for short tests, not for serious applications.
 */
App: class {

    dye: Context
    title: String
    loop: FixedLoop

    // just logger things (TM)
    logger: Logger
    console: StdoutHandler
    fileHandler: FileHandler

    // adjustable things
    escQuits? := true

    showTiming := false

    init: func (=title, width := 800, height := 600, fullscreen := false, windowWidth := -1, windowHeight := -1) {
        setupLogging()

        dye = Context new(width, height, title, fullscreen, windowWidth, windowHeight)
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
            if (showTiming) {
                dye setTitle("#{title} | #{loop timingInfo}")
            }
            update()
        )
    }

    quit: func {
        dye quit()
        exit(0)
    }

    setupLogging: func {
        console = StdoutHandler new()
        console setFormatter(ColoredFormatter new(NiceFormatter new()))
        Log root attachHandler(console)

        file := File new("app.log")
        file write("")

        fileHandler = FileHandler new(file path)
        fileHandler setFormatter(NiceFormatter new())
        Log root attachHandler(fileHandler)

        logger = Log getLogger(title)
    }

    silence: func {
        Log root detachHandler(console)
    }

}

