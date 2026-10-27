data "azurerm_client_config" "current_azurerm_config" {
  provider = azurerm.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into ADO as expected."
    }
  }
}

data "azuredevops_client_config" "current_azuredevops_config" {
  # This "primes the pump" by making an ADO REST API query, in case the Entra principal currently running Terraform 
  # is a member of an Entra Security Group that is authorized to do things in ADO, but does not yet happen 
  # to be listed as an ADO user.  ADO will react to this query by automatically adding the current Entra principal 
  # into the ADO organization as a "user" with a "Stakeholder"-level license, which is all that is needed for 
  # managing agent pools/queues.
  provider = azuredevops.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into ADO as expected."
    }
  }
}

# Commented things out because I changed a lot, and I haven't yet had a chance to re-test anything.

# resource "azurerm_resource_group" "my_resource_group" {
#   provider = azurerm.demo
#   name     = "${var.workload_nickname}-rg-demo"
#   location = "centralus"
# }

# module "networking_azure_220" {
#   source = "./modules/220_networking_azure"
#   providers = {
#     azurerm = azurerm.demo
#   }
#   resource_group = {
#     id       = azurerm_resource_group.my_resource_group.id
#     name     = azurerm_resource_group.my_resource_group.name
#     location = azurerm_resource_group.my_resource_group.location
#   }
#   workload_nickname                 = var.workload_nickname
#   ms_devopsinfrastructure_object_id = var.ms_devopsinfrastructure_object_id
# }

# module "compute_azure_240" {
#   # Making this module's invocation depend upon a query against ADO forces the current user into ADO if for some reason it isn't yet, 
#   # which helps ensure that Azure Managed DevOps Pool configuration proceeds as expected.
#   depends_on = [module.networking_azure_220, data.azuredevops_client_config.current_azuredevops_config]
#   source     = "./modules/240_compute_azure"
#   providers = {
#     azurerm = azurerm.demo
#   }
#   resource_group = {
#     id       = azurerm_resource_group.my_resource_group.id
#     name     = azurerm_resource_group.my_resource_group.name
#     location = azurerm_resource_group.my_resource_group.location
#   }
#   workload_nickname    = var.workload_nickname
#   subnet_id            = module.networking_azure_220.subnet_id
#   ado_organization_url = var.ado_organization_url
#   ado_project_name     = var.ado_project_name
# }
