@{
    RootModule = 'OnQ.psm1'
    Description = 'Event based asynchronous scripting with PowerShell'
    ModuleVersion = '0.1'
    GUID = 'ba5ad698-89a1-4887-9511-59f9025989b1'
    Author = 'James Brundage'
    Copyright = '2021 Start-Automating'
    FormatsToProcess = 'OnQ.format.ps1xml'
    TypesToProcess = 'OnQ.types.ps1xml'
    PrivateData = @{
        PSData = @{
            Tags = 'OnQ', 'Events'
        }
        OnQ = @{
            'Time' = '@Time.ps1'
            'Delay' = '@Delay.ps1'            
            'ModuleChanged' = 'EventSources/@ModuleChanged.ps1'
            'Job' = 'EventSources/@Job.ps1'
        }
    }
}
