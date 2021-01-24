[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingCmdletAliases", "",
    Justification="These are smart aliases and part of syntax, and auto-fixing them is destructive.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "",
    Justification="Global variables are the simplest way to test event updates.")]
param()

describe OnQ {
    it 'Helps create events' {
        $global:WaitAHalfSecond = $false
        On@Delay -Wait "00:00:00.5" -Then { $global:WaitAHalfSecond = $true; "Waited half second" }
        foreach ($i in 1..4) {
            Start-Sleep -Milliseconds 250
        }

        $global:WaitAHalfSecond | Should -Be $true
    }
    it 'Has a natural syntax' {
        $global:WaitedABit = $false
        on delay -Wait '00:00:00.5' -Then { $global:WaitedABit = $true; "Waited half second"}
        foreach ($i in 1..4) {
            Start-Sleep -Milliseconds 250
        }
        $global:WaitedABit | Should -Be $true
    }
    it 'Can handle an arbitrary signal, and send that signal' {
        $Global:Fired = $false
        on MySignal -Then { $Global:Fired = $true}
        send MySignal
        Start-Sleep -Milliseconds 250
        $Global:Fired | Should -Be $true
    }
    it 'Can pipe in arbitrary data to Send-Event' {
        $randomSourceId = "sourceId$(Get-Random)"
        $inputChecksum = 1..3 |
            Send-Event -SourceIdentifier $randomSourceId -PassThru |
            Select-Object -ExpandProperty MessageData |
            Measure-Object -Sum |
            Select-Object -ExpandProperty Sum

        $inputChecksum | Should -Be (1 + 2 + 3)
    }
    it 'Can Receive-Event sent by Send-Event, and -Clear them.' {
        $randomSourceId = "sourceId$(Get-Random)"
        1..3 |
            Send-Event -SourceIdentifier $randomSourceId 

        $outputchecksum = Receive-Event -SourceIdentifier $randomSourceId -Clear |
            Select-Object -ExpandProperty MessageData |
            Measure-Object -Sum |
            Select-Object -ExpandProperty Sum

        $outputchecksum | Should -Be (1 + 2 + 3)

        (Receive-Event -SourceIdentifier $randomSourceId) | Should -Be $null
    }
    it 'Can get a signal when a job finishes' {
        $global:JobsIsDone = $false
        $j = Start-Job -ScriptBlock { Start-Sleep -Milliseconds 500; "done" }

        $j|
            On@Job -Then { $global:JobsIsDone = $true }

        do  {
            Start-Sleep -Milliseconds 750
        } while ($j.JobStateInfo.State -ne 'Completed')

        Start-Sleep -Milliseconds 250

        $global:JobsIsDone | Should -Be $true
    }

    it 'Can take any piped input with an event, and will treat -SourceIdentifier as the EventName' {
        $MyTimer = [Timers.Timer]::new()
        $MyTimer | Watch-Event -SourceIdentifier Elapsed -Then { "it's time"}
    }

    it 'Can forward an event by providing an empty -Then {}' {
        on repeat "00:00:15" -Then {} # Tell the other Runspace I'm alive every 15 minutes.
        @(
            Get-EventSubscriber -SourceIdentifier repeat* | 
            Where-Object { $_.ForwardEvent }
        ).Length | Should -BeGreaterOrEqual 1
    }

    it 'Can receive results from event subscriptions' {
        $receivedResults = @(Get-EventSource -Name Delay -Subscription | Receive-Event)
        $receivedResults.Length | Should -BeGreaterOrEqual 1
    }


    context EventSources {
        it 'Has a number of built-in event source scripts.' {
            $es = Get-EventSource
            $es |
                Select-Object -ExpandProperty Name |
                Should -BeLike '@*'
        }
        it 'Can clear event sources' {
            $esCount = @(Get-EventSubscriber).Length
            $activeSubCount = @(Clear-EventSource -WhatIf).Length
            $activeSubCount | should -BeGreaterThan 0
            Clear-EventSource
            $esCount2 = @(Get-EventSubscriber).Length
            $esCount | Should -BeGreaterThan $esCount2
        }
    }
}
