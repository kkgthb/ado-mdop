data "azuread_service_principal" "thedoisp" {
  # This is a special built in service principal.  See:
  # https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking#check-the-principal-access-for-devopsinfrastructure
  # Its Microsoft-assigned universal client ID is "31687f79-5e43-4c1e-8c63-d9f4bff5cf8b"
  display_name = "DevOpsInfrastructure"
}

resource "azurerm_resource_group" "my_resource_group" {
  provider = azurerm.demo
  name     = "${var.workload_nickname}-rg-demo"
  location = "centralus"
}

