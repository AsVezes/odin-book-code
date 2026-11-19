package main

import "core:fmt"

Filter :: struct { minimum, examined: int }
Predicate :: proc(value: int, state: ^Filter) -> bool

meets_minimum :: proc(value: int, state: ^Filter) -> bool {
    state.examined += 1
    return value >= state.minimum
}

count_matching :: proc(values: []int, accept: Predicate, state: ^Filter) -> int {
    count := 0
    for value in values {
        if accept(value, state) { count += 1 }
    }
    return count
}

main :: proc() {
    values := [4]int{1, 4, 5, 7}
    state := Filter{minimum = 4}
    count := count_matching(values[:], meets_minimum, &state)
    fmt.println("matches:", count)
    fmt.println("examined:", state.examined)
}
