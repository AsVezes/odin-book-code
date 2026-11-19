# Odin — From Fundamentals to Real Projects: Companion Source Code

Reference source code, tests, exercises and checkpoints for the first English edition of *Odin: From Fundamentals to Real Projects*, by **Elliot Veyran** (As Vezes).

This repository complements the book. The book teaches the reader to build the programs; the files here provide the reference material, especially for labs that explicitly use a supplied library or verifier.

## Download

Use **Code → Download ZIP** at the top of this repository, or clone it:

```sh
git clone https://github.com/AsVezes/odin-book-code.git
cd odin-book-code
```

Run the book's commands from the directory containing `code/`, unless a unit specifies a different working directory. Start with [the source-kit guide](code/READER-START.md) and [the reader setup guide](docs/READER-GUIDE.md).

## Repository contents

- `code/hello-odin/`: first program (Unit 01)
- `code/resource-catalog/`: early reference for the cumulative CLI (Unit 05 baseline)
- `code/checkpoints/`: saved reference stages for comparison
- `code/lib/catalog_report/`: supplied JSON report library and tests (Unit 26)
- `code/labs/`: independent labs and Arena Courier reference material
- `code/tools/verify_native_cli.py`: CLI verification tool used in Unit 34

**Keep your own working copy:** The catalog and the game are developed progressively in the book. Do not replace your current project with a completed checkpoint when moving to a new unit.

## Requirements

Install the Odin compiler and the native dependencies appropriate to your system. For a first check:

```sh
odin version
odin check code/hello-odin
odin run code/hello-odin
```

Some later exercises need Python 3, a C compiler, a platform SDK or separately installed native graphics/physics libraries. This repository does **not** bundle binaries, graphics drivers, SDKs or third-party assets. The source snapshot does not constitute a fresh cross-platform test of every exercise.

## Edition and provenance

The reader code is copied from the private editorial repository `AsVezes/Renda`, at source commit `8c2b18e167a5`. The complete book manuscript, Kindle EPUB, print PDFs, private QA logs and editorial-only tools are not public here. See [SOURCE-PROVENANCE.md](SOURCE-PROVENANCE.md).

## Usage rights

Copyright © 2026 Elliot Veyran / As Vezes. An explicit open-source license has **not yet** been selected. Public access alone does not grant redistribution or relicensing rights.

## Report a problem

Open an issue describing the book unit, OS, `odin version`, command, expected behavior and actual output. Never post passwords, tokens or private files in issues.
