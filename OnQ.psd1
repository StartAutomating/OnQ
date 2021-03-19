@{
    RootModule = 'OnQ.psm1'
    Description = 'Easy Asynchronous Event-Driven Scripting with PowerShell'
    ModuleVersion = '0.1.2'
    GUID = 'ba5ad698-89a1-4887-9511-59f9025989b1'
    Author = 'James Brundage'
    Copyright = '2021 Start-Automating'
    FormatsToProcess = 'OnQ.format.ps1xml'
    TypesToProcess = 'OnQ.types.ps1xml'
    AliasesToExport = '*'
    PrivateData = @{
        PSData = @{
            ProjectURI = 'https://github.com/StartAutomating/OnQ'
            LicenseURI = 'https://github.com/StartAutomating/OnQ/blob/master/LICENSE'

            Tags = 'OnQ', 'Events'

            ReleaseNotes = @'
0.1.2:
---
New Event Source:
* UDP

PowerShellAsync Event Source now allows for a -Parameter dictionaries.
0.1.1:
---
New Event Sources:
* HTTPResponse
* PowerShellAsync

New Event Source Capabilities:

Event Sources can now return an InitializeEvent property or provide a ComponentModel.InitializationEvent attribute.
This will be called directly after the subscription is created, so as to avoid signalling too soon.

0.1:
---
Initial Module Release.

Fun simple event syntax (e.g. on mysignal {"do this"} or on delay "00:00:01" {"do that"})
Better pipelining support for Sending events.

'@
        }


        OnQ = @{
            'Time' = '@Time.ps1'
            'Delay' = '@Delay.ps1'
            'Process' = 'EventSources/@Process.ps1'
            'ModuleChanged' = 'EventSources/@ModuleChanged.ps1'
            'Job' = 'EventSources/@Job.ps1'
            'PowerShellAsync' = 'EventSources/@PowerShellAsync.ps1'
            'HttpResponse' = 'EventSources/@HttpResponse.ps1'
            UDP = 'EventSources/@UDP.ps1'
        }
    }
}
