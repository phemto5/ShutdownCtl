# Parameter help description
[Parameter]
[string]
$clientName
# powershell

$comp = "BlackRook"
$testResult = Test-Connection -IPv4 -TcpPort 8985 -TargetName $comp -ErrorVariable $testResult -ErrorAction SilentlyContinue  
if ($testResult) {
    $stopproc = Start-Process powershell -ArgumentList "Stop-Computer $comp -Verbose"
    Write-Host $stopproc.ToString()
    Invoke-WebRequest -Body " was shutdown" -Uri "ntfy.gamenight.dynu.net/client"
}
else {

    Write-Host "$comp is not responding" -ForegroundColor Red 
    Write-Host $testResult
}
