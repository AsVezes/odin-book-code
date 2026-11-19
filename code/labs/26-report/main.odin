package main

import "core:fmt"
import "core:os"
import report "../../lib/catalog_report"

main :: proc() {
    status := 2
    if len(os.args) == 3 && os.args[1] == "import" {
        status = report.import_file(os.args[2])
    } else if len(os.args) == 4 && os.args[1] == "export" {
        status = report.export_directory(os.args[2], os.args[3])
    } else {
        fmt.eprintln("Usage: report-lab import <report.json> | export <directory> <label>")
    }
    if status != 0 { os.exit(status) }
}
