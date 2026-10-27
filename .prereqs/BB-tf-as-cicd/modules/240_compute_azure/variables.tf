variable "resource_group" {
  description = "Parent resource group parameters"
  type = object({
    id       = string
    name     = string
    location = string
  })
}

variable "workload_nickname" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ado_organization_url" {
  type = string
}

variable "ado_project_name" {
  type = string
}