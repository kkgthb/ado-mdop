variable "entra_tenant_id" {
  type = string
}
variable "az_sub_id" {
  type = string
}
variable "workload_nickname" {
  type = string
}
variable "ms_devopsinfrastructure_object_id" {
  # This is a special built in service principal named "DevOpsInfrastructure".  See:
  # https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking#check-the-principal-access-for-devopsinfrastructure
  # Its Microsoft-assigned universal client ID is "31687f79-5e43-4c1e-8c63-d9f4bff5cf8b"
  type = string
}
variable "ado_organization_url" {
  type = string
}
variable "ado_project_name" {
  type = string
}
