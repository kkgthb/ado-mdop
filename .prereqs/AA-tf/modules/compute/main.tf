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


# # As expected before giving service principal ADO rights, Terraform apply errored out as follows:
# │ Error: creating Pool (Subscription: "CENSORED"
# │ Resource Group Name: "CENSORED-rg-demo"
# │ Pool Name: "mdp-CENSORED"): polling after CreateOrUpdate: polling failed: the Azure API returned the following error:
# │
# │ Status: "Failed"
# │ Code: "Failed"
# │ Message: "The request has been completed with result Failed. Please check details with more information."
# │ Activity Id: ""
# │
# │ ---
# │
# │ API Response:
# │
# │ ----[start]----
# │ 
# │ {
# │     "id": "/subscriptions/CENSORED/providers/Microsoft.DevOpsInfrastructure/locations/CENTRALUS/operationStatuses/CENSORED*CENSORED",
# │     "name": "CENSORED*CENSORED",
# │     "resourceId": "/subscriptions/CENSORED/resourceGroups/CENSORED-rg-demo/providers/Microsoft.DevOpsInfrastructure/pools/mdp-CENSORED",
# │     "status": "Failed",
# │     "startTime": "CENSORED",
# │     "endTime": "CENSORED",
# │     "error": {
# │         "message": "The request has been completed with result Failed. Please check details with more information.",
# │         "details": [
# │             {
# │                 "code": "PoolProvisioningFailed",
# │                 "message": "Failed to provision agent pool. Exception: Could not find or create agent pool mdp-CENSORED. The logged in user may not have sufficient permissions in the Azure DevOps organization or project(s).",
# │                 "details": [],
# │                 "additionalInfo": []
# │             }
# │         ],
# │         "additionalInfo": []
# │     }
# │ }
# │ -----[end]-----
# │
# │
# │   with module.compute.azurerm_managed_devops_pool.managed_devops_pool,
# │   on modules\compute\main.tf line 17, in resource "azurerm_managed_devops_pool" "managed_devops_pool":
# │   17: resource "azurerm_managed_devops_pool" "managed_devops_pool" {
# │
# │ creating Pool (Subscription: "CENSORED"
# │ Resource Group Name: "CENSORED-rg-demo"
# │ Pool Name: "mdp-CENSORED"): polling after CreateOrUpdate: polling failed: the Azure API returned the following error:
# │
# │ Status: "Failed"
# │ Code: "Failed"
# │ Message: "The request has been completed with result Failed. Please check details with more information."
# │ Activity Id: ""
# │
# │ ---
# │
# │ API Response:
# │
# │ ----[start]----
# │ {
# │     "id": "/subscriptions/CENSORED/providers/Microsoft.DevOpsInfrastructure/locations/CENTRALUS/operationStatuses/CENSORED*CENSORED",
# │     "name": "CENSORED*CENSORED",
# │     "resourceId": "/subscriptions/CENSORED/resourceGroups/CENSORED-rg-demo/providers/Microsoft.DevOpsInfrastructure/pools/mdp-CENSORED",
# │     "status": "Failed",
# │     "startTime": "CENSORED",
# │     "endTime": "CENSORED",
# │     "error": {
# │         "message": "The request has been completed with result Failed. Please check details with more information.",
# │         "details": [
# │             {
# │                 "code": "PoolProvisioningFailed",
# │                 "message": "Failed to provision agent pool. Exception: Could not find or create agent pool mdp-CENSORED. The logged in user may not have sufficient permissions in the Azure DevOps organization or project(s).",
# │                 "details": [],
# │                 "additionalInfo": []
# │             }
# │         ],
# │         "additionalInfo": []
# │     }
# │ }
# │ -----[end]-----
# │
# # As expected before giving service principal ADO rights, Terraform apply errored out as precedes.
# # I do not see "mdp-" in tfstate file, so yay, it seems to not go in corrupted, that's good.

resource "azurerm_managed_devops_pool" "managed_devops_pool" {
  dev_center_project_id = azurerm_dev_center_project.mydcp.id
  name                  = "mdp-${var.workload_nickname}"
  resource_group_name   = var.resource_group.name
  location              = var.resource_group.location
  maximum_concurrency   = 1
  azure_devops_organization {
    organization {
      parallelism = 1
      url         = trimsuffix(var.ado_organization_url, "/")
      projects    = sort(tolist(toset([var.ado_project_name])))
    }
    permission {
      kind = "Inherit"
    }
  }
  stateless_agent {}
  virtual_machine_scale_set_fabric {
    os_disk_storage_account_type = "Standard"
    sku_name                     = "Standard_D2ads_v5"
    subnet_id                    = var.subnet_id
    image {
      aliases               = ["ubuntu-22.04/latest"]
      well_known_image_name = "ubuntu-22.04/latest"
    }
  }
}
