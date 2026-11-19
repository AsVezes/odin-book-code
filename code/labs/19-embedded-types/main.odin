package main
import "core:fmt"

Position :: struct { x, y: int }
Explicit :: struct { position: Position, name: string }
Promoted :: struct { kind: u8, using position: Position, name: string }
Convertible :: struct { kind: u8, #subtype position: Position, name: string }

move_right :: proc(position: ^Position) {
    position.x += 1
}

main :: proc() {
    explicit := Explicit{position = Position{x = 2}, name = "plain"}
    promoted := Promoted{position = Position{x = 2}, name = "using"}
    convertible := Convertible{position = Position{x = 2}, name = "subtype"}
    move_right(&explicit.position)
    move_right(&promoted)
    move_right(&convertible)
    fmt.println("explicit:", explicit.position.x)
    fmt.println("using:", promoted.x, promoted.position.x)
    fmt.println("subtype:", convertible.position.x)
}
