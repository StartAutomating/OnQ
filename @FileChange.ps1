<#
.Synopsis
    Watches for File Changes.
.Description
    Uses the [IO.FileSystemWatcher] to watch for changes to files.
#>
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
$Recurse,

# The names of the file change events to watch.
# By default, watches for Changed, Created, Deleted, or Renamed
[ValidateSet('Changed','Created','Deleted','Renamed')]
[string[]]
$EventName = @('Changed','Created','Deleted','Renamed')
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
    $fileSystemWatcher | 
        Add-Member NoteProperty EventName $EventName -Force -PassThru
}
