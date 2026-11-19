package sim

Width :: 640
Height :: 360
Player_Y :: 320
Tick_Seconds :: 1.0 / 60.0

step :: proc(x: int, left, right: bool) -> int {
    movement := 0
    if left  { movement -= 5 }
    if right { movement += 5 }
    return clamp(x + movement, 12, Width - 12)
}
