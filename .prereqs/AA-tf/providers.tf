# Configure the AzureRM provider
provider "azurerm" {
  features {}
  alias                           = "demo"
  tenant_id                       = var.entra_tenant_id
  subscription_id                 = var.az_sub_id
  resource_provider_registrations = "none"
}

# Configure the AzureDevOps provider
provider "azuredevops" {
  alias           = "demo"
  tenant_id       = var.entra_tenant_id
  org_service_url = trimsuffix(var.ado_organization_url, "/")
}
