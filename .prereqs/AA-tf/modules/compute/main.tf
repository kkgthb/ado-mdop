resource "azurerm_dev_center" "mydc" {
  name                = "dc-${var.workload_nickname}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_dev_center_project" "mydcp" {
  dev_center_id       = azurerm_dev_center.mydc.id
  name                = "dcp-${var.workload_nickname}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
}

# Commenting out because this is where I expect a service principal to fail
# resource "azurerm_managed_devops_pool" "managed_devops_pool" {
#   dev_center_project_id = azurerm_dev_center_project.mydcp.id
#   name                  = "mdp-${var.workload_nickname}"
#   resource_group_name   = var.resource_group.name
#   location              = var.resource_group.location
#   maximum_concurrency   = 1
#   azure_devops_organization {
#     organization {
#       parallelism = 1
#       url         = trimsuffix(var.ado_organization_url, "/")
#       projects    = sort(tolist(toset([var.ado_project_name])))
#     }
#     permission {
#       kind = "Inherit"
#     }
#   }
#   stateless_agent {}
#   virtual_machine_scale_set_fabric {
#     os_disk_storage_account_type = "Standard"
#     sku_name                     = "Standard_D2ads_v5"
#     subnet_id                    = var.subnet_id
#     image {
#       aliases               = ["ubuntu-22.04/latest"]
#       well_known_image_name = "ubuntu-22.04/latest"
#     }
#   }
# }
