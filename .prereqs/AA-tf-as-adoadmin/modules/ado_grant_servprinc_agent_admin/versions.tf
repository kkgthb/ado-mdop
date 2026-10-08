terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
    external = {
      source = "hashicorp/external"
    }
  }
}
