$script:my_human_upn = (whoami /upn).ToLower()
$script:my_robotic_clientid = [System.Environment]::GetEnvironmentVariable('DEMOS_my_favorite_workload_identity_client_id')
$script:my_robotic_objectid = [System.Environment]::GetEnvironmentVariable('DEMOS_my_favorite_workload_identity_object_id')
$script:az_current_user_name = (az account show --query 'user.name' --output 'tsv').ToLower()
$script:az_is_currently_human = ($az_current_user_name -eq $my_human_upn)
$script:az_is_currently_robot = ($az_current_user_name -eq $my_robotic_clientid)

Function Switch-ToHuman {
    If ($az_is_currently_human) {
        Write-Host "You are already human; no az login work to do."
        Return # short-circuit
    }
    Write-Host "Switching to human (pssst -- check your background windows for a popup to log in with)"
    (
        az login `
            --allow-no-subscriptions `
            --tenant "$([Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id'))"
    )
    Write-Host "Switched to human"
}

# [Environment]::SetEnvironmentVariable('DEMOS_my_favorite_workload_identity_secret', (
# az ad app credential reset `
# --id "$my_robotic_clientid" `
# --display-name "LogLaptopAzCliInAsServicePrincipal" `
# --end-date ((Get-Date).AddDays(7).ToString("yyyy-MM-dd")) `
# --query 'password' `
# --output 'tsv'
# ), 'User')
# [Environment]::SetEnvironmentVariable('DEMOS_my_favorite_workload_identity_secret', (
#     [Environment]::GetEnvironmentVariable('DEMOS_my_favorite_workload_identity_secret', 'User')
# ), 'Process')

# [Environment]::SetEnvironmentVariable('DEMOS_MS_FirstParty_ObjectId_In_My_Entra_For_DevOpsInfrastructure', (
#         az ad sp show `
#             --id '31687f79-5e43-4c1e-8c63-d9f4bff5cf8b' `
#             --query 'id' `
#             --output 'tsv'
#     ), 'User')
# [Environment]::SetEnvironmentVariable('DEMOS_MS_FirstParty_ObjectId_In_My_Entra_For_DevOpsInfrastructure', (
#     [Environment]::GetEnvironmentVariable('DEMOS_MS_FirstParty_ObjectId_In_My_Entra_For_DevOpsInfrastructure', 'User')
# ), 'Process')

Function Switch-ToRobot {
    If ($az_is_currently_robot) {
        Write-Host "You are already a robot; no az login work to do."
        Return # short-circuit
    }
    Write-Host "Switching to robot"
    (
        az login `
            --allow-no-subscriptions `
            --tenant "$([Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id'))" `
            --service-principal `
            --username "$my_robotic_clientid" `
            --password "$([Environment]::GetEnvironmentVariable('DEMOS_my_favorite_workload_identity_secret'))"
    )
    Write-Host "Switched to robot"
}

$visible_ado_repos_count = (
    # Credit JMESpath counting https://stackoverflow.com/a/64508522
    az repos list `
        --org "$([Environment]::GetEnvironmentVariable('DEMOS_my_ado_organization_url', 'User'))" `
        --project "$([Environment]::GetEnvironmentVariable('DEMOS_my_ado_project_name', 'User'))" `
        --query '[] | length(@)' `
        --output 'tsv'
)
If ((-not $visible_ado_repos_count) -or ($visible_ado_repos_count -eq 0)) {
    Write-Error 'Your current logged-in state does not seem to have access to any repos in your ADO project of choice.  That seems weird.'
    # My service principal currently errors out as follows:
    # VS800075: The project with id 'vstfs:///Classification/TeamProject/CENSORED' does not exist, or you do not have permission to access it.
    # Update:  it seems better now, with 0, instead of an error.  Had to also set `View project-level information` (https://stackoverflow.com/a/60733122)
}
Else {
    Write-Host "You seem to have access to see $visible_ado_repos_count repos in this ADO project; looks like a good authZ dummy-check start."
}

$ado_queues_url = ([Environment]::GetEnvironmentVariable('DEMOS_my_ado_organization_url', 'User') + [Environment]::GetEnvironmentVariable('DEMOS_my_ado_project_name', 'User') + '/_apis/distributedtask/queues?api-version=7.1')
$visible_ado_queues_count = (
    # Credit JMESpath counting https://stackoverflow.com/a/64508522
    az rest `
        --method 'GET' `
        --resource '499b84ac-1321-427f-aa17-267ca6975798' `
        --url "$ado_queues_url" `
        --query 'count' `
        --output 'tsv'
)
If ((-not $visible_ado_queues_count) -or ($visible_ado_queues_count -eq 0)) {
    Write-Error 'Your current logged-in state does not seem to have access to any queues in your ADO project of choice.  That seems weird.'
    # Interesting:  I get an "ERROR: Not Found(...)" containing the following, when I made my service principal a queues admin but apparently that is not project membership enough:
    # {
    #     "$id": "1",
    #     "innerException": null,
    #     "message": "VS800075: The project with id 'vstfs:///Classification/TeamProject/CENSORED' does not exist, or you do not have permission to access it.",
    #     "typeName": "Microsoft.TeamFoundation.Core.WebApi.ProjectDoesNotExistException, Microsoft.TeamFoundation.Core.WebApi",
    #     "typeKey": "ProjectDoesNotExistException",
    #     "errorCode": 0,
    #     "eventId": 3000
    # }
    # Update:  it seems better now, with the same count as my human, instead of an error.  Had to also set `View project-level information` (https://stackoverflow.com/a/60733122)
}
Else {
    Write-Host "You seem to have access to see $visible_ado_queues_count queues in this ADO project; looks like a good authZ dummy-check start."
}

Function Set-RobotPrivilegesHigh {
    Switch-ToHuman
    $robotic_owner_role_assignment = (
        az role assignment list `
            --include-groups `
            --include-inherited `
            --assignee-object-id $my_robotic_objectid `
            --role 'Owner' `
            --scope "/subscriptions/$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id'))" `
            --query '[].id' `
            --output 'tsv'
    )
    If ($robotic_owner_role_assignment) {
        Write-Host "Robot seems to have already been assigned high privileges; you're good to go."
        Return # short-circuit
    }
    Write-Host "Up-privileging robot"
    (
        az role assignment create `
            --assignee "$my_robotic_clientid" `
            --role 'Owner' `
            --scope "/subscriptions/$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id'))" `
    )
    Write-Host "Robot up-privileged"
}

Function Set-RobotPrivilegesLow {
    Switch-ToHuman
    $robotic_owner_role_assignment = (
        az role assignment list `
            --include-groups `
            --include-inherited `
            --assignee-object-id $my_robotic_objectid `
            --role 'Owner' `
            --scope "/subscriptions/$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id'))" `
            --query '[].id' `
            --output 'tsv'
    )
    If (-not $robotic_owner_role_assignment) {
        Write-Host "Robot seems to have already been deprivileged; you're good to go."
        Return # short-circuit
    }
    Write-Host "Deprivileging robot"
    (
        az role assignment delete `
            --ids "$robotic_owner_role_assignment"
    )
    Write-Host "Robot deprivileged"
}

# Switch-ToHuman
# Switch-ToRobot
# Set-RobotPrivilegesHigh
# Set-RobotPrivilegesLow