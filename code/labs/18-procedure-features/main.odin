package main

import "core:fmt"

describe_count :: proc(value: int) -> string {
    if value < 0 { return "invalid count" }
    if value == 0 { return "empty" }
    return "populated"
}

describe_name :: proc(value: string) -> string {
    if len(value) == 0 { return "unnamed" }
    return "named"
}

describe :: proc{describe_count, describe_name}

can_preview :: proc(count: int, limit: int = 3) -> bool {
    return count >= 0 && limit >= 0 && count <= limit
}

sum_values :: proc(values: ..int) -> (total: int) {
    for value in values { total += value }
    return
}

main :: proc() {
    fmt.println(describe(0))
    fmt.println(describe("hero"))
    fmt.println("default:", can_preview(4))
    fmt.println("named:", can_preview(limit = 5, count = 4))
    counts := [3]int{2, 0, 5}
    fmt.println("sums:", sum_values(), sum_values(2, 0, 5), sum_values(..counts[:]))
}
