package score

import "core:os"

Read_Result :: enum { Valid, Missing, Invalid, IO_Error }

encode :: proc(points: u32) -> [8]byte {
    return {'A', 'R', '1', 0, byte(points), byte(points >> 8), byte(points >> 16), byte(points >> 24)}
}

decode :: proc(data: []byte) -> (u32, bool) {
    if len(data) != 8 || data[0] != 'A' || data[1] != 'R' || data[2] != '1' || data[3] != 0 {
        return 0, false
    }
    return u32(data[4]) | (u32(data[5]) << 8) | (u32(data[6]) << 16) | (u32(data[7]) << 24), true
}

load :: proc(path: string) -> (u32, Read_Result) {
    file, err := os.open(path)
    if err == .Not_Exist { return 0, .Missing }
    if err != nil       { return 0, .IO_Error }
    defer os.close(file)

    buffer: [9]byte
    used := 0
    for used < len(buffer) {
        read, read_error := os.read(file, buffer[used:])
        used += read
        if read_error == .EOF { break }
        if read_error != nil    { return 0, .IO_Error }
        if read == 0           { break }
    }
    points, ok := decode(buffer[:used])
    if !ok { return 0, .Invalid }
    return points, .Valid
}

save :: proc(path, temporary: string, points: u32) -> bool {
    bytes := encode(points)
    file, err := os.create(temporary)
    if err != nil { return false }

    written, write_error := os.write(file, bytes[:])
    close_error := os.close(file)
    if write_error != nil || close_error != nil || written != len(bytes) {
        _ = os.remove(temporary)
        return false
    }
    if os.rename(temporary, path) != nil {
        _ = os.remove(temporary)
        return false
    }
    return true
}
