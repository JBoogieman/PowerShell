function touch {
    <#
    .SYNOPSIS
        Creates an empty file, or updates its timestamp if it already exists.
    .EXAMPLE
        touch notes.txt
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
    }
    else {
        New-Item $Path -ItemType File | Out-Null
    }
}
