# Reconstruct Unit 40 from Unit 39

Complete the three passes in Unit 40 in your own Arena directory first. These comparison instructions use a POSIX shell and Git's patch reader. They operate on a fresh scratch tree. Set `book_root` to the absolute directory that contains `code/`.

```sh
book_root=/absolute/path/to/odin-completo
mkdir arena-unit40-work
cp -R "$book_root/code/labs/37-round/sim" arena-unit40-work/
cp -R "$book_root/code/labs/39-marker/window" arena-unit40-work/
cd arena-unit40-work
```

In `window/main.odin`, change the line `import "../../37-round/sim"` to `import "../sim"`. The latter imports the sibling package you copied. This is the starting layout discussed in Unit 40. Follow the three passes in the text on a working copy. To reproduce the reference automatically, apply the patch to a separate, unedited starting tree with that same import adjustment.

```sh
git apply --check "$book_root/code/labs/arena-game/from-unit-39.patch"
git apply "$book_root/code/labs/arena-game/from-unit-39.patch"
odin test sim
odin test score
odin build headless -out:arena-headless
python3 verify.py ./arena-headless
odin build window -out:arena
```

The patch has hunks for `sim/arena.odin`, `sim/arena_test.odin`, the score package, the window loop and the headless verifier. It leaves the marker loader untouched. The patched sources match the final Arena Courier source. The headless verifier must pass replay, usage, score round-trip, corrupt-file preservation and staging failure. A graphical build gives you a separate executable for Unit 41's desktop smoke test.

Before running the graphical build, choose a fresh writable directory. Keep any existing save elsewhere while testing. Run `arena` using its absolute path from the chosen directory so `arena.score` and `marker.png` resolve there.
