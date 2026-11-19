# Start here — Odin reader kit

Extract the archive into its own folder. Open the book or the included
Markdown manuscript alongside the code. For your first two sources, use
Route A in the reader guide. If you already started typing the programs,
use its section on adding material later. Look for “Reader Guide — Set Up
Your Working Copy” in the book or at
`editorial/manuscrito/en-US/reader-files-and-working-copy.md` in a kit
that includes the manuscript.

Keep three locations distinct:

- The extracted kit and its example sources. Copy `code/hello-odin/main.odin`
  and `code/checkpoints/01/resource-catalog/main.odin` for Unit 01. The
  catalog directly under `code/resource-catalog/` is the Unit 05 reference.
- Your writable project folders. The early units call your working folder
  containing `code/` the **book root**. Start in Unit 01 for the catalog and
  Unit 36 for Arena Courier. In Units 41–43 the Arena directory is your
  own folder containing `sim/`, `score/`, `window/`, and `headless/`.
- Your installed Odin release, whose packages include the official
  libraries and bindings. It lives outside the kit.

Set up Odin in Unit 01, Section 2, then use `odin version` to identify your compiler. Edition examples were
checked on Linux amd64 with `dev-2026-11-nightly:9a69916` (the
`dev-2026-11a` release) unless a lesson records a different scope.
Your platform needs the matching linker and SDK. Python 3 is used for
verification scripts, and a C compiler with an archive tool is needed
for the C ABI lab. Arena's window needs a graphical display and the
native libraries named by the installed Raylib binding. A headless run
only exercises the simulation and files. The Box2D appendix also requires
a compatible native Box2D library. The standard source kit includes no
compiler, native libraries, graphics driver, or third-party assets.

Before distributing a rebuilt executable or sharing an archive, inventory
**what you actually ship**: source files, generated images, linked native
libraries, and any copied third-party material. The Odin Raylib binding is
not proof that a compatible Raylib binary is present; likewise, the Box2D
appendix's binding is not a Box2D library. Inspect the licenses and notice
requirements for the exact versions and artifacts you include, and keep
their notices with the distribution where required. Do not copy binaries
or artwork into the kit merely to make an example launch. The source
candidate's manifest and SHA-256 checks prove only the bytes that were
packaged; they do **not** establish license clearance, dependency
completeness, or permission to publish. For a local exercise, record the
installed library versions and distinguish dependencies supplied by Odin,
installed separately, and actually redistributed.

The version notes (`editorial/FONTES_E_VERSOES.md` in the full kit) record
the edition baseline and platform scope. The ZIP manifest describes
file paths, sizes and SHA-256 digests. For a QA candidate, the notice in
the archive identifies its status and any outstanding distribution checks.
