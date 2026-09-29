# Dot-source every function in .\Functions so they're available in the session.
# Load from your $PROFILE with:
#   . "C:\Users\Justin\Documents\git\PowerShell\Profile.ps1"

Get-ChildItem -Path (Join-Path $PSScriptRoot 'Functions') -Filter *.ps1 |
    ForEach-Object { . $_.FullName }
