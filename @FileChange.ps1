<#
.Synopsis
    Watches for File Changes.
.Description
    Uses the [IO.FileSystemWatcher] to watch for changes to files.
#>
[Diagnostics.Tracing.EventSource(Name='Changed')]
[Diagnostics.Tracing.EventSource(Name='Created')]
[Diagnostics.Tracing.EventSource(Name='Deleted')]
[Diagnostics.Tracing.EventSource(Name='Renamed')]
param(
[Parameter(ValueFromPipelineByPropertyName)]
[Alias('Fullname')]
[string]
$FilePath = "$pwd",

[Parameter(ValueFromPipelineByPropertyName)]
[string]
$FileFilter,

[Parameter(ValueFromPipelineByPropertyName)]
[IO.NotifyFilters[]]
$NotifyFilter = @("FileName", "DirectoryName", "LastWrite"),

[Alias('InludeSubsdirectory','InludeSubsdirectories')]
[switch]
$Recurse
)

process {
    $resolvedFilePath = try {
        $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($FilePath)
    } catch {
        Write-Error "Could not resolve path '$FilePath'"
        return
    }

    $fileSystemWatcher = [IO.FileSystemWatcher]::new($(
        if ($resolvedFilePath) {
            $resolvedFilePath
        } else {
            $FilePath
        }
    ))


    $fileSystemWatcher.EnableRaisingEvents =$true
    $fileSystemWatcher.IncludeSubdirectories = $Recurse
    $combinedNotifyFilter = 0
    foreach ($n in $NotifyFilter) {
        $combinedNotifyFilter = $combinedNotifyFilter -bor $n
    }
    $fileSystemWatcher.NotifyFilter = $combinedNotifyFilter
    $fileSystemWatcher
}
