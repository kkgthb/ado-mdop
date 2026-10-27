variable "workload_nickname" {
  type     = string
  nullable = false
}
variable "entra_tenant_id" {
  type     = string
  nullable = false
}
variable "ado_organization_url" {
  type     = string
  nullable = false
}
variable "ado_project_name" {
  type     = string
  nullable = false
}
variable "entra_gatekeepers_group_display_name" {
  type     = string
  nullable = false
}
variable "ado_preapproved_pipeline_names" {
  type = list(string)
  validation {
    condition = alltrue([
      for nm in var.ado_preapproved_pipeline_names : nm != ""
    ])
    error_message = "No preapproved pipeline name may be blank."
  }
}
