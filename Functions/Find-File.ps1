function Find-File {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name,
        
        [string]$Path = $PWD
    )
    Get-ChildItem -Path $Path -Filter "*$Name*" -Recurse -ErrorAction SilentlyContinue | 
        Select-Object FullName, Length, LastWriteTime
}
