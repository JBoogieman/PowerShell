function Get-BigFiles {
    <#
    .SYNOPSIS
        Lists the largest files under a folder.
    .EXAMPLE
        Get-BigFiles
    .EXAMPLE
        Get-BigFiles -Path C:\Users\Justin\Downloads -Top 10
    #>
    param(
        [string]$Path = '.',
        [int]$Top = 20
    )

    Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $Top FullName,
            @{ n = 'MB'; e = { [math]::Round($_.Length / 1MB, 2) } }
}
