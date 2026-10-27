# Approval checks want ADO identity IDs (UUID storage keys), not Entra object IDs or descriptors.
data "azuredevops_users" "current_ado_user" {
  origin    = "aad"
  origin_id = var.entra_current_logged_in_user_object_id
}
data "azuredevops_storage_key" "current_ado_user" {
  descriptor = one(data.azuredevops_users.current_ado_user.users).descriptor
}
