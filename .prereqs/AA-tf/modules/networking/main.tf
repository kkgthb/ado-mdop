# The VNET
resource "azurerm_virtual_network" "myvnet" {
  name                = "vnet-${var.workload_nickname}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = ["10.30.0.0/27"]
}

# Azure RBAC role assignments against the VNET
data "azuread_service_principal" "thedoisp" {
  # This is a special built in service principal.  See:
  # https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking#check-the-principal-access-for-devopsinfrastructure
  # Its Microsoft-assigned universal client ID is "31687f79-5e43-4c1e-8c63-d9f4bff5cf8b"
  display_name = "DevOpsInfrastructure"
}
resource "azurerm_role_assignment" "myvnetreaderra" {
  scope                = azurerm_virtual_network.myvnet.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_service_principal.thedoisp.object_id
}
resource "azurerm_role_assignment" "myvnetnetcontribra" {
  scope                = azurerm_virtual_network.myvnet.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.thedoisp.object_id
}

# A subnet within the VNET
resource "azurerm_subnet" "mysubnet" {
  name                 = "subnet-${var.workload_nickname}"
  resource_group_name  = var.resource_group.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.30.0.0/28"]
  delegation {
    name = "managed-devops-pool"
    service_delegation {
      name = "Microsoft.DevOpsInfrastructure/pools"
    }
  }
  lifecycle {
    ignore_changes = [
      delegation, # ENHANCEMENT:  find something more elegant than this, eventually
    ]
  }
}
