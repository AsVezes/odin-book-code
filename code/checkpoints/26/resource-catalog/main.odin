package main

import "core:fmt"
import "core:os"
import report "../../../lib/catalog_report"

print_help :: proc() {
    fmt.println("Resource catalog")
    fmt.println("Usage: resource-catalog <command> [argument]")
    fmt.println("Commands:")
    fmt.println("  help                Show this help")
    fmt.println("  check <path>        Check whether a path exists")
    fmt.println("  list <directory>    List direct entry names")
    fmt.println("  export <directory> <label>  Write a JSON report to stdout")
    fmt.println("  import <report.json>        Validate and print the accepted report")
}

// Check only path existence; this does not read or validate file contents.
check_path :: proc(path: string) {
    if len(path) == 0 {
        fmt.eprintln("Error: provide a non-empty path.")
        os.exit(2)
    }

    if os.exists(path) {
        fmt.println("Found:", path)
        return
    }

    fmt.eprintln("Not found or unavailable:", path)
    os.exit(1)
}

main :: proc() {
    // The first argument identifies the executable.
    if len(os.args) == 1 {
        print_help()
        return
    }

    command := os.args[1]

    if command == "help" || command == "--help" {
        if len(os.args) != 2 {
            fmt.eprintln("Error: help does not accept extra arguments.")
            os.exit(2)
        }
        print_help()
        return
    }

    if command == "check" {
        if len(os.args) != 3 {
            fmt.eprintln("Usage: resource-catalog check <path>")
            os.exit(2)
        }

        check_path(os.args[2])
        return
    }

    if command == "list" {
        if len(os.args) != 3 || len(os.args[2]) == 0 {
            fmt.eprintln("Usage: resource-catalog list <directory>")
            os.exit(2)
        }
        if !list_entries(os.args[2]) {
            os.exit(1)
        }
        return
    }

    if command == "export" {
        if len(os.args) != 4 || len(os.args[2]) == 0 || len(os.args[3]) == 0 {
            fmt.eprintln("Usage: resource-catalog export <directory> <label>")
            os.exit(2)
        }
        status := report.export_directory(os.args[2], os.args[3])
        if status != 0 { os.exit(status) }
        return
    }

    if command == "import" {
        if len(os.args) != 3 || len(os.args[2]) == 0 {
            fmt.eprintln("Usage: resource-catalog import <report.json>")
            os.exit(2)
        }
        status := report.import_file(os.args[2])
        if status != 0 { os.exit(status) }
        return
    }

    fmt.eprintln("Unknown command:", command)
    print_help()
    os.exit(2)
}
