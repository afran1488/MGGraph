$Scopes = @(
    "User.Read.All",
    "Directory.Read.All",
    "AuditLog.Read.All"
)

Connect-MgGraph -Scopes $Scopes -NoWelcome

# List of users w. a column called ID
$inputCsvPath = "C:\Users\afrancisco_local\OneDrive - JESUIT REFUGEE SERVICE\MFA-ITA-AUDIT_2024-1-30.csv"

# The output file
$outputCsvPath = "C:\Users\afrancisco_local\OneDrive - JESUIT REFUGEE SERVICE\MFA-ITA.csv"

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
                @{Name='LastSignInDateTime'; Expression={$_.SignInActivity.LastSignInDateTime}}

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