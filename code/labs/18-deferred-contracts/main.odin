package main
import "core:fmt"

Counter :: struct { value, delta: int }

record_delta :: proc(counter: ^Counter, start: int) {
    counter.delta = counter.value - start
}

@(deferred_in_out = record_delta)
begin_delta :: proc(counter: ^Counter) -> int {
    return counter.value
}

group_depth: int
groups_closed: int

end_group :: proc() {
    group_depth -= 1
    groups_closed += 1
}

@(deferred_none = end_group)
begin_group :: proc() {
    group_depth += 1
}

main :: proc() {
    counter := Counter{value = 5}
    {
        begin_delta(&counter)
        counter.value += 3
        fmt.println("during delta:", counter.delta)
    }
    fmt.println("after delta:", counter.delta)
    {
        begin_group()
        fmt.println("during group:", group_depth)
    }
    fmt.println("after group:", group_depth, groups_closed)
}
