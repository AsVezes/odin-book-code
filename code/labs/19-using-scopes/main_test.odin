#+feature using-stmt
package main
import "core:testing"

@(test)
statement_alias :: proc(t: ^testing.T) {
    position := Position{x = 1, y = 2}
    {
        using position
        x += 3
        testing.expect(t, position.x == 4 && y == 2)
    }
    testing.expect(t, position.x == 4 && position.y == 2)
}

@(test)
parameter_alias :: proc(t: ^testing.T) {
    position := Position{x = 4, y = 2}
    shift_parameter(&position, 2)
    testing.expect(t, position.x == 6 && position.y == 2)
    shift_parameter(&position, 0)
    testing.expect(t, position.x == 6 && position.y == 2)
    shift_parameter(&position, -3)
    testing.expect(t, position.x == 3 && position.y == 2)
}
