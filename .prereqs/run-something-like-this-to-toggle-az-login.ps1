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