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

# # Darnit.  ADO settings did not auto-delete when I deleted.  Otherwise seems promising though.
# # Oh, and re-creating without first manually deleting the project-level and org-level fails like the below.
# # I've got a suspicion that despite Microsoft's October 2025 announcement 
# # (https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/features-timeline?view=azure-devops#october-2025)
# # that the service principal no longer needs org-wide permissions, that they botched the implementation, 
# # and that that actually is what's blocking proper destroy, or recreate-if-I-do-not-manually-destroy-ado-side-first.
# # I think ADO mirrors the project-level one upon creation, then can't update it properly at the project level 
# # once it's been mirrored to the org level unless the service principal has org access.  🤦‍♀️
# # Update:  confirmed.  Gave my service principal org-wide agent pools access, and now it smoothly auto-deletes 
# # the ADO side when I delete the Azure MDP, and also, before that, when I deleted the Azure side before I elevated 
# # my service principal's privilege (thereby orphaning the ADO side) and recreated the Azure side after elevation, 
# # that elevated service principal was able to "take over" the orphan and manage it just fine.
# # So much for the October 2025 "improvement."  Sigh.
# # But, good news is, the service principal doesn't require a paid ADO license.
# ╷
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
# │                 "message": "Failed to provision agent pool. Exception: Access denied. CENSORED_ENTRA_SP_NAME needs Manage permissions for pool mdp-CENSORED to perform the action. For more information, contact the Azure DevOps Server administrator.",
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
# │   on modules\compute\main.tf line 101, in resource "azurerm_managed_devops_pool" "managed_devops_pool":
# │  101: resource "azurerm_managed_devops_pool" "managed_devops_pool" {
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
# │                 "message": "Failed to provision agent pool. Exception: Access denied. CENSORED_ENTRA_SP_NAME needs Manage permissions for pool mdp-CENSORED to perform the action. For more information, contact the Azure DevOps Server administrator.",
# │                 "details": [],
# │                 "additionalInfo": []
# │             }
# │         ],
# │         "additionalInfo": []
# │     }
# │ }
# │ -----[end]-----
# │


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

# # Further notes
# # 
# # Remove existing user
# # Are you sure you want to remove CENSORED_ENTRA_SP_NAME (CENSORED_CLIENT_ID) from the organization CENSORED?
# # CENSORED_ENTRA_SP_NAME (CENSORED_CLIENT_ID) will continue to have access even after removal 
# # if the user is a member of an Microsoft Entra group that has been added to this organization.
# # 
# # Cool, let's put that to the test ... hopefully my TF still works great since 
# # I put CENSORED_ENTRA_SP_NAME into an Entra group that's part of my new 
# # ADO "Project Collection Agent Pool Administrators" org-level group 
# # and my new ADO "Project Agent Pool Administrators" project-level group.
# #
# # Result:  nope.  Despite queues count through REST API still working fine, see latest error message:
# ╷
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
# │                 "message": "Failed to provision agent pool. Exception: The logged in user, CENSORED_ENTRA_OBJECT_ID, was not found in the Azure DevOps organization provided, https://dev.azure.com/CENSORED.",
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
# │   on modules\compute\main.tf line 194, in resource "azurerm_managed_devops_pool" "managed_devops_pool":
# │  194: resource "azurerm_managed_devops_pool" "managed_devops_pool" {
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
# │                 "message": "Failed to provision agent pool. Exception: The logged in user, CENSORED_ENTRA_OBJECT_ID, was not found in the Azure DevOps organization provided, https://dev.azure.com/CENSORED.",
# │                 "details": [],
# │                 "additionalInfo": []
# │             }
# │         ],
# │         "additionalInfo": []
# │     }
# │ }
# │ -----[end]-----