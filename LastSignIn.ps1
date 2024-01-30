$Scopes = @(
    "User.Read.All",
    "Directory.Read.All",
    "AuditLog.Read.All"
)

Connect-MgGraph -Scopes $Scopes -NoWelcome

# List of users w. a column called ID
$inputCsvPath = "PATH"

# The output file
$outputCsvPath = "PATH"

# Calling the user IDs from line2
$userIdList = Import-Csv -Path $inputCsvPath

# Get and hold the users data
$userData = @()

# Loop through each user ID in the CSV
foreach ($userId in $userIdList) {
    try {
        Write-Host "Processing user: $($userId.Id)"
        $userInfo = Get-MgUser -UserId $userId.Id -Property DisplayName, Mail, SignInActivity |
            Select-Object DisplayName, Mail, 
                     @{Name='LastSignInDateTime'; Expression={$_.SignInActivity.LastSignInDateTime}},
                     @{Name='LastSignInRequestId'; Expression={$_.SignInActivity.LastSignInRequestId}},
                     @{Name='LastNonInteractiveSignInDateTime'; Expression={$_.SignInActivity.LastNonInteractiveSignInDateTime}},
                     @{Name='LastNonInteractiveSignInRequestId'; Expression={$_.SignInActivity.LastNonInteractiveSignInRequestId}}

        $userData += $userInfo

        Write-Host "Successfully processed user: $($userId.Id)"
    } catch {
        Write-Warning "Failed to retrieve data for user ID: $($userId.Id)"
    }
}

# Export
$userData | Export-Csv -Path $outputCsvPath -NoTypeInformation -Force

# Output to let me know its done
Write-Host "User data exported to $outputCsvPath"
