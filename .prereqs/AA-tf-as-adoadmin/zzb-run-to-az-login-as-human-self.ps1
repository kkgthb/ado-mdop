$script:my_human_upn = (whoami /upn).ToLower()
$script:az_current_user_name = (az account show --query 'user.name' --output 'tsv').ToLower()
$script:az_is_currently_human = ($az_current_user_name -eq $my_human_upn)

Function Switch-AzToHumanSelf {
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

Switch-AzToHumanSelf
