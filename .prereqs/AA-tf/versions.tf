terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.71.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "=1.15.1"
    }
  }
}
