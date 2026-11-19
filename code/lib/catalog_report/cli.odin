package catalog_report

import "core:encoding/json"
import "core:fmt"
import "core:io"
import "core:os"
import "core:slice"

read_candidate :: proc(path: string, buffer: []byte) -> ([]byte, os.Error) {
    file, err := os.open(path)
    if err != nil { return nil, err }
    defer os.close(file)
    used := 0
    for used < len(buffer) {
        n, read_error := os.read(file, buffer[used:])
        used += n
        if read_error == .EOF { break }
        if read_error != nil { return nil, read_error }
        if n == 0 { break }
    }
    return buffer[:used], nil
}

import_file :: proc(path: string) -> int {
    buffer := make([]byte, Max_Report + 1)
    defer delete(buffer)
    data, err := read_candidate(path, buffer)
    if err != nil {
        fmt.eprintln("Read failed:", os.error_string(err))
        return 1
    }
    state: []byte
    defer delete(state)
    result := replace_report(&state, data)
    if result != .Ok {
        fmt.eprintln("Report rejected:", result)
        return 1
    }
    return emit(state)
}

emit :: proc(data: []byte) -> int {
    written, write_error := os.write(os.stdout, data)
    if write_error != nil || written != len(data) {
        fmt.eprintln("Could not write accepted report")
        return 1
    }
    return 0
}

Report_Entry :: struct { path, kind: string }
Report :: struct { format: string, version: int, root: string, entries: []Report_Entry }

by_name :: proc(a, b: os.File_Info) -> bool {
    return a.name < b.name
}


// The caller owns the full buffer; returned bytes only borrow its used prefix.
Bounded_Output :: struct { buffer: []byte, used: int, overflow: bool }
bounded_write :: proc(data: rawptr, mode: io.Stream_Mode, bytes: []byte, offset: i64, whence: io.Seek_From) -> (i64, io.Error) {
    output := cast(^Bounded_Output)data
    #partial switch mode {
    case .Query:
        return io.query_utility({.Write})
    case .Write:
        if len(bytes) > len(output.buffer)-output.used {
            output.overflow = true
            return 0, .Short_Write
        }
        copy(output.buffer[output.used:], bytes)
        output.used += len(bytes)
        return i64(len(bytes)), nil
    case:
        return 0, .Unsupported
    }
}

encode_bounded :: proc(report: Report, buffer: []byte) -> ([]byte, Result) {
    output := Bounded_Output{buffer = buffer}
    writer := io.Writer{procedure = bounded_write, data = &output}
    err := json.marshal_to_writer(writer, report)
    if output.overflow { return nil, .Size }
    if err != nil { return nil, .Schema }
    return buffer[:output.used], .Ok
}

export_directory :: proc(path, label: string) -> int {
    allocator := context.allocator
    files, err := os.read_directory_by_path(path, Max_Entries + 1, allocator)
    if err != nil {
        fmt.eprintln("Could not list:", path, os.error_string(err))
        return 1
    }
    defer os.file_info_slice_delete(files, allocator)
    if len(files) > Max_Entries {
        fmt.eprintln("Too many entries")
        return 1
    }
    slice.sort_by(files, by_name)
    entries := make([]Report_Entry, len(files))
    defer delete(entries)
    for f, i in files {
        kind := "unknown"
        #partial switch f.type {
        case .Regular: kind = "file"
        case .Directory: kind = "directory"
        case .Symlink: kind = "symlink"
        }
        entries[i] = {f.name, kind}
    }
    buffer, allocation_error := make([]byte, Max_Report)
    if allocation_error != nil {
        fmt.eprintln("Could not allocate report buffer")
        return 1
    }
    defer delete(buffer)
    bytes, encode_result := encode_bounded(Report{"resource-catalog", 1, label, entries}, buffer)
    if encode_result != .Ok {
        fmt.eprintln("Could not encode report:", encode_result)
        return 1
    }
    result := validate(bytes)
    if result != .Ok {
        fmt.eprintln("Report rejected:", result)
        return 1
    }
    return emit(bytes)
}
