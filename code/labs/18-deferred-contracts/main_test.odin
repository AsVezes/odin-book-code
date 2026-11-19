package main
import "core:testing"

early_delta :: proc(counter: ^Counter) {
    begin_delta(counter)
    counter.value += 2
    return
}

@(test)
input_then_output :: proc(t: ^testing.T) {
    counter := Counter{value = 5}
    {
        begin_delta(&counter)
        counter.value += 2
        {
            begin_delta(&counter)
            counter.value += 3
        }
        testing.expect(t, counter.delta == 3)
    }
    testing.expect(t, counter.value == 10 && counter.delta == 5)
    early_delta(&counter)
    testing.expect(t, counter.value == 12 && counter.delta == 2)
}

@(test)
no_arguments :: proc(t: ^testing.T) {
    group_depth = 0
    groups_closed = 0
    {
        begin_group()
        testing.expect(t, group_depth == 1 && groups_closed == 0)
        {
            begin_group()
            testing.expect(t, group_depth == 2)
        }
        testing.expect(t, group_depth == 1 && groups_closed == 1)
    }
    testing.expect(t, group_depth == 0 && groups_closed == 2)
}
