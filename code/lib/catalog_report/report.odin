package catalog_report

import "core:encoding/json"
import "core:slice"
import "core:strings"
import "core:unicode/utf8"

Max_Report :: 1024 * 1024
Max_Entries :: 10_000
Result :: enum { Ok, Size, Syntax, Duplicate_Key, Schema, Version, Entry, Order, Allocation }

valid_path :: proc(path: string) -> bool {
    if len(path) == 0 || len(path) > 4096 || !utf8.valid_string(path) {
        return false
    }
    for r in path {
        if r < 32 || (r >= 127 && r <= 159) || r == '\\' { return false }
    }
    rest := path
    for part in strings.split_iterator(&rest, "/") {
        if part == "" || part == "." || part == ".." { return false }
    }
    return path[len(path)-1] != '/'
}


hex_digit :: proc(c: byte) -> (u32, bool) {
    if c >= '0' && c <= '9' { return u32(c-'0'), true }
    if c >= 'a' && c <= 'f' { return u32(c-'a')+10, true }
    if c >= 'A' && c <= 'F' { return u32(c-'A')+10, true }
    return 0, false
}

hex_quad :: proc(text: string, start: int) -> (u32, bool) {
    if start+4 > len(text) { return 0, false }
    result: u32
    for i in 0..<4 {
        digit, ok := hex_digit(text[start+i])
        if !ok { return 0, false }
        result = result*16 + digit
    }
    return result, true
}

// Inspect the token spelling before a decoder can replace invalid surrogates.
valid_string_escapes :: proc(text: string) -> bool {
    i := 1 // Skip the opening JSON quote.
    for i < len(text)-1 {
        if text[i] != '\\' { i += 1; continue }
        i += 1
        if i >= len(text)-1 { return false }
        if text[i] != 'u' { i += 1; continue }
        first, ok := hex_quad(text, i+1)
        if !ok { return false }
        i += 5
        if first >= 0xDC00 && first <= 0xDFFF { return false }
        if first >= 0xD800 && first <= 0xDBFF {
            if i+6 > len(text)-1 || text[i] != '\\' || text[i+1] != 'u' { return false }
            second, second_ok := hex_quad(text, i+2)
            if !second_ok || second < 0xDC00 || second > 0xDFFF { return false }
            i += 6
        }
    }
    return true
}

validate :: proc(data: []byte) -> Result {
    if len(data) > Max_Report { return .Size }
    if !utf8.valid_string(string(data)) { return .Syntax }
    for b in data {
        if b == 0 { return .Syntax }
    }

    // Bound nesting before recursive parsing. The report only needs three levels.
    tokenizer := json.make_tokenizer(string(data), .JSON, true)
    depth := 0
    previous_token: json.Token_Kind
    previous_empty_string := false
    for {
        token, err := json.get_token(&tokenizer)
        if err == .EOF && token.kind == .EOF { break }
        if err != .None { return .Syntax }
        // Preserve an empty member name before the installed decoder drops it.
        if previous_empty_string && token.kind == .Colon { return .Schema }
        #partial switch token.kind {
        case .Open_Brace, .Open_Bracket:
            depth += 1
            if depth > 3 { return .Schema }
        case .Close_Brace, .Close_Bracket:
            if previous_token == .Comma { return .Syntax }
            depth -= 1
            if depth < 0 { return .Syntax }
        case .String:
            if !valid_string_escapes(token.text) { return .Syntax }

        }
        previous_empty_string = token.kind == .String && token.text == "\"\""
        previous_token = token.kind
    }

    parser := json.make_parser(data, .JSON, true)
    value, err := json.parse_value(&parser)
    if err == .Duplicate_Object_Key { return .Duplicate_Key }
    if err == .Out_Of_Memory { return .Allocation }
    if err != .None { return .Syntax }
    defer json.destroy_value(value)
    if parser.curr_token.kind != .EOF || parser.curr_token_err != .EOF { return .Syntax }

    root, object_ok := value.(json.Object)
    if !object_ok || len(root) != 4 { return .Schema }
    format, format_ok := root["format"].(json.String)
    label, label_ok := root["root"].(json.String)
    items, items_ok := root["entries"].(json.Array)
    version, version_ok := root["version"].(json.Integer)
    if !version_ok || version != 1 { return .Version }
    if !format_ok || format != "resource-catalog" || !label_ok || !valid_path(label) || !items_ok {
        return .Schema
    }
    if len(items) > Max_Entries { return .Size }

    previous := ""
    for item in items {
        fields, fields_ok := item.(json.Object)
        if !fields_ok || len(fields) != 2 { return .Entry }
        path, path_ok := fields["path"].(json.String)
        kind, kind_ok := fields["kind"].(json.String)
        if !path_ok || !kind_ok || !valid_path(path) { return .Entry }
        if kind != "file" && kind != "directory" && kind != "symlink" && kind != "unknown" { return .Entry }
        if previous >= path { return .Order }
        previous = path
    }
    return .Ok
}

// State owns a copy of the accepted report. Rejected input leaves it unchanged.
replace_report :: proc(state: ^[]byte, candidate: []byte) -> Result {
    result := validate(candidate)
    if result != .Ok { return result }
    replacement, err := slice.clone(candidate)
    if err != .None { return .Allocation }
    delete(state^)
    state^ = replacement
    return .Ok
}
