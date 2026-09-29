function Remove-MergedBranches {
    <#
    .SYNOPSIS
        Deletes local git branches that are already merged into the base branch.
    .DESCRIPTION
        Prunes stale remote-tracking refs, then runs `git branch -d` on every local
        branch merged into -Base. Skips the current branch and main/master/develop.
        Uses -d (not -D), so git refuses to delete anything that isn't fully merged.
    .EXAMPLE
        Remove-MergedBranches
    .EXAMPLE
        Remove-MergedBranches -Base develop -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Base = 'main'
    )

    git fetch --prune

    git branch --merged $Base |
        Where-Object { $_ -notmatch '^\*' } |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and $_ -notin @($Base, 'main', 'master', 'develop') } |
        ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_, 'git branch -d')) {
                git branch -d $_
            }
        }
}
