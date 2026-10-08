module "ado_grant_servprinc_agent_admin" {
  source = "./modules/ado_grant_servprinc_agent_admin"
  providers = {
    azuredevops = azuredevops.demo
  }
  entra_grantee_principal_object_id = var.entra_grantee_principal_object_id
  ado_project_name                  = var.ado_project_name
}
