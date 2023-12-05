# Parameter help description
[CmdletBinding()]
Param(
    [Parameter()]
    [string]
    $clientName,
    [Parameter()]
    [bool]
    $All = $false,
    [Parameter()]
    [bool]
    $Search = $false
)
$compusers =@("hplapy.anderson.local","")
function RemoteShutdown {
    param (
        $comp
    )
    $testResult = Test-Connection -IPv4 -TargetName $comp -ErrorVariable $testResult -Quiet  
    if ($testResult) {
        Start-Process -NoNewWindow -FilePath powershell -ArgumentList "Stop-Computer $comp -Verbose" 
        # Write-Host $stopproc.ToString()
        Invoke-WebRequest -Method Post -Body "$comp was shutdown" -Uri "ntfy.gamenight.dynu.net/client" -OutFile "resp.json" 
        # Invoke-Item .\resp.json
    }
    else {
        Write-Host "Test result as $testResult so $comp is not responding" -ForegroundColor Red 
        # Write-Host $testResult??
    }
}

function SeachAll {
    
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
    Invoke-WebRequest -Method Post -Body "$(  ConvertTo-Json $AwakeComputers )) are awake" -Uri "ntfy.gamenight.dynu.net/client" -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
}
if ($All) {
    foreach ($comp in $compusers) {
        RemoteShutdown($comp )
    }
}
else {
    if ($Search) {
        SeachAll
    }
    else {
        if ($clientName) {
            RemoteShutdown($clientName )
        }
    }
}