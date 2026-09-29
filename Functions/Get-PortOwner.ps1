function Get-PortOwner {
    <#
    .SYNOPSIS
        Shows which process is listening on (or connected via) a local TCP port.
    .EXAMPLE
        Get-PortOwner 3000
    #>
    param(
        [Parameter(Mandatory)]
        [int]$Port
    )

    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, State,
            @{ n = 'PID';     e = { $_.OwningProcess } },
            @{ n = 'Process'; e = { (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).ProcessName } }
}
