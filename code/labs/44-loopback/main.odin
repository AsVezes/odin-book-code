package main

import "core:fmt"
import "core:net"
import "core:os"
import "core:strconv"
import "core:time"

probe :: proc(port: int) -> int {
    conn, err := net.dial_tcp(net.Endpoint{address = net.IP4_Loopback, port = port})
    if err != nil {
        fmt.eprintln("connect failed:", err)
        return 2
    }
    defer net.close(conn)

    if net.set_blocking(conn, false) != .None {
        fmt.eprintln("could not configure socket")
        return 2
    }

    received: [4]byte
    expected := [4]byte{'P', 'O', 'N', 'G'}
    used := 0
    start := time.tick_now()
    for time.tick_since(start) < 250 * time.Millisecond {
        n, result := net.recv(conn, received[used:])
        #partial switch result {
        case .None:
            if n == 0 {
                fmt.eprintln("peer closed before a complete token")
                return 2
            }
            used += n
            if used == len(received) {
                if received != expected {
                    fmt.eprintln("unexpected token")
                    return 2
                }
                fmt.println("PONG")
                return 0
            }
        case .Would_Block, .Interrupted:
            time.sleep(2 * time.Millisecond)
        case:
            fmt.eprintln("read failed:", result)
            return 2
        }
    }
    fmt.eprintln("read deadline expired")
    return 3
}

main :: proc() {
    if len(os.args) == 2 {
        port, valid := strconv.parse_int(os.args[1], 10)
        if valid && port >= 1 && port <= 65535 {
            status := probe(port)
            if status != 0 { os.exit(status) }
            return
        }
    }
    fmt.eprintln("Usage: loopback <port>")
    os.exit(2)
}
