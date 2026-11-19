package main

import "core:fmt"

Not_Started :: struct {}
Completed :: struct { count: int }
Failed :: struct { message: string }
Outcome :: union { Not_Started, Completed, Failed }

show :: proc(result: Outcome) {
    switch value in result {
    case Not_Started:
        fmt.println("not started")
    case Completed:
        fmt.println("completed:", value.count)
    case Failed:
        fmt.println("failed:", value.message)
    case:
        fmt.println("unset")
    }
}

main :: proc() {
    show(Not_Started{})
    show(Completed{count = 3})
    failed: Outcome = Failed{message = "read error"}
    show(failed)
    unset: Outcome
    show(unset)
    _, completed_ok := failed.(Completed)
    fmt.println("completed payload available:", completed_ok)
}
