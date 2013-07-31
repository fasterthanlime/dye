
// third-party stuff
use sdl2
import sdl2/[RW]

import stb/image

// sdk stuff
import io/Reader

/**
 * Reader implementation on top of SDL_RWops
 *
 * Allows, among other things, to read android assets - which might
 * not be regular files on the filesystem but rather, compressed in
 * the archive.
 */
RWopsReader: class extends Reader {

    ops: RWops 

    /* our own housekeeping to figure out if we're at the end of the file */
    eof := false

    init: func (path: String) {
        ops = RWops new(path, "rb")   

        if (!ops) {
            RWException new(This, "Couldn't open for reading.") throw()
        }
    }

    read: func (chars: Char*, offset: Int, count: Int) -> SizeT {
        result := ops read(chars + offset, 1, count)
        if (result == 0) {
            eof = true
        }
        result
    }

    read: func ~char -> Char {
        c: Char
        ops read(c&, 1, 1)
        c
    }

    hasNext?: func -> Bool {
        !eof
    }

    mark: func -> Long {
        marker = ops tell()
        marker
    }

    seek: func (offset: Long, mode: SeekMode) -> Bool {
        ops seek(offset, match mode {
            case SeekMode SET => SDL_SeekMode SET
            case SeekMode CUR => SDL_SeekMode CUR
            case SeekMode END => SDL_SeekMode END
        })
        true
    }

    close: func {
        ops close()
    }

}

RWException: class extends Exception {

    init: func ~justMessage (.message) {
        super(message)
    }

    init: func ~withOrigin (.origin, .message) {
        super(origin, message)
    }

}

StbIo: class {

    callbacks: static func -> StbIoCallbacks {
        cb: StbIoCallbacks
        cb read = _read
        cb skip = _skip
        cb eof = _eof

        cb
    }
    
    // fill 'data' with 'size' bytes. return number of bytes actually read
    _read: static func (r: Reader, data: Char*, size: Int) -> Int {
        r read(data, 0, size)
    }

    // skip the next 'n' bytes
    _skip: static func (r: Reader, n: UInt) {
        r seek(n, SeekMode CUR)
    }

    // returns nonzero if we are at the end of file/data
    _eof: static func (r: Reader) -> Int {
        r hasNext?() ? 0 : 1
    }

}

