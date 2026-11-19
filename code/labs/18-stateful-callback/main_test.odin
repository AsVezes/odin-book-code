package main

import "core:testing"

@(test)
synchronous_state :: proc(t: ^testing.T) {
    values := [4]int{1, 4, 5, 7}
    state := Filter{minimum = 4}
    testing.expect_value(t, count_matching(values[:], meets_minimum, &state), 3)
    testing.expect_value(t, state.examined, 4)
    state.minimum = 6
    testing.expect_value(t, count_matching(values[:], meets_minimum, &state), 1)
    testing.expect_value(t, state.examined, 8)
    testing.expect_value(t, count_matching(values[:0], meets_minimum, &state), 0)
    testing.expect_value(t, state.examined, 8)
}

@(test)
traversal_boundaries :: proc(t: ^testing.T) {
    values := [5]int{-5, -4, -3, -2, -1}
    state := Filter{minimum = 1}
    testing.expect_value(t, count_matching(values[:], meets_minimum, &state), 0)
    testing.expect_value(t, state.examined, 5)
    values[0] = 1
    state.examined = 0
    testing.expect_value(t, count_matching(values[:], meets_minimum, &state), 1)
    testing.expect_value(t, state.examined, 5)
    values = [5]int{1, 2, 3, 4, 5}
    state.examined = 0
    testing.expect_value(t, count_matching(values[:], meets_minimum, &state), 5)
    testing.expect_value(t, state.examined, 5)
    state.examined = 0
    testing.expect_value(t, count_matching(values[:0], meets_minimum, &state), 0)
    testing.expect_value(t, state.examined, 0)
}
