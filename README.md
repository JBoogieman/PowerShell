# PowerShell

Personal collection of PowerShell functions, one per file in `Functions/`.

## Setup

Add this line to your PowerShell profile (`notepad $PROFILE`):

```powershell
. "C:\Users\Justin\Documents\git\PowerShell\Profile.ps1"
```

Restart the shell (or run `. $PROFILE`), and every function in `Functions/` is loaded.

## Functions

| Function | What it does |
| --- | --- |
| `Get-PortOwner <port>` | Shows which process is using a local TCP port |
| `Remove-MergedBranches [-Base main]` | Deletes local git branches already merged into the base branch (supports `-WhatIf`) |
| `Get-BigFiles [-Path .] [-Top 20]` | Lists the largest files under a folder |
| `touch <path>` | Creates an empty file, or updates its timestamp |

Run `Get-Help <function>` for examples.

## Adding a function

Drop a new `Verb-Noun.ps1` file into `Functions/` and add a row to the table above.
