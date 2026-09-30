function Test-Port {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$true, Position=1)]
        [int]$Port
    )
    $result = Test-NetConnection -ComputerName $ComputerName -Port $Port -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) {
        Write-Host "$ComputerName : $Port is OPEN" -ForegroundColor Green
    } else {
        Write-Host "$ComputerName : $Port is CLOSED" -ForegroundColor Red
    }
}
