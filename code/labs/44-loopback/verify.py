from pathlib import Path
import socket
import subprocess
import sys
import threading
import time


def case(binary, chunks):
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        listener.listen(1)
        listener.settimeout(3)
        port = listener.getsockname()[1]
        errors = []

        def server():
            try:
                peer, _ = listener.accept()
                with peer:
                    if chunks is None:
                        time.sleep(0.5)
                        return
                    for chunk in chunks:
                        peer.sendall(chunk)
                        time.sleep(0.01)
            except OSError as exc:
                errors.append(exc)

        thread = threading.Thread(target=server)
        thread.start()
        try:
            result = subprocess.run([binary, str(port)], timeout=3, capture_output=True, text=True)
        finally:
            thread.join()
        assert not errors, errors
        return result


if __name__ == "__main__":
    binary = str(Path(sys.argv[1]).resolve())
    success = case(binary, [b"PO", b"NG"])
    assert (success.returncode, success.stdout, success.stderr) == (0, "PONG\n", "")
    closed = case(binary, [b"PO"])
    assert closed.returncode == 2 and "peer closed" in closed.stderr
    wrong = case(binary, [b"NOPE"])
    assert wrong.returncode == 2 and "unexpected token" in wrong.stderr
    deadline = case(binary, None)
    assert deadline.returncode == 3 and "deadline" in deadline.stderr
    print("loopback: 4/4")
