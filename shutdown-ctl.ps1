# Parameter help description
[CmdletBinding()]
Param(
    [Parameter()]
    [string]
    $clientName
)
# powershell
if ($clientName) {
    $comp = $clientName
    $testResult = Test-Connection -IPv4 -TcpPort 8985 -TargetName $comp -ErrorVariable $testResult -Quiet  
    if ($testResult) {
        $stopproc = Start-Process powershell -ArgumentList "Stop-Computer $comp -Verbose"
        Write-Host $stopproc.ToString()
        Invoke-WebRequest -Body "$comp was shutdown" -Uri "ntfy.gamenight.dynu.net/client"
    }
    else {
        Write-Host "$comp is not responding" -ForegroundColor Red 
        Write-Host $testResult
    }
}
else {
    $AwakeComputers = [System.Collections.ArrayList]::new()
    for ($i = 50; $i -lt 249; ++$i) {
        $address = "192.168.1.$i"
        Write-Host "`r$i" -NoNewline -ForegroundColor Blue
        $testRes = Test-Connection  -IPv4 -TargetName $address -Quiet -TimeoutSeconds 1 -Count 1 -Delay 1 
        if ($testRes) {
            Write-Host "$testRes $address" -ForegroundColor Green
            $otherdata = Test-Connection -IPv4 -TargetName $address -Ping -ResolveDestination -TimeoutSeconds 1 -Count 1 -Delay 1 -ErrorAction SilentlyContinue
            write-host $otherdata.Destination
            $AwakeComputers.Add("$address - $($otherdata.Destination)")
        }
    }
    Invoke-WebRequest -Body "$($AwakeComputers -join ",")) are awake" -Uri "ntfy.gamenight.dynu.net/client" -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
}