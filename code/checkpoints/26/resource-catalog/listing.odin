package main

import "core:fmt"
import "core:os"
import "core:slice"

by_name :: proc(a, b: os.File_Info) -> bool {
    return a.name < b.name
}

list_entries :: proc(path: string) -> bool {
    allocator := context.allocator
    entries, err := os.read_all_directory_by_path(path, allocator)
    if err != nil {
        fmt.eprintln("Could not list:", path, os.error_string(err))
        return false
    }
    defer os.file_info_slice_delete(entries, allocator)

    slice.sort_by(entries, by_name)
    for entry in entries {
        fmt.println(entry.name)
    }
    return true
}

