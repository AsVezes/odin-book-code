package main

import "core:fmt"
import "core:os"
import "core:c"
import rl "vendor:raylib"
import "../../37-round/sim"

main :: proc() {
    rl.InitWindow(sim.Width, sim.Height, "Arena Courier - first round")
    if !rl.IsWindowReady() {
        fmt.eprintln("Could not initialize the window")
        os.exit(1)
    }
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)
    marker := load_marker()
    defer release_marker(marker)

    arena := sim.new_arena(7)
    elapsed: f64
    for !rl.WindowShouldClose() {
        input := sim.Input{left = rl.IsKeyDown(.LEFT), right = rl.IsKeyDown(.RIGHT)}
        if arena.phase == .Playing {
            elapsed += min(f64(rl.GetFrameTime()), 0.125)
            for elapsed >= sim.Tick_Seconds && arena.phase == .Playing {
                sim.step(&arena, input)
                elapsed -= sim.Tick_Seconds
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangle(c.int(arena.player_x - 12), sim.Player_Y - 8, 24, 16, rl.DARKBLUE)
        for drop in arena.drops[:arena.count] {
            if drop.hazard {
                rl.DrawRectangle(c.int(drop.x - 8), c.int(drop.y - 8), 16, 16, rl.MAROON)
            } else if marker.attached {
                rl.DrawTexturePro(
                    marker.texture,
                    {0, 0, f32(marker.texture.width), f32(marker.texture.height)},
                    {f32(drop.x - 7), f32(drop.y - 7), 14, 14}, {}, 0, rl.WHITE,
                )
            } else {
                rl.DrawCircle(c.int(drop.x), c.int(drop.y), 7, rl.DARKGREEN)
            }
        }
        if arena.phase == .Finished {
            rl.DrawText("Round finished", 240, 165, 20, rl.DARKGRAY)
        }
        rl.EndDrawing()
    }
}
