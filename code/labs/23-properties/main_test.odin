package main

import "core:testing"

@(test)
property_contract :: proc(t: ^testing.T) {
    testing.expect_value(t, inspect("health", i32(0)), Outcome.Accepted)
    testing.expect_value(t, inspect("health", i32(101)), Outcome.InvalidValue)
    testing.expect_value(t, inspect("health", "40"), Outcome.WrongType)
    testing.expect_value(t, inspect("speed", f64(-1)), Outcome.InvalidValue)
    testing.expect_value(t, inspect("name", ""), Outcome.InvalidValue)
    testing.expect_value(t, inspect("color", i32(3)), Outcome.UnknownProperty)
    testing.expect_value(t, inspect("speed", f64(0)), Outcome.Accepted)
    testing.expect_value(t, inspect("speed", f64(2.5)), Outcome.Accepted)
    testing.expect_value(t, inspect("name", "hero"), Outcome.Accepted)

    nan := transmute(f64)u64(0x7ff8000000000000)
    infinity := transmute(f64)u64(0x7ff0000000000000)
    testing.expect_value(t, inspect("speed", nan), Outcome.InvalidValue)
    testing.expect_value(t, inspect("speed", infinity), Outcome.InvalidValue)
    testing.expect_value(t, inspect("color", "oops"), Outcome.UnknownProperty)
}
