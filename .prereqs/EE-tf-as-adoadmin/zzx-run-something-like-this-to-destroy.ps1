# Reminder:  to run this Terraform code successfully, 
# you must be logged into the Azure DevOps CLI as an Entra principal that has adequate permissions to manipulate 
# Azure DevOps org and project security details

Push-Location("$PsScriptRoot")

terraform destroy `
    -var workload_nickname="$([Environment]::GetEnvironmentVariable('DEMOS_my_workload_nickname', 'User'))" `
    -var entra_tenant_id="$([Environment]::GetEnvironmentVariable('DEMOS_my_entra_tenant_id', 'User'))" `
    -var ado_organization_url="$([Environment]::GetEnvironmentVariable('DEMOS_my_ado_organization_url', 'User'))" `
    -var ado_project_name="$([Environment]::GetEnvironmentVariable('DEMOS_my_ado_project_name', 'User'))" `
    -var entra_gatekeepers_group_display_name="$([Environment]::GetEnvironmentVariable('DEMOS_my_favorite_security_group_display_name', 'User'))" `
    -var ado_preapproved_pipeline_names="$(ConvertTo-Json -InputObject @([Environment]::GetEnvironmentVariable('DEMOS_my_ado_pipeline_name_1', 'Process')) -Compress)" `
    -input=false `
    -auto-approve

Pop-Location