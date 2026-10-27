output "entra_logged_in_as" {
  value = data.azuread_client_config.current_entra_context.object_id
  precondition {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", data.azuread_client_config.current_entra_context.object_id))
    error_message = "The entra_logged_in_as output must be a valid GUID in standard UUID/GUID format (e.g., 123e4567-e89b-12d3-a456-426614174000)."
  }
}
output "ado_logged_into_org_name" {
  value = data.azuredevops_client_config.current_ado_context.name
}
output "theadoprojectid" {
  value = data.azuredevops_project.the_ado_project.project_id
  precondition {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", data.azuredevops_project.the_ado_project.project_id))
    error_message = "The theadoprojectid output must be a valid GUID in standard UUID/GUID format (e.g., 123e4567-e89b-12d3-a456-426614174000)."
  }
}

output "ado_logged_in_as" {
  value = module.ado_012_current_user_id.ado_id_for_entra_user
  # Already did validation in sub-module
}
output "ado_gatekeepers_group_id" {
  value = module.ado_014_gatekeepers_group_id.ado_id_for_entra_group
  # Already did validation in sub-module
}

output "ado_preapproved_pipeline_ids_by_name" {
  value = module.ado_022_preapproved_pipeline_ids.ado_pipeline_ids_by_name
}

output "ado_mdp_id" {
  value = module.ado_042_ado_mdp_config.ado_mdp_id
}
output "ado_check_approval_id" {
  value = module.ado_042_ado_mdp_config.ado_check_approval_id
}
output "ado_pipeline_authorization_ids_by_pipeline_name" {
  value = module.ado_042_ado_mdp_config.ado_pipeline_authorization_ids_by_pipeline_name
}
