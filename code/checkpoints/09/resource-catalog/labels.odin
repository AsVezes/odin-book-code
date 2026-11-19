package main

import "core:fmt"

Label_Status :: enum { Ok, No_Labels, Empty_Label, Duplicate_Label }

Label_Result :: struct {
    status: Label_Status,
    index:  int,
}

validate_labels :: proc(labels: []string) -> Label_Result {
    if len(labels) == 0 {
        return {.No_Labels, -1}
    }
    seen := make(map[string]bool)
    defer delete(seen)
    for label, index in labels {
        if len(label) == 0 {
            return {.Empty_Label, index}
        }
        if _, exists := seen[label]; exists {
            return {.Duplicate_Label, index}
        }
        seen[label] = true
    }
    return {.Ok, -1}
}

run_labels :: proc(labels: []string) -> bool {
    result := validate_labels(labels)
    switch result.status {
    case .Ok:
        for label in labels {
            fmt.println(label)
        }
        return true
    case .No_Labels:
        fmt.eprintln("Usage: resource-catalog labels <name>...")
    case .Empty_Label:
        fmt.eprintln("Empty label at position:", result.index + 1)
    case .Duplicate_Label:
        fmt.eprintln("Duplicate label:", labels[result.index])
    }
    return false
}
