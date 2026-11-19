package main

import "core:fmt"

invert_scalar :: proc(value: u64) -> u64 {
    return value ~ 0xffff_ffff_ffff_ffff
}

when ODIN_ARCH == .amd64 {
    invert :: asm(value: u64) -> (result: u64) [
        value -> result = %rax,
    ] {
        not %rax
    }
} else {
    invert :: proc(value: u64) -> u64 {
        return invert_scalar(value)
    }
}

main :: proc() {
    cases := [4]u64{0, 1, 0x55aa, 0xffff_ffff_ffff_ffff}
    for value in cases {
        assert(invert(value) == invert_scalar(value))
    }
    fmt.println("bit inversion: 4/4")
}
