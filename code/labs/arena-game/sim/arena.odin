package sim

Width :: 640
Height :: 360
Player_Y :: 320
Tick_Seconds :: 1.0 / 60.0
Max_Objects :: 32

Phase :: enum { Title, Playing, Paused, Finished }
Input :: struct { left, right, start, pause: bool }
Drop :: struct { x, y: int, hazard: bool }
Arena :: struct {
    phase: Phase,
    player_x: int,
    seed, ticks, points: u32,
    count: int,
    drops: [Max_Objects]Drop,
}

new_arena :: proc(seed: u32) -> Arena {
    return Arena{player_x = Width / 2, seed = seed}
}

control :: proc(arena: ^Arena, input: Input, restart_seed: u32) {
    switch arena.phase {
    case .Title, .Finished:
        if input.start {
            arena^ = new_arena(restart_seed)
            arena.phase = .Playing
        }
    case .Playing:
        if input.pause {
            arena.phase = .Paused
        }
    case .Paused:
        if input.pause {
            arena.phase = .Playing
        }
    }
}

next_random :: proc(seed: ^u32) -> u32 {
    seed^ = seed^ * 1664525 + 1013904223
    return seed^
}

try_spawn :: proc(arena: ^Arena) {
    if arena.count == len(arena.drops) {
        return
    }
    roll := next_random(&arena.seed)
    arena.drops[arena.count] = Drop{
        x = 12 + int((roll >> 8) % u32(Width - 24)),
        y = 0,
        hazard = (roll >> 20) % 3 == 0,
    }
    arena.count += 1
}

remove_drop :: proc(arena: ^Arena, index: int) {
    arena.count -= 1
    arena.drops[index] = arena.drops[arena.count]
    arena.drops[arena.count] = {}
}

step :: proc(arena: ^Arena, input: Input) {
    if arena.phase != .Playing {
        return
    }

    movement := 0
    if input.left  { movement -= 5 }
    if input.right { movement += 5 }
    arena.player_x = clamp(arena.player_x + movement, 12, Width - 12)
    arena.ticks += 1
    if arena.ticks % 24 == 0 {
        try_spawn(arena)
    }

    index := 0
    for index < arena.count {
        drop := &arena.drops[index]
        drop.y += 4
        if abs(drop.x - arena.player_x) <= 20 && abs(drop.y - Player_Y) <= 16 {
            if drop.hazard {
                arena.phase = .Finished
                return
            }
            arena.points += 1
        } else if drop.y <= Height + 12 {
            index += 1
            continue
        }
        remove_drop(arena, index)
    }
}

replay :: proc(seed: u32, steps: int) -> Arena {
    arena := new_arena(seed)
    control(&arena, Input{start = true}, seed)
    for tick in 0..<steps {
        step(&arena, Input{left = (tick / 30) % 2 == 0, right = (tick / 30) % 2 == 1})
    }
    return arena
}
