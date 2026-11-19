package main

import "core:fmt"

categories :: #load("categories.txt", string)
#assert(len(categories) > 0)

main :: proc() {
    fmt.print(categories)
}
