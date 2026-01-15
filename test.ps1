#param (
#    [Parameter(Mandatory = $true)]
#    [string]$PlanJsonPath
#)

# Load Terraform plan JSON
$plan = Get-Content "C:\Users\anon\Desktop\terraformplan.json" -Raw | ConvertFrom-Json

# Filter: only azuread_group + create or delete
$results = $plan.resource_changes | Where-Object {
    $_.type -eq "azuread_group" -and (
        $_.change.actions -contains "create" -or
        $_.change.actions -contains "delete"
    ) -and
    (
        (
            $_.change.after.display_name
        ) -match 'PIM'
    ) -or
    (
        (
            $_.change.before.display_name
        ) -match 'PIM'
    )
}

foreach ($group in $results) {

    $actions = $group.change.actions
    $address = $group.address

    # Prefer display_name from "after", fallback to "before"
    $groupNameAfter = $group.change.after.display_name
    $groupNameBefore = $group.change.before.display_name

    if ($actions -contains "create" -and -not ($actions -contains "delete")) {

        Write-Host "Creating DB entry for group: $groupNameAfter"
        $name = $groupNameAfter.Replace("-PIM", "")
        $pimname = $groupNameAfter
        Write-Host "INSERT INTO TABLE name, piname $name, $pimname"
    }
    elseif ($actions -contains "delete" -and -not ($actions -contains "create")) {

        Write-Host "Deleting DB entry for group: $groupNameBefore"
        $name = $groupNameBefore.Replace("-PIM", "")
        $pimname = $groupNameBefore
        Write-Host "DELETE FROM TABLE WHERE name == '$name' and pimname == '$pimname'"
        

    }
    elseif ($actions -contains "create" -and $actions -contains "delete") {

        Write-Host "Replacing group (delete + create): $groupNameBefore"
        $name = $groupNameAfter.Replace("-PIM", "")
        $pimname = $groupNameBefore
        Write-Host "DELETE FROM TABLE WHERE name == '$name' and pimname == '$pimname'"
        Write-Host "INSERT INTO TABLE name, piname '$name' '$pimname'"
    }
}
