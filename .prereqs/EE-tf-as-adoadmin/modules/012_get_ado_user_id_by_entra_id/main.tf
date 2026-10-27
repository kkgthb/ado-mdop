# Approval checks want ADO identity IDs (UUID storage keys), not Entra object IDs or descriptors.
data "azuredevops_users" "ado_users" {
  origin    = "aad"
  origin_id = var.entra_user_object_id
}
data "azuredevops_storage_key" "ado_user" {
  descriptor = one(data.azuredevops_users.ado_users.users).descriptor
}
