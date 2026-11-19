package main
import "core:testing"

@(test)
payload_selection :: proc(t: ^testing.T) {
    completed: Outcome = Completed{count = 3}
    value, ok := completed.(Completed)
    testing.expect(t, ok)
    if ok { testing.expect(t, value.count == 3) }
    failed: Outcome = Failed{message = "read error"}
    _, wrong := failed.(Completed)
    testing.expect(t, !wrong)
    error, matches := failed.(Failed)
    testing.expect(t, matches)
    if matches { testing.expect(t, error.message == "read error") }
}

@(test)
representation_boundaries :: proc(t: ^testing.T) {
    unset: Outcome
    started: Outcome = Not_Started{}
    testing.expect(t, unset == nil)
    testing.expect(t, started != nil)
    // A union selects a payload type; it does not enforce its numeric range.
    negative: Outcome = Completed{count = -1}
    value, ok := negative.(Completed)
    testing.expect(t, ok)
    if ok { testing.expect(t, value.count < 0) }
}
