package main

import "core:fmt"
import "core:os"

select_last :: proc(values: []int, reproduce: bool) -> (int, bool) {
    if len(values) == 0 {
        return 0, false
    }
    index := len(values) - 1
    if reproduce {
        index += 1
    }
    return values[index], true
}

main :: proc() {
    fixture := [2]int{8, 13}
    reproduce := len(os.args) == 2 && os.args[1] == "repro"
    value, ok := select_last(fixture[:], reproduce)
    fmt.println(value, ok)
    empty, found := select_last(fixture[:0], false)
    fmt.println(empty, found)
}
