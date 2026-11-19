package main
import "core:testing"

@(test)
promoted_alias :: proc(t: ^testing.T) {
    object := Promoted{kind = 17, position = Position{x = 2, y = 8}, name = "using"}
    base: ^Position = &object
    testing.expect(t, base == &object.position)
    move_right(base)
    testing.expect(t, object.x == 3 && object.position.x == 3)
    object.x = 9
    testing.expect(t, object.position.x == 9)
    testing.expect(t, object.kind == 17 && object.y == 8 && object.name == "using")
}

@(test)
subtype_alias :: proc(t: ^testing.T) {
    object := Convertible{kind = 23, position = Position{x = 2, y = 8}, name = "subtype"}
    base: ^Position = &object
    testing.expect(t, base == &object.position)
    move_right(base)
    testing.expect(t, object.position.x == 3)
    testing.expect(t, object.kind == 23 && object.position.y == 8 && object.name == "subtype")
}
