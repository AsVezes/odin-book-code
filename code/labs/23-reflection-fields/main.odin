package main

import "core:fmt"
import "core:reflect"

Player :: struct {
    health: i32,
    name: string,
}

// Synchronous inspection only: no borrowed any escapes this call.
read_i32 :: proc(record: any, field_name: string) -> (i32, bool) {
    field := reflect.struct_field_value_by_name(record, field_name)
    value, ok := field.(i32)
    if !ok { return 0, false }
    return value, true
}

main :: proc() {
    player := Player{health = 75, name = "hero"}
    names := reflect.struct_field_names(Player)
    fmt.println("fields:", len(names))
    for name in names { fmt.println(name) }
    health, health_ok := read_i32(player, "health")
    _, name_ok := read_i32(player, "name")
    _, missing_ok := read_i32(player, "speed")
    fmt.println("health:", health, health_ok)
    fmt.println("name is i32:", name_ok)
    fmt.println("missing is i32:", missing_ok)
}
