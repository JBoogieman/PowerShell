function Get-InstalledSoftware {
    <#
    .SYNOPSIS
    Retrieves installed software from registry hives, bypassing Win32_Product.
    
    .EXAMPLE
    Get-InstalledSoftware | Out-GridView
    #>
    
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    Get-ItemProperty $paths -ErrorAction SilentlyContinue | 
        # Filter out system components and child updates to keep the list clean
        Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 -and $_.ParentKeyName -eq $null } |
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | 
        Sort-Object DisplayName
}
