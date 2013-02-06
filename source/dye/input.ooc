
// third-party stuff
use deadlogger
import deadlogger/Log

use sdl2
import sdl2/[Core, Event]

import dye/[math, core, fbo]

// sdk stuff
import structs/[ArrayList]

/**
 * Manage input events such as keyboard & mouse
 */
Input: abstract class {

    logger := static Log getLogger(This name)

    listeners := ArrayList<Listener> new()

    mousepos: Vec2 {
        get { getMousePos() }
    }

    getMousePos: abstract func -> Vec2

    enabled := true

    unsubscribe: func (l: Listener) -> Bool {
        listeners remove(l)
    }

    /**
     * Register for an event listener. You can
     * then match on its type to see which event
     * it is.
     */
    onEvent: func (cb: Func(LEvent)) -> Listener {
        listener := Listener new(cb)
        listeners add(listener)
        listener
    }

    onWindowSizeChange: func (cb: Func (Int, Int)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case wscv: WindowSizeChanged => cb(wscv x, wscv y)
            }
        )
    }

    onExit: func (cb: Func) -> Listener {
        onEvent(|ev|
            match (ev) {
                case xv: ExitEvent => cb()
            }
        )
    }

    onKeyPress: func ~any (cb: Func (KeyPress)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case kp: KeyPress => 
                    cb(kp)
            }
        )
    }

    onKeyPress: func (scancode: Int, cb: Func (KeyPress)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case kp: KeyPress => 
                    if(kp scancode == scancode) cb(kp)
            }
        )
    }

    onKeyRelease: func ~any (cb: Func (KeyRelease)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case kr: KeyRelease => 
                    cb(kr)
            }
        )
    }

    onKeyRelease: func (scancode: Int, cb: Func (KeyRelease)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case kr: KeyRelease => 
                    if(kr scancode == scancode) cb(kr)
            }
        )
    }

    onMousePress: func (which: UInt, cb: Func (MousePress)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case mp: MousePress =>
                    if(mp button == which) cb(mp)
            }
        )
    }

    onMouseRelease: func (which: UInt, cb: Func (MouseRelease)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case mr: MouseRelease =>
                    if(mr button == which) cb(mr)
            }
        )
    }

    onMouseMove: func (cb: Func (MouseMotion)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case mm: MouseMotion =>
                    cb(mm)
            }
        )
    }

    onMouseDrag: func (which: UInt, cb: Func (MouseMotion)) -> Listener {
        onEvent(|ev|
            match (ev) {
                case mm: MouseMotion =>
                    if(isButtonPressed(which)) {
                        // it's a drag!
                        cb(mm)
                    }
            }
        )
    }

    /**
     * Return the state of a key (true = pressed,
     * false = released) at any time.
     */
    isPressed: abstract func (keyval: Int) -> Bool

    isButtonPressed: abstract func (button: Int) -> Bool

    sub: func -> SubInput {
        SubInput new(this)
    }

    nuke: func {
        // not much to do here
    }

    //---------------
    // private stuff
    //---------------

    _notifyListeners: func (ev: LEvent) {
        if (!enabled) return

        for(l in listeners) {
            l cb(ev)

            if (ev consumed) {
                break
            }
        }
    }

}

/**
 * Input subordinate to another input
 */
SubInput: class extends Input {

    own: Listener
    parent: Input

    init: func (=parent) {
        own = parent onEvent(|ev|
            _notifyListeners(ev)
        )
    }

    isPressed: func (keyval: Int) -> Bool {
        parent isPressed(keyval)
    }

    isButtonPressed: func (button: Int) -> Bool {
        parent isButtonPressed(button)
    }

    getMousePos: func -> Vec2 {
        parent getMousePos()
    }

    nuke: func {
        parent unsubscribe(own)
    }

}

/**
 * Input implement for SDL
 */
SdlInput: class extends Input {

    dye: DyeContext
    logger := static Log getLogger(This name)

    MAX_KEY := static 65536
    keyState: Bool*

    MAX_BUTTON := static 6
    buttonState: Bool*

    debug := false

    _mousepos := vec2(0.0, 0.0)

    init: func (=dye) {
        keyState = gc_malloc(Bool size * MAX_KEY)
        buttonState = gc_malloc(Bool size * MAX_BUTTON)

        logger info("Input system initialized")
    }

    isPressed: func (scancode: Int) -> Bool {
        if (scancode >= MAX_KEY) {
            return false
        }
        keyState[scancode]
    }

    isButtonPressed: func (button: Int) -> Bool {
        if (button >= MAX_BUTTON) {
            return false
        }
        buttonState[button]
    }

    disconnect: func {
        // useless, we'll just stop polling.
    }

    // --------------------------------
    // private functions below
    // --------------------------------

    _poll: func {
        event: SdlEvent

        while(SdlEvent poll(event&)) {
            match (event type) {
                case SDL_KEYDOWN =>
                    _keyPressed (event key keysym sym, event key keysym scancode)
                case SDL_KEYUP   =>
                    _keyReleased(event key keysym sym, event key keysym scancode)
                case SDL_MOUSEBUTTONUP   =>
                    _mouseReleased(event button button)
                case SDL_MOUSEBUTTONDOWN =>
                    _mousePressed (event button button)
                case SDL_MOUSEMOTION =>
                    _mouseMoved (event motion x, event motion y)
                case SDL_QUIT =>
                    _quit()
                case SDL_WINDOWEVENT =>
                    match (event window event) {
                        case SDL_WINDOWEVENT_SIZE_CHANGED =>
                            _windowSizeChanged (event window data1, event window data2)
                    }
            }
        }
    }

    _quit: func () {
        if(debug) {
            logger debug("Requested exit")
        }
        _notifyListeners(ExitEvent new())
    }

    _keyPressed: func (keycode, scancode: Int) {
        if(debug) {
            logger debug("Key pressed! code %d", scancode)
        }
        if (scancode < MAX_KEY) {
            keyState[scancode] = true
            _notifyListeners(KeyPress new(keycode, scancode))
        }
    }

    _keyReleased: func (keycode, scancode: Int) {
        if (scancode < MAX_KEY) {
            keyState[scancode] = false
            _notifyListeners(KeyRelease new(keycode, scancode))
        }
    }

    _mouseMoved: func (x, y: Int) {
        _mousepos set!(x, dye windowSize y - y)
        _notifyListeners(MouseMotion new(_mousepos))
    }

    _mousePressed: func (button: Int) {
        if(debug) {
            logger debug("Mouse pressed at %s", _mousepos _)
        }
        buttonState[button] = true
        _notifyListeners(MousePress new(_mousepos, button))
    }

    _mouseReleased: func (button: Int) {
        if(debug) {
            logger debug("Mouse released at %s", _mousepos _)
        }
        buttonState[button] = false
        _notifyListeners(MouseRelease new(_mousepos, button))
    }

    _windowSizeChanged: func (x, y: Int) {
        if(debug) {
            logger debug("Window size changed to %dx%d", x, y)
        }
        _notifyListeners(WindowSizeChanged new(x, y))
    }

    getMousePos: func -> Vec2 {
        if (dye size == dye windowSize || (!dye fbo)) {
            // all good, no transformation to make
            _mousepos
        } else {
            // in this case, windowSize is bigger than size
            // we have two things to account for: 1) scaling
            // 2) offset (there might be black bars on top/bottom
            // or left/right)
            _mousepos sub(dye fbo targetOffset) mul(1.0 / dye fbo scale)
        }
    }

}

LEvent: class {
    // base class for all events
    consumed := false

    consume: func {
        consumed = true
    }
}

WindowSizeChanged: class extends LEvent {

    x, y: Int
    init: func (=x, =y)
        
}

ExitEvent: class extends LEvent { }

MouseEvent: class extends LEvent {

    pos: Vec2
    
    init: func (=pos)

}

MouseMotion: class extends MouseEvent {

    init: super func

}

/*
 * Mouse button pressed (!= mouse click)
 */
MousePress: class extends MouseEvent {

    button: Int

    init: func (=pos, =button)

}

/*
 * Mouse button released. Note: release events
 * are not guaranteed to happen, e.g. if the
 * window loses focus before the user releases
 * the mouse button you're out of luck. You might
 * want to have a backup strategy
 */
MouseRelease: class extends MouseEvent {

    button: Int

    init: func (=pos, =button)

}

KeyboardEvent: class extends LEvent {

    keycode: Int
    scancode: Int
    init: func (=keycode, =scancode) {}

}

KeyPress: class extends KeyboardEvent {

    init: super func

}

KeyRelease: class extends KeyboardEvent {
   
    init: super func

}


/*
 * Func is a weird type, better wrap it in a class
 */
Listener: class {

    cb: Func(LEvent)
    init: func (=cb) {}

}

/*
 * Scancodes
 */
KeyCode: enum from Int {
    LEFT  = SDL_SCANCODE_LEFT
    RIGHT = SDL_SCANCODE_RIGHT
    UP    = SDL_SCANCODE_UP
    DOWN  = SDL_SCANCODE_DOWN
    SPACE = SDL_SCANCODE_SPACE
    ENTER = SDL_SCANCODE_RETURN
    F1    = SDL_SCANCODE_F1
    F2    = SDL_SCANCODE_F2
    F3    = SDL_SCANCODE_F3
    F4    = SDL_SCANCODE_F4
    F5    = SDL_SCANCODE_F5
    F6    = SDL_SCANCODE_F6
    F7    = SDL_SCANCODE_F7
    F8    = SDL_SCANCODE_F8
    F9    = SDL_SCANCODE_F9
    F10   = SDL_SCANCODE_F10
    F11   = SDL_SCANCODE_F11
    F12   = SDL_SCANCODE_F12
    A     = SDL_SCANCODE_A
    B     = SDL_SCANCODE_B
    C     = SDL_SCANCODE_C
    D     = SDL_SCANCODE_D
    E     = SDL_SCANCODE_E
    F     = SDL_SCANCODE_F
    G     = SDL_SCANCODE_G
    H     = SDL_SCANCODE_H
    I     = SDL_SCANCODE_I
    J     = SDL_SCANCODE_J
    K     = SDL_SCANCODE_K
    L     = SDL_SCANCODE_L
    M     = SDL_SCANCODE_M
    N     = SDL_SCANCODE_N
    O     = SDL_SCANCODE_O
    P     = SDL_SCANCODE_P
    Q     = SDL_SCANCODE_Q
    R     = SDL_SCANCODE_R
    S     = SDL_SCANCODE_S
    T     = SDL_SCANCODE_T
    U     = SDL_SCANCODE_U
    V     = SDL_SCANCODE_V
    W     = SDL_SCANCODE_W
    X     = SDL_SCANCODE_X
    Y     = SDL_SCANCODE_Y
    Z     = SDL_SCANCODE_Z
    KP0   = SDL_SCANCODE_KP_0
    KP1   = SDL_SCANCODE_KP_1
    KP2   = SDL_SCANCODE_KP_2
    KP3   = SDL_SCANCODE_KP_3
    KP4   = SDL_SCANCODE_KP_4
    KP5   = SDL_SCANCODE_KP_5
    KP6   = SDL_SCANCODE_KP_6
    KP7   = SDL_SCANCODE_KP_7
    KP8   = SDL_SCANCODE_KP_8
    KP9   = SDL_SCANCODE_KP_9
    _0    = SDL_SCANCODE_0
    _1    = SDL_SCANCODE_1
    _2    = SDL_SCANCODE_2
    _3    = SDL_SCANCODE_3
    _4    = SDL_SCANCODE_4
    _5    = SDL_SCANCODE_5
    _6    = SDL_SCANCODE_6
    _7    = SDL_SCANCODE_7
    _8    = SDL_SCANCODE_8
    _9    = SDL_SCANCODE_9
    ESC   = SDL_SCANCODE_ESCAPE

    // opinionated, but meh.
    ALT   = SDL_SCANCODE_LALT 
    CTRL  = SDL_SCANCODE_LCTRL
    SHIFT = SDL_SCANCODE_LSHIFT

    LALT   = SDL_SCANCODE_LALT
    LCTRL  = SDL_SCANCODE_LCTRL
    LSHIFT = SDL_SCANCODE_LSHIFT

    RALT   = SDL_SCANCODE_RALT
    RCTRL  = SDL_SCANCODE_RCTRL
    RSHIFT = SDL_SCANCODE_RSHIFT

    DEL   = SDL_SCANCODE_DELETE
    BACKSPACE = SDL_SCANCODE_BACKSPACE
}

/*
 * Mouse button codes
 */
MouseButton: enum from Int {
    LEFT   = SDL_BUTTON_LEFT
    MIDDLE = SDL_BUTTON_MIDDLE
    RIGHT  = SDL_BUTTON_RIGHT
}

