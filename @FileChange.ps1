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
# The path to the file or directory
[Parameter(ValueFromPipelineByPropertyName)]
[Alias('Fullname')]
[string]
$FilePath = "$pwd",

# A wildcard filter describing the names of files to watch
[Parameter(ValueFromPipelineByPropertyName)]
[string]
$FileFilter,

# A notify filter describing the file changes that should raise events.
[Parameter(ValueFromPipelineByPropertyName)]
[IO.NotifyFilters[]]
$NotifyFilter = @("FileName", "DirectoryName", "LastWrite"),

# If set, will include subdirectories in the watcher.
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
    $fileSystemWatcher.Filter = $FileFilter
    $combinedNotifyFilter = 0
    foreach ($n in $NotifyFilter) {
        $combinedNotifyFilter = $combinedNotifyFilter -bor $n
    }
    $fileSystemWatcher.NotifyFilter = $combinedNotifyFilter
    $fileSystemWatcher
}
