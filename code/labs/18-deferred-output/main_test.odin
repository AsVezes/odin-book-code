package main
import "core:testing"

early_success :: proc(stats: ^Stats) {
    token := acquire(stats, true)
    assert(token.acquired)
    return
}

@(test)
failed_acquisition :: proc(t: ^testing.T) {
    stats: Stats
    {
        token := acquire(&stats, false)
        testing.expect(t, !token.acquired)
        testing.expect(t, stats.callbacks == 0 && stats.active == 0)
    }
    testing.expect(t, stats.callbacks == 1)
    testing.expect(t, stats.opened == 0 && stats.closed == 0 && stats.active == 0)
}

@(test)
nested_and_early_return :: proc(t: ^testing.T) {
    stats: Stats
    {
        outer := acquire(&stats, true)
        testing.expect(t, outer.acquired && stats.active == 1)
        {
            inner := acquire(&stats, false)
            testing.expect(t, !inner.acquired && stats.active == 1)
        }
        testing.expect(t, stats.callbacks == 1 && stats.closed == 0 && stats.active == 1)
    }
    testing.expect(t, stats.callbacks == 2 && stats.closed == 1 && stats.active == 0)
    early_success(&stats)
    testing.expect(t, stats.callbacks == 3 && stats.closed == 2 && stats.active == 0)
    testing.expect(t, stats.opened == stats.closed)
}
