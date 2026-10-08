output "ado_grantee_principal_descriptor" {
  value = azuredevops_service_principal_entitlement.grantee_sp.descriptor
}
output "ado_org_group_descriptor" {
  value = local.org_group_descriptor
}
output "ado_org_group_id" {
  value = local.org_group_id
}
output "ado_org_pooladmins_desired_permissions" {
  value = local.ado_org_pooladmins_desired_permissions
}
