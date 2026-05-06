# Reminder:  to run this Terraform code successfully, 
# you must be logged into the Azure CLI as an Entra principal that has adequate permissions to manipulate 
# both Azure and Azure DevOps.

$gh_cli_logged_in_user = (gh auth status --active --json 'hosts' --jq '.hosts."github.com"[0].login')
$current_repo_owner = (gh repo view --json 'owner' --jq '.owner.login')
If ($gh_cli_logged_in_user -ne $current_repo_owner) {
    gh auth switch --user $current_repo_owner
}

# Reinforce robot identity
[Environment]::SetEnvironmentVariable('ARM_TENANT_ID', [Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id', 'User'), 'Process')
[Environment]::SetEnvironmentVariable('ARM_CLIENT_ID', [Environment]::GetEnvironmentVariable('DEMOS_my_favorite_workload_identity_client_id', 'User'), 'Process')
[Environment]::SetEnvironmentVariable('ARM_CLIENT_SECRET', [Environment]::GetEnvironmentVariable('DEMOS_my_favorite_workload_identity_secret', 'User'), 'Process')

Push-Location("$PsScriptRoot/AA-tf")

terraform init

terraform plan `
    -var entra_tenant_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id', 'User'))" `
    -var az_sub_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_azure_subscription_id', 'User'))" `
    -var workload_nickname="$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))" `
    -var ado_organization_url="$([Environment]::GetEnvironmentVariable('DEMOS_my_ado_organization_url', 'User'))" `
    -var ado_project_name="$([Environment]::GetEnvironmentVariable('DEMOS_my_ado_project_name', 'User'))" `
    -var ms_devopsinfrastructure_object_id="$([Environment]::GetEnvironmentVariable('DEMOS_MS_FirstParty_ObjectId_In_My_Entra_For_DevOpsInfrastructure', 'User'))"

Pop-Location

# Tear down bonus robot identity
[Environment]::SetEnvironmentVariable('ARM_CLIENT_SECRET', $null, 'Process')
[Environment]::SetEnvironmentVariable('ARM_CLIENT_ID', $null, 'Process')
[Environment]::SetEnvironmentVariable('ARM_TENANT_ID', $null, 'Process')
