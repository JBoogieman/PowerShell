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
| `Find-File <name> [-Path .]` | Recursively finds files whose name contains the search text |
| `Get-BigFiles [-Path .] [-Top 20]` | Lists the largest files under a folder |
| `Get-InstalledSoftware` | Lists installed software from the registry Uninstall keys (64- and 32-bit), without touching `Win32_Product` |
| `Get-MsiInfo <path>` | Reads ProductCode, UpgradeCode, version, and publisher from an MSI without installing it (accepts pipeline input) |
| `Get-PortOwner <port>` | Shows which process is using a local TCP port |
| `Get-RebootHistory [-ComputerName PC01] [-Days 30]` | Shows recent restarts, shutdowns, crashes, and bugchecks from the System log, including who or what triggered them |
| `Remove-MergedBranches [-Base main]` | Deletes local git branches already merged into the base branch (supports `-WhatIf`) |
| `Test-PendingReboot` | Returns `$true` if Windows has a reboot pending (CBS, Windows Update, or pending file renames) |
| `Test-Port <computer> <port>` | Checks whether a TCP port is open on a remote host |
| `touch <path>` | Creates an empty file, or updates its timestamp |

Run `Get-Help <function>` for examples.

## Adding a function

Drop a new `Verb-Noun.ps1` file into `Functions/` and add a row to the table above.
