package main

import "core:fmt"
import "core:os"
import b2 "vendor:box2d"
import rl "vendor:raylib"

make_fixture :: proc() -> (b2.WorldId, b2.BodyId) {
    world_def := b2.DefaultWorldDef()
    world_def.gravity = {0, -10}
    world := b2.CreateWorld(world_def)
    assert(b2.World_IsValid(world))

    ground_def := b2.DefaultBodyDef()
    ground_def.position = {0, -0.5}
    ground := b2.CreateBody(world, ground_def)
    ground_box := b2.MakeBox(4, 0.5)
    shape_def := b2.DefaultShapeDef()
    _ = b2.CreatePolygonShape(ground, shape_def, ground_box)

    body_def := b2.DefaultBodyDef()
    body_def.type = .dynamicBody
    body_def.position = {0, 4}
    body := b2.CreateBody(world, body_def)
    moving_box := b2.MakeBox(0.5, 0.5)
    _ = b2.CreatePolygonShape(body, shape_def, moving_box)
    assert(b2.Body_IsValid(body))
    return world, body
}

main :: proc() {
    world, body := make_fixture()
    defer b2.DestroyWorld(world)
    if len(os.args) != 2 || os.args[1] != "window" {
        start := b2.Body_GetPosition(body).y
        for _ in 0..<180 {
            b2.World_Step(world, 1.0 / 60.0, 4)
        }
        finish := b2.Body_GetPosition(body).y
        assert(start == 4 && finish >= 0.4 && finish <= 0.6)
        fmt.printf("start=%.2f rest=%.3f\n", start, finish)
        return
    }

    rl.InitWindow(480, 320, "Box2D and Raylib")
    if !rl.IsWindowReady() {
        fmt.eprintln("Could not initialize the window")
        return
    }
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)
    remaining: f64
    for !rl.WindowShouldClose() {
        remaining += min(f64(rl.GetFrameTime()), 0.125)
        for remaining >= 1.0 / 60.0 {
            b2.World_Step(world, 1.0 / 60.0, 4)
            remaining -= 1.0 / 60.0
        }
        center := b2.Body_GetPosition(body)
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawRectangleRec({80, 270, 320, 20}, rl.DARKGRAY)
        rl.DrawRectangleRec({220 + center.x * 40, 250 - center.y * 40, 40, 40}, rl.BLUE)
        rl.EndDrawing()
    }
}
