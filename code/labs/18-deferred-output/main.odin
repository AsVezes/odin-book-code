package main
import "core:fmt"

Stats :: struct { active, opened, closed, callbacks: int }
Token :: struct { stats: ^Stats, acquired: bool }

release :: proc(token: Token) {
    token.stats.callbacks += 1
    if !token.acquired { return }
    token.stats.active -= 1
    token.stats.closed += 1
}

@(deferred_out = release)
acquire :: proc(stats: ^Stats, allowed: bool) -> Token {
    if !allowed { return Token{stats = stats} }
    stats.active += 1
    stats.opened += 1
    return Token{stats = stats, acquired = true}
}

work :: proc(stats: ^Stats, allowed: bool) {
    token := acquire(stats, allowed)
    fmt.println("acquired:", token.acquired)
    if !token.acquired { return }
    fmt.println("active:", stats.active)
}

main :: proc() {
    stats: Stats
    work(&stats, true)
    fmt.println("after success:", stats.active, stats.opened, stats.closed, stats.callbacks)
    work(&stats, false)
    fmt.println("after failure:", stats.active, stats.opened, stats.closed, stats.callbacks)
}
