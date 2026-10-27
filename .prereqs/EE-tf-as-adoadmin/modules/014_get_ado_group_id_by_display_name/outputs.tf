output "ado_id_for_entra_group" {
  value = data.azuredevops_group.ado_group_cicdgatekeepers.group_id
  precondition {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", data.azuredevops_group.ado_group_cicdgatekeepers.group_id))
    error_message = "The ado_id_for_entra_group output must be a valid GUID in standard UUID/GUID format (e.g., 123e4567-e89b-12d3-a456-426614174000)."
  }
}
