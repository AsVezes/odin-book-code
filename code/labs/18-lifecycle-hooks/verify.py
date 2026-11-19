"""Verify process lifecycle behavior on the selected Odin compiler."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument("--odin", default="odin")
parser.add_argument("--evidence", type=Path)
args = parser.parse_args()
source = Path(__file__).with_name("main.odin").read_bytes()
records = []

def run(command, cwd):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, timeout=60)
    records.append(dict(command=[str(x) for x in command], exit_code=result.returncode,
                        stdout=result.stdout, stderr=result.stderr))
    return result

with tempfile.TemporaryDirectory(prefix="odin-lifecycle-") as directory:
    root = Path(directory)
    (root / "main.odin").write_bytes(source)
    version = run([args.odin, "version"], root)
    assert version.returncode == 0, records[-1]
    checked = run([args.odin, "check", str(root)], root)
    assert checked.returncode == 0, records[-1]
    binary = root / ("lifecycle.exe" if os.name == "nt" else "lifecycle")
    built = run([args.odin, "build", str(root), "-out:" + str(binary)], root)
    assert built.returncode == 0, records[-1]
    cases = [([], 0, "init\nmain\nwork\ndefer\nfini\n"),
             (["return"], 0, "init\nmain\ndefer\nfini\n"),
             (["exit"], 7, "init\nmain\n")]
    for arguments, status, expected in cases:
        result = run([str(binary), *arguments], root)
        assert (result.returncode, result.stdout, result.stderr) == (status, expected, ""), records[-1]

evidence = dict(toolchain=version.stdout.strip(), source_sha256=hashlib.sha256(source).hexdigest(),
                results=records, limits=["One init and one fini hook; no ordering claim among multiple hooks.",
                                        "No panic, signal, crash, DLL, or cross-platform verification."])
if args.evidence:
    args.evidence.write_text(json.dumps(evidence, indent=2) + "\n")
print("PASS: normal return, early return, and direct process exit")
