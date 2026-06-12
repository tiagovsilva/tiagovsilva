@{
    Severity = @(
        'Error'
        'Warning'
    )

    Rules = @{
        PSAvoidUsingPlainTextForPassword = @{
            Enable = $true
        }
    }
}
