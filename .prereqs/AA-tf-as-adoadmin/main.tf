data "azuredevops_client_config" "current_azuredevops_config" {
  provider = azuredevops.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into ADO as expected."
    }
  }
}

module "ado_grant_servprinc_agent_admin" {
  depends_on = [data.azuredevops_client_config.current_azuredevops_config]
  source     = "./modules/ado_grant_servprinc_agent_admin"
  providers = {
    azuredevops = azuredevops.demo
  }
  entra_grantee_principal_object_id = var.entra_grantee_principal_object_id
  ado_organization_url              = var.ado_organization_url
  ado_project_name                  = var.ado_project_name
}
