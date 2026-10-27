output "ado_id_for_entra_user" {
  value = data.azuredevops_storage_key.ado_user.id
  precondition {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", data.azuredevops_storage_key.ado_user.id))
    error_message = "The ado_id_for_entra_user output must be a valid GUID in standard UUID/GUID format (e.g., 123e4567-e89b-12d3-a456-426614174000)."
  }
}
