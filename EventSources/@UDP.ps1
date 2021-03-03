<#

#>
param(
[Parameter(ValueFromPipelineByPropertyName)]
[Net.IPAddress]
$IPAddress = [Net.IPAddress]::Any,

[Parameter(Mandatory,ValueFromPipelineByPropertyName)]
[int]
$Port,

[Parameter(ValueFromPipelineByPropertyName)]
[Text.Encoding]
$Encoding
)

$UdpBackgroundJob = {
    param($IPAddress, $port, $encoding)
    
    $udpSvr=  [Net.Sockets.UdpClient]::new()
    $endpoint = [Net.IpEndpoint]::new($IPAddress, $Port)

    try {
        $udpSvr.Client.Bind($endpoint)
    } catch  {
        Write-Error -Message $_.Message -Exception $_
        return
    }
    $eventSourceId = "UDP.${IPAddress}:$port"
    Register-EngineEvent -SourceIdentifier $eventSourceId -Forward
    if ($encoding) {
        $RealEncoding  = [Text.Encoding]::GetEncoding($encoding.BodyName)
        if (-not $RealEncoding) {
            throw "Could not find $($encoding | Out-String)"
        }
    }
    while ($true) {
        $packet = $udpSvr.Receive([ref]$endpoint)

        if ($RealEncoding) {            
            New-Event -Sender $IPAddress -MessageData $RealEncoding.GetString($packet) -SourceIdentifier $eventSourceId |
                Out-Null
        } else {
            New-Event -Sender $IPAddress -MessageData $packet -SourceIdentifier $eventSourceId  | Out-Null
        }
        
    }
}

$startedJob = Start-Job -ScriptBlock $UdpBackgroundJob -ArgumentList $IPAddress, $port, $Encoding
@{
    SourceIdentifier = "UDP.${IPAddress}:$port"
}


