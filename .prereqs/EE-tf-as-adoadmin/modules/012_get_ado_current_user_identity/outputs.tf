output "ado_id_for_entra_current_logged_in_user" {
  value = data.azuredevops_storage_key.current_ado_user.id
}
