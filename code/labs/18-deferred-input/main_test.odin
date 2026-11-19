package main
import "core:testing"

early_scope :: proc(stats: ^Stats) {
    begin_scope(stats)
    return
}

@(test)
caller_scope :: proc(t: ^testing.T) {
    stats: Stats
    {
        begin_scope(&stats)
        testing.expect(t, stats.active == 1 && stats.closed == 0)
        {
            begin_scope(&stats)
            testing.expect(t, stats.active == 2 && stats.closed == 0)
        }
        testing.expect(t, stats.active == 1 && stats.closed == 1)
    }
    testing.expect(t, stats.active == 0 && stats.opened == 2 && stats.closed == 2)
    early_scope(&stats)
    testing.expect(t, stats.active == 0 && stats.opened == 3 && stats.closed == 3)
}
