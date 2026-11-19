package main

import "core:os"
import "core:fmt"
import rl "vendor:raylib"

button :: proc(bounds: rl.Rectangle, label: cstring) -> bool {
    hovered := rl.CheckCollisionPointRec(rl.GetMousePosition(), bounds)
    rl.DrawRectangleRec(bounds, hovered ? rl.SKYBLUE : rl.LIGHTGRAY)
    rl.DrawText(label, i32(bounds.x) + 8, i32(bounds.y) + 8, 18, rl.BLACK)
    return hovered && rl.IsMouseButtonReleased(.LEFT)
}

main :: proc() {
    rl.InitWindow(360, 160, "Counter Panel")
    if !rl.IsWindowReady() {
        fmt.eprintln("Could not initialize the panel")
        os.exit(1)
    }
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    count: i32
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        if button({20, 54, 125, 36}, "Increment") {
            count = min(count + 1, 9999)
        }
        if button({160, 54, 100, 36}, "Reset") {
            count = 0
        }
        rl.DrawText(rl.TextFormat("Count: %d", count), 20, 20, 20, rl.DARKGRAY)
        rl.EndDrawing()
    }
}
