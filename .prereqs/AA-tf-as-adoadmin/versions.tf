terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "=1.16.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "=2.4.2"
    }
  }
}
