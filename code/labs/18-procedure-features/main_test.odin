package main

import "core:testing"

@(test)
group_and_default_contracts :: proc(t: ^testing.T) {
    testing.expect_value(t, describe(-1), "invalid count")
    testing.expect_value(t, describe(0), "empty")
    testing.expect_value(t, describe(2), "populated")
    testing.expect_value(t, describe(""), "unnamed")
    testing.expect_value(t, describe("hero"), "named")
    testing.expect(t, can_preview(0))
    testing.expect(t, can_preview(3))
    testing.expect(t, !can_preview(4))
    testing.expect(t, can_preview(limit = 5, count = 4))
    testing.expect(t, !can_preview(-1))
    testing.expect(t, !can_preview(count = 0, limit = -1))
}

@(test)
variadic_contract :: proc(t: ^testing.T) {
    values := [3]int{2, 0, 5}
    testing.expect_value(t, sum_values(), 0)
    testing.expect_value(t, sum_values(2, 0, 5), 7)
    testing.expect_value(t, sum_values(..values[:]), 7)
    testing.expect_value(t, sum_values(..values[:0]), 0)
    testing.expect_value(t, values, [3]int{2, 0, 5})
}
