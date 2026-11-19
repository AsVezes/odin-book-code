package sim

import "core:testing"

@(test)
score_and_hazard :: proc(t: ^testing.T) {
    arena := new_arena(7)
    arena.count = 2
    arena.drops[0] = {x = 320, y = Player_Y - 4}
    arena.drops[1] = {x = 320, y = Player_Y - 4}
    step(&arena, {})
    testing.expect(t, arena.points == 2 && arena.count == 0)
    arena.count = 1
    arena.drops[0] = {x = 320, y = Player_Y - 4, hazard = true}
    step(&arena, {})
    testing.expect(t, arena.phase == .Finished && arena.points == 2)
}

@(test)
seed_and_full_capacity :: proc(t: ^testing.T) {
    a := replay(7, 600)
    b := replay(7, 600)
    testing.expect(t, a == b && a.ticks > 0)
    a.count = len(a.drops)
    prev_seed := a.seed
    try_spawn(&a)
    testing.expect(t, a.count == len(a.drops) && a.seed == prev_seed)
}

@(test)
movement_and_edges :: proc(t: ^testing.T) {
    a := new_arena(7)
    step(&a, {})
    testing.expect(t, a.player_x == 320)
    step(&a, {left = true, right = true})
    testing.expect(t, a.player_x == 320)
    step(&a, {left = true})
    testing.expect(t, a.player_x == 315)
    step(&a, {right = true})
    testing.expect(t, a.player_x == 320)

    a.player_x = 12
    step(&a, {left = true})
    testing.expect(t, a.player_x == 12)
    a.player_x = Width - 12
    step(&a, {right = true})
    testing.expect(t, a.player_x == Width - 12)
}

@(test)
contact_boundary_and_finished_freeze :: proc(t: ^testing.T) {
    outside := new_arena(7)
    outside.count = 1
    outside.drops[0] = {x = 341, y = Player_Y - 4}
    step(&outside, {})
    testing.expect(t, outside.points == 0 && outside.count == 1)

    inside := new_arena(7)
    inside.count = 1
    inside.drops[0] = {x = 340, y = Player_Y - 4}
    step(&inside, {})
    testing.expect(t, inside.points == 1 && inside.count == 0)

    hazard := new_arena(7)
    hazard.count = 1
    hazard.drops[0] = {x = 320, y = Player_Y - 4, hazard = true}
    step(&hazard, {})
    testing.expect(t, hazard.phase == .Finished && hazard.points == 0)
    frozen := hazard
    step(&hazard, {left = true})
    testing.expect(t, hazard == frozen)
}

@(test)
spawn_tick_boundary :: proc(t: ^testing.T) {
    a := new_arena(7)
    for i in 0..<23 {
        step(&a, {})
    }
    testing.expect(t, a.ticks == 23 && a.count == 0)
    initial_seed := a.seed
    step(&a, {})
    testing.expect(t, a.ticks == 24 && a.count == 1)
    testing.expect(t, a.seed != initial_seed && a.drops[0].y == 4)
}

@(test)
full_capacity_spawn_tick_preserves_seed :: proc(t: ^testing.T) {
    a := new_arena(7)
    a.ticks = 23
    a.count = len(a.drops)
    for i in 0..<a.count {
        a.drops[i] = {x = 12, y = 0}
    }
    initial_seed := a.seed
    step(&a, {})
    testing.expect(t, a.ticks == 24)
    testing.expect(t, a.count == Max_Objects)
    testing.expect(t, a.seed == initial_seed)
    testing.expect(t, a.drops[0].y == 4)
}

@(test)
swap_removal_visits_moved_drop :: proc(t: ^testing.T) {
    arena := new_arena(7)
    arena.count = 3
    arena.drops[0] = {x = 320, y = Player_Y - 4}
    arena.drops[1] = {x = 100, y = 10}
    arena.drops[2] = {x = 320, y = Player_Y - 4}

    step(&arena, {})

    testing.expect(t, arena.points == 2)
    testing.expect(t, arena.count == 1)
    testing.expect(t, arena.drops[0].x == 100)
    testing.expect(t, arena.drops[0].y == 14)
    testing.expect(t, arena.drops[1] == Drop{})
}

@(test)
swap_removal_rechecks_replacement :: proc(t: ^testing.T) {
    a := new_arena(7)
    a.count = 3
    a.drops[0] = {x = 320, y = Player_Y - 4}
    a.drops[1] = {x = 320, y = Player_Y - 4}
    a.drops[2] = {x = 320, y = Player_Y - 4}
    step(&a, {})
    testing.expect(t, a.points == 3 && a.count == 0)
    testing.expect(t, a.drops[0] == Drop{})

    b := new_arena(7)
    b.count = 2
    b.drops[0] = {x = 320, y = Player_Y - 4, hazard = true}
    b.drops[1] = {x = 320, y = Player_Y - 4}
    step(&b, {})
    testing.expect(t, b.phase == .Finished && b.points == 0 && b.count == 2)
    testing.expect(t, b.drops[1].y == Player_Y - 4)
}

@(test)
offscreen_removal_does_not_skip_next_drop :: proc(t: ^testing.T) {
    a := new_arena(7)
    a.count = 2
    a.drops[0] = {x = 12, y = Height + 12}
    a.drops[1] = {x = 320, y = Player_Y - 4}
    step(&a, {})
    testing.expect(t, a.points == 1 && a.count == 0)
}
