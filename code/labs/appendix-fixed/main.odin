package main

import "core:fmt"

Capacity :: #config(LAB_CAPACITY, 2)
#assert(Capacity > 0)

try_push :: proc(values: ^[dynamic; Capacity]int, value: int) -> bool {
    if len(values^) == cap(values^) {
        return false
    }
    append(values, value)
    return true
}

main :: proc() {
    values: [dynamic; Capacity]int
    for value := 0; value < Capacity; value += 1 {
        assert(try_push(&values, value))
    }
    assert(!try_push(&values, 99))
    assert(len(values) == Capacity && values[len(values) - 1] == Capacity - 1)
    fmt.println("full:", len(values))
}
