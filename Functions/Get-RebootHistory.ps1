function Get-RebootHistory {
    <#
    .SYNOPSIS
        Shows recent restarts, shutdowns, crashes, and bugchecks from the System event log.
    .DESCRIPTION
        Pulls the System log events that explain why a machine went down:
          1074  Planned restart/shutdown, with the process, user, and reason that started it
          6008  Unexpected shutdown (the previous shutdown wasn't clean)
          41    Kernel-Power: rebooted without shutting down cleanly (crash, power loss, hard reset)
          1001  Bugcheck (BSOD), with the stop code
          6005  Boot (the event log service started)
        Remote machines are read over RPC, so they need the "Remote Event Log Management"
        firewall rule enabled.
    .PARAMETER ComputerName
        One or more computers to check. Defaults to the local machine.
    .PARAMETER Days
        How many days back to look. Defaults to 30.
    .EXAMPLE
        Get-RebootHistory
    .EXAMPLE
        Get-RebootHistory -ComputerName PC01, PC02 -Days 7 | Format-Table -AutoSize
    .EXAMPLE
        Get-RebootHistory -Days 90 | Where-Object Type -in 'Dirty reboot', 'Bugcheck'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('CN', 'Name')]
        [string[]]$ComputerName = $env:COMPUTERNAME,

        [ValidateRange(1, 3650)]
        [int]$Days = 30
    )

    process {
        foreach ($computer in $ComputerName) {
            $params = @{
                FilterHashtable = @{
                    LogName   = 'System'
                    Id        = 1074, 6008, 41, 1001, 6005
                    StartTime = (Get-Date).AddDays(-$Days)
                }
                ErrorAction     = 'Stop'
            }
            # Only pass -ComputerName for remote machines; local reads skip RPC entirely
            if ($computer -notin $env:COMPUTERNAME, 'localhost', '.') {
                $params.ComputerName = $computer
            }

            try {
                $events = Get-WinEvent @params
            }
            catch {
                # Get-WinEvent throws when nothing matches; that's not an error here
                if ($_.FullyQualifiedErrorId -like 'NoMatchingEventsFound*') { continue }
                Write-Error "${computer}: $($_.Exception.Message)"
                continue
            }

            # Other providers also log ID 1001 to System; keep only the WER bugcheck one
            $events = $events | Where-Object {
                $_.Id -ne 1001 -or $_.ProviderName -match 'WER-SystemErrorReporting|BugCheck'
            }

            foreach ($evt in $events) {
                $type = $user = $process = $reason = $null

                switch ($evt.Id) {
                    1074 {
                        # Properties: 0 process, 1 computer, 2 reason, 3 reason code,
                        #             4 shutdown type, 5 comment, 6 user
                        $p       = $evt.Properties
                        $type    = (Get-Culture).TextInfo.ToTitleCase("$($p[4].Value)")
                        $user    = $p[6].Value
                        $process = $p[0].Value -replace '\s+\(.*\)$', ''
                        $reason  = $p[2].Value
                        if ($p[5].Value) { $reason += " | Comment: $($p[5].Value)" }
                    }
                    6008 {
                        $type   = 'Unexpected shutdown'
                        $reason = ($evt.Message -split "`r?`n")[0]
                    }
                    41 {
                        $type = 'Dirty reboot'
                        $code = [int64]$evt.Properties[0].Value
                        $reason = if ($code -eq 0) {
                            'No bugcheck recorded (power loss, hard reset, or hang)'
                        }
                        else {
                            'Bugcheck 0x{0:X}' -f $code
                        }
                    }
                    1001 {
                        $type   = 'Bugcheck'
                        $reason = "Stop code $($evt.Properties[0].Value)"
                    }
                    6005 {
                        $type   = 'Boot'
                        $reason = 'Event log service started'
                    }
                }

                [pscustomobject]@{
                    ComputerName = $evt.MachineName
                    TimeCreated  = $evt.TimeCreated
                    EventId      = $evt.Id
                    Type         = $type
                    User         = $user
                    Process      = $process
                    Reason       = $reason
                }
            }
        }
    }
}
