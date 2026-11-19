# Reader Guide — Set Up Your Working Copy

Choose how to start. Both routes lead to the same two programs in Unit 01 and the same catalog in Unit 02. You can do the folder setup before installing Odin. Unit 01, Section 2, walks you through installing or locating the compiler.

**Free companion source code:** https://github.com/AsVezes/odin-book-code

Download the source kit from that repository using **Code > Download ZIP**, or clone it with Git. It contains the reference checkpoints, labs, the Unit 26 report library, and verification tools used in later units. The book's introductory examples can still be typed without downloading anything. Original companion code is MIT-licensed; third-party dependencies have separate terms.

| If you have… | Start here |
|---|---|
| The source kit for this edition | Extract it to its own folder, then use Route A to copy the two Unit 01 sources. |
| The book and an editor | Use Route B to type the two listings as you read Unit 01. You can start without a repository account or a download. |

Pick instructions that match your **host and shell**. Blocks marked POSIX use a shell such as `sh` or Bash. Blocks marked Windows PowerShell use PowerShell and name Windows executables with `.exe`. Units 34 and 43 package native Windows x64 ZIPs and Linux archives in separate recipes. Run the extraction tests for your own platform. A cross-target check verifies the compiler's checks for that target. Runtime evidence comes from the intended platform.

## Create a folder for your work

Call the folder `odin-work` or choose any name you like. Keep it separate from the source kit and the Odin installation. Use a fresh folder for a new project. If you already started writing the catalog, keep your existing working folder and use [Add material from the kit later](#add-material-from-the-kit-later).

On Linux or macOS:

```sh
work_root="$HOME/odin-work"
mkdir "$work_root" &&
    cd "$work_root" &&
    mkdir -p code/hello-odin code/resource-catalog
```

On Windows PowerShell:

```powershell
$workRoot = Join-Path $env:USERPROFILE 'odin-work'
New-Item -ItemType Directory -Path $workRoot -ErrorAction Stop | Out-Null
Set-Location -LiteralPath $workRoot -ErrorAction Stop
New-Item -ItemType Directory -Path 'code/hello-odin','code/resource-catalog' -Force -ErrorAction Stop
```

If the new folder name is already taken, choose another name before repeating the setup. In the first units, **book root** means this working folder, the one containing your `code/`. For example, `odin run code/hello-odin` starts from `odin-work`, one level above `code/`. When a later recipe asks for the extracted kit's location separately, give it that folder's full path.

## Route A — Start from an extracted kit

Keep the extracted folder as a source of examples and comparisons. In your file manager, copy each file from the left column into the folder on the right. Both files are named `main.odin`, so check their parent folders.

| Path in the extracted kit | Folder in your working copy |
|---|---|
| `code/hello-odin/main.odin` | `odin-work/code/hello-odin/` |
| `code/checkpoints/01/resource-catalog/main.odin` | `odin-work/code/resource-catalog/` |

The kit's separate `code/resource-catalog/` reference already includes the Unit 05 refactor. For Unit 01, start with the source under `code/checkpoints/01/`. Open both copies in your editor, then continue with Unit 01. For the kit's layout and tools, see `code/READER-START.md` inside the extracted folder.

## Route B — Type the programs as you go

Keep the two folders empty until Unit 01 introduces their programs. Type the greeting from Section 3 in `code/hello-odin/main.odin` and the catalog starting point from Section 6 in `code/resource-catalog/main.odin`. Save as UTF-8 plain text. If the editor hides extensions, check that the full filename ends in `.odin`.

## Check and continue

In Unit 01, Section 2, locate or install Odin and confirm its version. If setup took your terminal into the compiler directory, return to your working folder in the same terminal. Run the exercises from there. The greeting prints `Hello, Odin!`. The starting catalog prints `Resource catalog — starting point`. If you copied the programs, compare each one with the listing as you read it. Then predict and try the same small changes as a reader who typed it.

If a run seems to use the wrong program, check where you are with `pwd` on Linux or macOS or `Get-Location` in PowerShell. Open `code/hello-odin/main.odin` from that location and check the greeting in the file. A successful run from the kit can still leave your working file untested.

Unit 02 changes the catalog you already started. At the end, run the new CLI's `help` and `check` commands from your working folder. Section 5 of Unit 02 shows how to check their messages and exit statuses.

## Add material from the kit later

Extract the kit beside your working folder. Leave the catalog you have typed in `odin-work/code/resource-catalog/`. Use the paths below when you reach those activities.

| When you need it | What to use |
|---|---|
| Unit 06, comparison tests for union outcomes | Run the printed example in a scratch folder. For the supplied tests, use `code/labs/06-union-outcomes/` in the kit. Copy that one lab folder under `odin-work/code/labs/` if you want to edit the supplied test or source. |
| Later standalone labs | Open the named lab under the kit's `code/labs/`. If the exercise requires edits, follow the unit's layout in a writable copy. Keep any relative imports or fixture paths intact. |
| Unit 26, catalog report library | Create `odin-work/code/lib/catalog_report/` if it is absent. Copy only `report.odin`, `cli.odin`, and `report_test.odin` from the kit's `code/lib/catalog_report/` to that folder. If you already have those files, compare before replacing them. Unit 26 shows how to add the `../lib/catalog_report` import to your existing catalog. |
| Unit 34, release verification | Keep the kit accessible for `code/tools/verify_native_cli.py`. Build from `odin-work` and point the recipe's `kit_root` at the extracted kit. |

After adding a supplied lab or library, rerun the last catalog checkpoint you reached in your working folder. Include `labels` once you finish Unit 09 and `list` once you finish Unit 25. That gives you a baseline before integrating any new behavior.

## Start a separate Arena working folder

When you reach Unit 36, create a writable folder named `arena` beside your catalog folder and the extracted kit. Build the movement lab there from the listings. From that point, Arena commands such as `odin test sim` start inside this folder. U37 continues with `sim/` and `window/`. U40 adds `score/` and `headless/`.

Keep the kit at its own path so its Arena reference stays available for comparison. For U41 and U43, give the recipes the absolute path of that kit when they ask for the supplied verifier. Run the build from your `arena` folder. This is the folder you carry forward after every Arena milestone.

**Use this reference**

Before adding files from the kit, identify which chapter owns the next edit. Keep your working source and compare the relevant checkpoint file by file. After a copy or edit, rerun the last chapter's verification command from the same directory.
