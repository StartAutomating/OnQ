<#
.Synopsis
    Watches a process.
.Description
    Watches a process.

    If -Exit is passed, watches for process exit.

    If -Output is passed, watches for process output

    If -Error is passed, watched for process error
#>
param(
[Parameter(Mandatory,ValueFromPipelineByPropertyName)]
[int]
$ProcessID,

[Parameter(ValueFromPipelineByPropertyName)]
[switch]
$Exit,

[switch]
$StandardOutput,

[switch]
$StandardError
)

$eventNames = @(
    if ($Exit) {
        "Exited"
    }
    if ($StandardOutput) {
        "OutputDataReceived"
    }
    if ($StandardError) {
        "ErrorDataReceived"
    }
)

if ($eventNames) {
    Get-Process -Id $ProcessID |
        Add-Member EventName $eventNames -Force -PassThru
} else {
    Get-Process -Id $ProcessID |
        Add-Member EventName "Exited" -Force -PassThru
}
