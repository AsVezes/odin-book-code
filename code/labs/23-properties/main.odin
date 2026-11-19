package main

import "core:fmt"
import "core:math"

Outcome :: enum { Accepted, UnknownProperty, WrongType, InvalidValue }

inspect :: proc(name: string, payload: any) -> Outcome {
    switch name {
    case "health":
        value, ok := payload.(i32)
        if !ok { return .WrongType }
        if value < 0 || value > 100 { return .InvalidValue }
    case "speed":
        value, ok := payload.(f64)
        if !ok { return .WrongType }
        if math.is_nan(value) || math.is_inf(value, 0) || value < 0 { return .InvalidValue }
    case "name":
        value, ok := payload.(string)
        if !ok { return .WrongType }
        if len(value) == 0 { return .InvalidValue }
    case:
        return .UnknownProperty
    }
    return .Accepted
}

main :: proc() {
    fmt.println(inspect("health", i32(0)))
    fmt.println(inspect("health", "101"))
    fmt.println(inspect("health", i32(101)))
    fmt.println(inspect("color", "oops"))
}
