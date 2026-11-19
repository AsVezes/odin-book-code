package main
import "core:fmt"

Stats :: struct { active, opened, closed: int }

end_scope :: proc(stats: ^Stats) {
    stats.active -= 1
    stats.closed += 1
}

@(deferred_in = end_scope)
begin_scope :: proc(stats: ^Stats) {
    stats.active += 1
    stats.opened += 1
}

work :: proc(stats: ^Stats, early: bool) {
    begin_scope(stats)
    fmt.println("active:", stats.active)
    if early { return }
    fmt.println("work")
}

main :: proc() {
    stats: Stats
    work(&stats, false)
    fmt.println("after normal:", stats.active, stats.opened, stats.closed)
    work(&stats, true)
    fmt.println("after return:", stats.active, stats.opened, stats.closed)
}
