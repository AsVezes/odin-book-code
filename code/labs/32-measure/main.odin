package main

import "core:fmt"
import "core:time"

Lanes :: #simd[4]u32
Iterations :: 300
Groups :: 4096

scalar :: proc(data: [][4]u32) -> u32 {
    total: u32
    for v in data {
        for i in 0..<4 {
            total += v[i]
        }
    }
    return total
}

vector :: proc(data: [][4]u32) -> u32 {
    total: Lanes
    for v in data {
        total += transmute(Lanes)v
    }
    lanes := transmute([4]u32)total
    return lanes[0] + lanes[1] + lanes[2] + lanes[3]
}

measure :: proc(sum: proc([][4]u32) -> u32, data: [][4]u32) -> (u32, f64) {
    digest: u32
    start := time.tick_now()
    for _ in 0..<Iterations {
        digest += sum(data)
    }
    return digest, time.duration_seconds(time.tick_since(start))
}

main :: proc() {
    data: [Groups][4]u32
    for i in 0..<len(data) {
        data[i] = [4]u32{u32(i % 7), 2, 3, 4}
    }
    expected: u32
    for i in 0..<len(data) {
        expected += u32(i % 7) + 9
    }
    assert(scalar(data[:]) == expected && vector(data[:]) == expected)

    for sample in 0..<6 {
        first, second := scalar, vector
        first_name, second_name := "scalar", "vector"
        if sample % 2 == 1 {
            first, second = second, first
            first_name, second_name = second_name, first_name
        }
        a, a_seconds := measure(first, data[:])
        b, b_seconds := measure(second, data[:])
        assert(a == expected * Iterations && b == a)
        fmt.printf("sample=%d digest=%d first=%s first_seconds=%.9f second=%s second_seconds=%.9f\n", sample, a, first_name, a_seconds, second_name, b_seconds)
    }
}
