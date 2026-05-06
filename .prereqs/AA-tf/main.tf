resource "azurerm_resource_group" "my_resource_group" {
  provider = azurerm.demo
  name     = "${var.workload_nickname}-rg-demo"
  location = "centralus"
}

module "networking" {
  source = "./modules/networking"
  providers = {
    azurerm = azurerm.demo
  }
  resource_group = {
    id       = azurerm_resource_group.my_resource_group.id
    name     = azurerm_resource_group.my_resource_group.name
    location = azurerm_resource_group.my_resource_group.location
  }
  workload_nickname = var.workload_nickname
}

module "compute" {
  depends_on = [ module.networking ]
  source = "./modules/compute"
  providers = {
    azurerm = azurerm.demo
  }
  resource_group = {
    id       = azurerm_resource_group.my_resource_group.id
    name     = azurerm_resource_group.my_resource_group.name
    location = azurerm_resource_group.my_resource_group.location
  }
  workload_nickname = var.workload_nickname
  subnet_id = module.networking.subnet_id
  ado_organization_url = var.ado_organization_url
  ado_project_name = var.ado_project_name
}