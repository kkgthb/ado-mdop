output "entra_logged_in_as" {
  value = data.azuread_client_config.current_entra_context.object_id
}

output "ado_logged_into_org_name" {
  value = data.azuredevops_client_config.current_ado_context.name
}

output "theadoprojectid" {
  value = data.azuredevops_project.the_ado_project.project_id
}

output "ado_logged_in_as" {
  value = module.ado_012_current_user_id.ado_id_for_entra_user
}
output "ado_gatekeepers_group_id" {
  value = module.ado_014_gatekeepers_group_id.ado_id_for_entra_group
}

output "ado_preapproved_pipeline_ids" {
  value = "TODO_list_of_pipeline_id_strings"
}
