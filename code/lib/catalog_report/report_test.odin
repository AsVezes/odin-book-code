package catalog_report

import "core:testing"

Good :: `{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"audio.ogg","kind":"file"},{"path":"images","kind":"directory"}]}`

@(test)
reject_without_replacing :: proc(t: ^testing.T) {
    state: []byte
    defer delete(state)
    testing.expect(t, replace_report(&state, transmute([]byte)string(Good)) == .Ok)
    cases := [?]struct { input: string, want: Result }{
        {`{"format":"resource-catalog","version":1,"root":"assets","r\u006fot":"other","entries":[]}`, .Duplicate_Key},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[]} {}`, .Syntax},
        {`{"format":"resource-catalog","version":1.0,"root":"assets","entries":[]}`, .Version},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[],"":null}`, .Schema},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"a//b","kind":"file"}]}`, .Entry},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"","kind":"file"}]}`, .Entry},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"z","kind":"file"},{"path":"a","kind":"file"}]}`, .Order},
    }
    for fixture in cases {
        testing.expect_value(t, replace_report(&state, transmute([]byte)fixture.input), fixture.want)
        testing.expect_value(t, string(state), Good)
    }
}


@(test)
unicode_and_schema_boundaries :: proc(t: ^testing.T) {
    state: []byte
    defer delete(state)
    good := transmute([]byte)string(Good)
    testing.expect_value(t, replace_report(&state, good), Result.Ok)
    cases := [?]struct { input: string, want: Result }{
        {`{"format":"resource-catalog","version":1,"root":"asset\ud800","entries":[]}`, .Syntax},
        {`{"format":"resource-catalog","version":1,"root":"asset\udc00","entries":[]}`, .Syntax},
        {`{"format":"resource-catalog","version":1,"root":"asset\udc00\ud800","entries":[]}`, .Syntax},
        {`{"format":"resource-catalog","version":1,"root":"asset\ud800x","entries":[]}`, .Syntax},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"a\u0000b","kind":"file"}]}`, .Entry},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"a\u0001b","kind":"file"}]}`, .Entry},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":2,"kind":"file"}]}`, .Entry},
        {`{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"a","kind":"file"},{"path":"\u0061","kind":"file"}]}`, .Order},
    }
    for fixture in cases {
        testing.expect_value(t, replace_report(&state, transmute([]byte)fixture.input), fixture.want)
        testing.expect_value(t, string(state), Good)
    }
    escaped :: `{"format":"resource-catalog","version":1,"root":"asset\ud83d\ude80","entries":[]}`
    literal :: `{"format":"resource-catalog","version":1,"root":"asset🚀","entries":[]}`
    testing.expect_value(t, validate(transmute([]byte)string(escaped)), Result.Ok)
    testing.expect_value(t, validate(transmute([]byte)string(literal)), Result.Ok)
}

@(test)
byte_limits_and_bounded_output :: proc(t: ^testing.T) {
    input := make([]byte, Max_Report+1)
    defer delete(input)
    for i in 0..<len(input) { input[i] = ' ' }
    copy(input, string(Good))
    testing.expect_value(t, validate(input[:Max_Report]), Result.Ok)
    testing.expect_value(t, validate(input), Result.Size)

    path := make([]byte, 4097)
    defer delete(path)
    for i in 0..<len(path) { path[i] = 'a' }
    testing.expect(t, valid_path(string(path[:4096])))
    testing.expect(t, !valid_path(string(path)))

    entries: [0]Report_Entry
    report := Report{"resource-catalog", 1, "assets", entries[:]}
    buffer := make([]byte, Max_Report)
    defer delete(buffer)
    bytes, result := encode_bounded(report, buffer)
    testing.expect_value(t, result, Result.Ok)
    exact := len(bytes)
    _, exact_result := encode_bounded(report, buffer[:exact])
    testing.expect_value(t, exact_result, Result.Ok)
    refused, short_result := encode_bounded(report, buffer[:exact-1])
    testing.expect_value(t, short_result, Result.Size)
    testing.expect_value(t, len(refused), 0)
}

@(test)
late_entry_type_failure_preserves_complete_report :: proc(t: ^testing.T) {
    // The final entry is invalid JSON-schema data, not a JSON syntax error.
    // A failure must preserve both prior entries, their kinds, and their order.
    state: []byte
    defer delete(state)
    testing.expect_value(t, replace_report(&state, transmute([]byte)string(Good)), Result.Ok)

    invalid_last_kind :: `{"format":"resource-catalog","version":1,"root":"assets","entries":[{"path":"audio.ogg","kind":"file"},{"path":"images","kind":true}]}`
    testing.expect_value(
        t,
        replace_report(&state, transmute([]byte)string(invalid_last_kind)),
        Result.Entry,
    )
    testing.expect_value(t, string(state), Good)

    // A valid empty report must replace the old state; rejection is not emptiness.
    empty :: `{"format":"resource-catalog","version":1,"root":"assets","entries":[]}`
    testing.expect_value(t, replace_report(&state, transmute([]byte)string(empty)), Result.Ok)
    testing.expect_value(t, string(state), string(empty))
}
