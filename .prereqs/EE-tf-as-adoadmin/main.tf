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
