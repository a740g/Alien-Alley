# Alien Alley

A QB64-PE source port of the classic 1994 vertical-scrolling space shooter from *PC Game Programming Explorer* by Dave Roberts.

![Screenshot](screenshots/screenshot1.png)
![Screenshot](screenshots/screenshot2.png)
![Screenshot](screenshots/screenshot3.png)

---

> **Lineage:** This is a source port of a source port — originally written in Turbo C (1994), later ported to FreeBASIC/Allegro, and now rewritten in pure QB64-PE BASIC with no external dependencies.

## Table of Contents

- [About the Game](#about-the-game)
- [Features](#features)
- [Controls](#controls)
- [Build Requirements](#build-requirements)
- [Building & Running](#building--running)
- [Credits](#credits)
- [License](#license)
- [Original Game Info](#original-game-info)

## About the Game

You control a defending spaceship flying through the cosmos. Alien ships drift in from above, maneuvering side-to-side and firing plasma cannons at you. Fire back, dodge their missiles, and see how long you can survive.

- Up to **4 aliens** on screen at once
- **Shield-based health** system (80 units, -5 per hit)
- **Persistent high scores** (top 10, with name entry)
- **Dual-layer starfield** with occasional planets

## Features

- **Cross-platform** — runs natively on Windows, Linux & macOS
- **No external dependencies** — uses only native QB64-PE graphics and sound (unlike the FreeBASIC/Allegro predecessor)
- **32-bit color** at 640×400 fullscreen (16:10 aspect ratio, square pixels)
- **MIDI music** with 3 looping tracks (intro, gameplay, high score fanfare)
- **Stereo-panned** sound effects (position-aware)
- **PCX sprite** loading with color-key transparency
- **Toggleable FPS** counter and unlimited frame rate mode
- **Alt+Enter** for windowed/fullscreen toggle

## Controls

| Input | Action |
| --- | --- |
| `W` / `↑` / mouse up | Move up |
| `S` / `↓` / mouse down | Move down |
| `A` / `←` / mouse left | Move left |
| `D` / `→` / mouse right | Move right |
| `Space` / `Ctrl` / `Alt` / click | Fire |
| `K` / `M` / `J` / `Enter` | Start game |
| `S` | View high scores |
| `F1` | Toggle FPS display |
| `F7` | Toggle unlimited frame rate |
| `Esc` / `Q` | Quit |

## Build Requirements

- **[QB64-PE v4.7.0+](https://github.com/QB64-Phoenix-Edition/QB64pe/releases)** (Phoenix Edition)
- Source file: `AlienAlley.bas`

## Building & Running

### Using the QB64-PE IDE

1. Clone the repository
2. Open `AlienAlley.bas` in the QB64-PE IDE
3. Press **F5** to compile and run

### From the Command Line

```bash
qb64pe -x -w -e AlienAlley.bas -o AlienAlley.exe
```

## Credits

| Role | Original (1994) | QB64-PE Port |
| --- | --- | --- |
| Programming | Dave Roberts | Samuel Gomes |
| Graphics | Kevin Long (AIR Design) | — |
| MIDI Music | James J. Black | — |
| Sound FX | Dave Roberts | — |

**QB64-PE port copyright:** © 2026 Samuel Gomes — [MIT License](LICENSE.txt)  
**Original game copyright:** © 1994 David G. Roberts

## License

This QB64-PE source port is released under the [MIT License](LICENSE.txt).  
The original game assets and code remain the property of their respective copyright holders.

## Original Game Info

*Alien Alley* was created as a teaching example for the book **PC Game Programming Explorer** by Dave Roberts (Coriolis Group Books, November 1994). The original Turbo C source code demonstrated joystick, mouse, and keyboard programming, fast page flipping animation, VGA palette effects, music and sound, and a scrolling background.

The original source code is archived online — see the [original Turbo C source](http://www.droberts.com/pcgpex/source.zip) and [update](http://www.droberts.com/pcgpex/update.zip).

> **Icon credit:** [Good Stuff No Nonsense](https://www.iconarchive.com/artist/goodstuff-no-nonsense.html) via IconArchive
