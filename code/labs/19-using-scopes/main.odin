#+feature using-stmt
package main
import "core:fmt"

Position :: struct { x, y: int }

shift_parameter :: proc(using position: ^Position, dx: int) {
    x += dx
}

main :: proc() {
    position := Position{x = 1, y = 2}
    {
        using position
        x += 3
    }
    shift_parameter(&position, 2)
    fmt.println("position:", position.x, position.y)
}
