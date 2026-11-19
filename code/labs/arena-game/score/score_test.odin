package score

import "core:testing"

@(test)
bytes_are_versioned :: proc(t: ^testing.T) {
    sample := encode(0x01020304)
    testing.expect(t, sample == [8]byte{'A', 'R', '1', 0, 4, 3, 2, 1})
    result, ok := decode(sample[:])
    testing.expect(t, ok && result == 0x01020304)
    _, truncated := decode(sample[:7])
    testing.expect(t, !truncated)
    sample[2] = '2'
    _, future := decode(sample[:])
    testing.expect(t, !future)
}
