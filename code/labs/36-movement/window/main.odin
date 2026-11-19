package main

import "core:fmt"
import "core:os"
import "core:c"
import rl "vendor:raylib"
import "../sim"

main :: proc() {
    rl.InitWindow(sim.Width, sim.Height, "Arena Courier - movement")
    if !rl.IsWindowReady() {
        fmt.eprintln("Could not initialize the window")
        os.exit(1)
    }
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    x := sim.Width / 2
    elapsed: f64
    for !rl.WindowShouldClose() {
        left := rl.IsKeyDown(.LEFT)
        right := rl.IsKeyDown(.RIGHT)
        elapsed += min(f64(rl.GetFrameTime()), 0.125)
        for elapsed >= sim.Tick_Seconds {
            x = sim.step(x, left, right)
            elapsed -= sim.Tick_Seconds
        }
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangle(c.int(x - 12), sim.Player_Y - 8, 24, 16, rl.DARKBLUE)
        rl.EndDrawing()
    }
}
