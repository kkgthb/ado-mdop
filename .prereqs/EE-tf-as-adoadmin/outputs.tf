output "entra_logged_in_as" {
  value = data.azuread_client_config.current_entra_context.object_id
}

output "ado_logged_into_org_name" {
  value = data.azuredevops_client_config.current_ado_context.name
}

output "ado_logged_in_as" {
  value = module.ado_012_current_user_id.ado_id_for_entra_current_logged_in_user
}
