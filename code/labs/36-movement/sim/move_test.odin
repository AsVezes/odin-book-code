package sim

import "core:testing"

@(test)
movement :: proc(t: ^testing.T) {
    x := step(320, true, false)
    x = step(x, true, false)
    testing.expect(t, x == 310)
    testing.expect(t, step(x, true, true) == 310)
    testing.expect(t, step(13, true, false) == 12)
    testing.expect(t, step(627, false, true) == 628)
}
