function Test-PendingReboot {
    <#
    .SYNOPSIS
    Checks if the local system has a pending reboot.
    
    .EXAMPLE
    Test-PendingReboot
    #>
    
    $rebootPending = $false

    # Check Component Based Servicing
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") { 
        $rebootPending = $true 
    }
    
    # Check Windows Update
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") { 
        $rebootPending = $true 
    }
    
    # Check Pending File Rename Operations
    $pendingRenames = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -ErrorAction SilentlyContinue
    if ($pendingRenames) { 
        $rebootPending = $true 
    }

    return $rebootPending
}
