# ----------- Entra tenant auth spot-check ------------
data "azuread_client_config" "current_entra_context" {
  provider = azuread.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into Entra as expected."
    }
  }
}

# ----------- ADO org auth spot-check ------------
data "azuredevops_client_config" "current_ado_context" {
  provider = azuredevops.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into ADO as expected."
    }
  }
}

# ----------- ADO identity translations ------------
module "ado_012_current_user_id" {
  depends_on = [data.azuread_client_config.current_entra_context]
  source     = "./modules/012_get_ado_current_user_identity"
  providers = {
    azuredevops = azuredevops.demo
  }
  entra_current_logged_in_user_object_id = data.azuread_client_config.current_entra_context.object_id
}
