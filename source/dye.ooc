
use sdl
import sdl/Core

Color: class {

  r, g, b: UInt8
  init: func (=r, =g, =b)

  toSDL: func (format: SdlPixelFormat*) -> UInt {
    SDL mapRgb(format, r, g, b)
  }

}

Dye: class {

  screen: SdlSurface*
  bgColor := Color new(72, 60, 50)

  init: func (width, height: Int) {
    SDL init(SDL_INIT_EVERYTHING)
    screen = SDL setMode(width, height, 0, SDL_HWSURFACE | SDL_DOUBLEBUF)
  }

  draw: func {
    SDL fillRect(screen, null, bgColor toSDL(screen@ format))
    SDL flip(screen)
  }

  quit: func {
    SDL quit()
  }

}

