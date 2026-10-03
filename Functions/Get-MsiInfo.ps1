function Get-MsiInfo {
    <#
    .SYNOPSIS
        Reads the ProductCode, UpgradeCode, version, and publisher from an MSI without installing it.
    .DESCRIPTION
        Opens the MSI's internal database read-only through the WindowsInstaller COM object
        and pulls values from its Property table. Useful for MECM detection methods and
        building uninstall command lines.
    .PARAMETER Path
        One or more .msi files. Accepts pipeline input from Get-ChildItem.
    .EXAMPLE
        Get-MsiInfo .\7z2408-x64.msi
    .EXAMPLE
        Get-ChildItem C:\Installers -Filter *.msi -Recurse | Get-MsiInfo | Format-Table ProductName, ProductVersion, ProductCode
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string[]]$Path
    )

    begin {
        # The WindowsInstaller COM object doesn't expose type info to PowerShell, so
        # $installer.OpenDatabase() fails with "method not found". Every call below goes
        # through .GetType().InvokeMember() (late binding) instead.
        $installer = New-Object -ComObject WindowsInstaller.Installer
        $query = 'SELECT `Property`, `Value` FROM `Property`'
    }

    process {
        foreach ($item in $Path) {
            $resolved = Resolve-Path -LiteralPath $item -ErrorAction SilentlyContinue
            if (-not $resolved) {
                Write-Error "File not found: $item"
                continue
            }
            $file = $resolved.ProviderPath

            $db = $view = $record = $null
            try {
                # Mode 0 = msiOpenDatabaseModeReadOnly, so the MSI is never modified
                $db   = $installer.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $installer, @($file, 0))
                $view = $db.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $db, @($query))
                [void]$view.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $view, $null)

                # Walk every row of the Property table into a hashtable
                $props  = @{}
                $record = $view.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $view, $null)
                while ($null -ne $record) {
                    $name  = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, @(1))
                    $value = $record.GetType().InvokeMember('StringData', 'GetProperty', $null, $record, @(2))
                    $props[$name] = $value
                    $record = $view.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $view, $null)
                }

                [pscustomobject]@{
                    ProductName     = $props['ProductName']
                    ProductVersion  = $props['ProductVersion']
                    Manufacturer    = $props['Manufacturer']
                    ProductCode     = $props['ProductCode']
                    UpgradeCode     = $props['UpgradeCode']
                    UninstallString = if ($props['ProductCode']) { "msiexec.exe /x $($props['ProductCode']) /qn" }
                    Path            = $file
                }
            }
            catch {
                Write-Error "Couldn't read '$file' as an MSI: $($_.Exception.GetBaseException().Message)"
            }
            finally {
                # COM keeps the .msi locked until these are released, which blocks you
                # from moving or deleting the file for the rest of the session
                if ($view) { [void]$view.GetType().InvokeMember('Close', 'InvokeMethod', $null, $view, $null) }
                foreach ($com in @($record, $view, $db)) {
                    if ($com) { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($com) }
                }
                [GC]::Collect()
                [GC]::WaitForPendingFinalizers()
            }
        }
    }

    end {
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($installer)
    }
}
