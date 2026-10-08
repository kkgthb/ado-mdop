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
output "ado_proj_name" {
  value = data.azuredevops_project.the_ado_project.name
}
output "ado_proj_group_descriptor" {
  value = local.proj_group_descriptor
}
output "ado_proj_group_id" {
  value = local.proj_group_id
}
output "ado_proj_pooladmins_desired_permissions" {
  value = local.ado_proj_pooladmins_desired_permissions
}
