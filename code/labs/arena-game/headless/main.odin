package main

import "core:fmt"
import "core:os"
import "../score"
import "../sim"

main :: proc() {
    if len(os.args) == 1 {
        arena := sim.replay(7, 600)
        fmt.printf("ticks=%d points=%d remaining=%d phase=%v\n", arena.ticks, arena.points, arena.count, arena.phase)
        return
    }
    if len(os.args) == 2 && os.args[1] == "profile" {
        total: u64
        for seed in 1..=10_000 {
            arena := sim.replay(u32(seed), 600)
            total += u64(arena.ticks) + u64(arena.points)
        }
        fmt.println("digest:", total)
        return
    }
    if len(os.args) == 2 && os.args[1] == "score-smoke" {
        best, result := score.load("arena.score")
        fmt.println("read:", result, best)
        if result == .Invalid || result == .IO_Error {
            os.exit(1)
        }
        if !score.save("arena.score", "arena.score.tmp", max(best, 12)) {
            fmt.eprintln("Could not save score")
            os.exit(1)
        }
        return
    }
    fmt.eprintln("Usage: arena-headless [score-smoke|profile]")
    os.exit(2)
}
