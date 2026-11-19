package main

import "core:os"
import "core:c"
import "core:fmt"
import rl "vendor:raylib"
import "../score"
import "../sim"

Seed :: 7

main :: proc() {
    rl.InitWindow(sim.Width, sim.Height, "Arena Courier")
    if !rl.IsWindowReady() {
        fmt.eprintln("Could not initialize the game window")
        os.exit(1)
    }
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    marker := load_marker()
    defer release_marker(marker)

    arena := sim.new_arena(Seed)
    best, load_result := score.load("arena.score")
    save_allowed := load_result == .Missing || load_result == .Valid
    save_failed := !save_allowed
    elapsed: f64

    for !rl.WindowShouldClose() {
        input := sim.Input{
            start = rl.IsKeyPressed(.ENTER),
            pause = rl.IsKeyPressed(.P),
            left = rl.IsKeyDown(.LEFT),
            right = rl.IsKeyDown(.RIGHT),
        }
        previous_phase := arena.phase
        sim.control(&arena, input, Seed)
        phase_before_ticks := arena.phase
        if previous_phase != arena.phase {
            elapsed = 0
        }
        if arena.phase == .Playing {
            elapsed += min(f64(rl.GetFrameTime()), 0.125)
            for elapsed >= sim.Tick_Seconds && arena.phase == .Playing {
                sim.step(&arena, input)
                elapsed -= sim.Tick_Seconds
            }
        }
        if phase_before_ticks == .Playing && arena.phase == .Finished && arena.points > best {
            if save_allowed && score.save("arena.score", "arena.score.tmp", arena.points) {
                best = arena.points
                save_failed = false
            } else {
                save_failed = true
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
        rl.DrawText(rl.TextFormat("Score: %d   Best: %d", arena.points, best), 12, 12, 20, rl.DARKGRAY)
        switch arena.phase {
        case .Title:    rl.DrawText("ENTER to start | Arrows move | P pauses", 84, 168, 20, rl.BLACK)
        case .Paused:   rl.DrawText("Paused. Press P to resume.", 178, 168, 20, rl.BLACK)
        case .Finished: rl.DrawText("Game over. ENTER restarts.", 175, 168, 20, rl.BLACK)
        case .Playing:
        }
        if save_failed {
            rl.DrawText("Best score could not be loaded or saved.", 12, 40, 16, rl.MAROON)
        }
        rl.EndDrawing()
    }
}
