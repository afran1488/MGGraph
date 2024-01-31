$Scopes = @("Directory.Read.All")
Connect-MgGraph -Scopes $Scopes -NoWelcome

$groups = Get-MgGroup -All

$groupsWithDevicesDetails = @()

foreach ($group in $groups) {
    $hasDeviceMember = (Get-MgGroupMember -GroupId $group.Id | Where-Object { $_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.device" }).Count -gt 0
    
    if ($hasDeviceMember) {
        $groupInfo = Get-MgGroup -GroupId $group.Id | Select-Object DisplayName, Id, OnPremisesSyncEnabled, GroupTypes, MembershipRule
        $memberCount = Get-MgGroupMemberCount -GroupId $group.Id -ConsistencyLevel "eventual"

        $details = New-Object PSObject -Property @{
            GroupName = $groupInfo.DisplayName
            GroupId = $groupInfo.Id
            MemberCount = $memberCount
            GroupTypes = ($groupInfo.GroupTypes -join ", ")
            MembershipRule = $groupInfo.MembershipRule
            OnPremisesSyncEnabled = $groupInfo.OnPremisesSyncEnabled
        }

        $groupsWithDevicesDetails += $details
    }
}

$groupsWithDevicesDetails | Export-Csv -Path "$HOME\Downloads\GroupsWithDevicesDetails.csv" -NoTypeInformation

Write-Host "Export completed. Check the file GroupsWithDevicesDetails.csv in your Downloads folder."
