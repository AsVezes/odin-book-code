package main

import "core:fmt"

Handle :: struct { slot: int, generation: u32 }
Slot :: struct { generation: u32, value: int, live: bool }
Pool :: struct { slots: [2]Slot }

insert :: proc(pool: ^Pool, value: int) -> (Handle, bool) {
    for &slot, i in pool.slots {
        if !slot.live && slot.generation != max(u32) {
            slot.generation += 1
            slot.value = value
            slot.live = true
            return Handle{i, slot.generation}, true
        }
    }
    return {}, false
}

get :: proc(pool: ^Pool, handle: Handle) -> (int, bool) {
    if handle.slot < 0 || handle.slot >= len(pool.slots) {
        return 0, false
    }
    slot := pool.slots[handle.slot]
    if !slot.live || slot.generation != handle.generation {
        return 0, false
    }
    return slot.value, true
}

remove :: proc(pool: ^Pool, handle: Handle) -> bool {
    _, ok := get(pool, handle)
    if !ok { return false }
    pool.slots[handle.slot].live = false
    return true
}

main :: proc() {
    pool: Pool
    first, ok := insert(&pool, 8)
    assert(ok)
    _, ok = insert(&pool, 13)
    assert(ok)
    _, ok = insert(&pool, 21)
    assert(!ok)
    assert(remove(&pool, first))
    replacement, inserted := insert(&pool, 34)
    old, old_ok := get(&pool, first)
    current, current_ok := get(&pool, replacement)
    assert(inserted && replacement.slot == first.slot)
    assert(!old_ok && old == 0 && current_ok && current == 34)
    fmt.println("stale rejected; replacement:", current)
}
