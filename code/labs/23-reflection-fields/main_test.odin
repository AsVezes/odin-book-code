package main

import "core:reflect"
import "core:testing"

@(test)
metadata_and_payload :: proc(t: ^testing.T) {
    names := reflect.struct_field_names(Player)
    testing.expect(t, len(names) == 2)
    if len(names) == 2 {
        testing.expect(t, names[0] == "health")
        testing.expect(t, names[1] == "name")
    }
    player := Player{health = 75, name = "hero"}
    value, ok := read_i32(player, "health")
    testing.expect(t, ok && value == 75)
    _, wrong := read_i32(player, "name")
    testing.expect(t, !wrong)
    _, missing := read_i32(player, "speed")
    testing.expect(t, !missing)
    player.health = -1
    negative, negative_ok := read_i32(player, "health")
    testing.expect(t, negative_ok && negative == -1)
    testing.expect(t, player.name == "hero")
}

@(test)
inspection_boundaries :: proc(t: ^testing.T) {
    Other :: struct { health: i64 }
    Nested :: struct { player: Player }
    other := Other{health = 75}
    nested := Nested{player = Player{health = 75}}
    _, width_ok := read_i32(other, "health")
    _, nested_ok := read_i32(nested, "health")
    _, scalar_ok := read_i32(i32(75), "health")
    _, nil_ok := read_i32(nil, "health")
    testing.expect(t, !width_ok)
    testing.expect(t, !nested_ok)
    testing.expect(t, !scalar_ok)
    testing.expect(t, !nil_ok)
    testing.expect(t, len(reflect.struct_field_names(i32)) == 0)
}
