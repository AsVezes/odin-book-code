package main

import "core:fmt"
import "core:os"
import "base:runtime"

ready: bool
finished: bool

@(init)
prepare :: proc "contextless" () {
    context = runtime.default_context()
    ready = true
    fmt.println("init")
}

@(fini)
finish :: proc "contextless" () {
    context = runtime.default_context()
    assert(ready && finished)
    fmt.println("fini")
}

main :: proc() {
    assert(ready)
    fmt.println("main")
    defer {
        finished = true
        fmt.println("defer")
    }
    if len(os.args) > 1 {
        switch os.args[1] {
        case "return":
            return
        case "exit":
            os.exit(7)
        }
    }
    fmt.println("work")
}
