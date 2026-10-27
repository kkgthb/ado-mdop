output "resource_group_name" {
  value = azurerm_resource_group.my_resource_group.name
}

output "current_azurerm_client_id" {
  value = data.azurerm_client_config.current_azurerm_config.client_id
}
output "current_azurerm_object_id" {
  value = data.azurerm_client_config.current_azurerm_config.object_id
}

output "current_azuredevops_org_url" {
  value = data.azuredevops_client_config.current_azuredevops_config.organization_url
}
