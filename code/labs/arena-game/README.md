# Arena Courier

From the book root, check the independent rule and score packages:

```sh
odin test code/labs/arena-game/sim
odin test code/labs/arena-game/score
odin build code/labs/arena-game/headless -out:arena-headless
python3 code/labs/arena-game/verify.py ./arena-headless
odin build code/labs/arena-game/window -out:arena
```

Launch the graphical binary from a writable directory with a working desktop display. Enter starts or restarts. Arrow keys move. P pauses and resumes. A green pickup scores and a red hazard ends the round. Use the window close control to quit.

The working directory holds `arena.score` and its sibling staging file while saving. The project assumes one writer. Keep a backup before replacing a corrupt score. Optionally place a PNG you may use at `marker.png`; missing or invalid files use a circle. Assets other than the optional marker are drawn using Raylib defaults. The pinned Raylib binding is bundled with Odin. On Linux the link requires X11 development linkage and the visual run needs a supported display and graphics stack. Consult the installed vendor README for other targets.

Window initialization failure writes a diagnostic to stderr and exits 1. A successful native link is not proof that the display/input smoke tests passed.
