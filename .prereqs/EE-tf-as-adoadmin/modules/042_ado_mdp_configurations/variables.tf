variable "ado_project_id" {
  type     = string
  nullable = false
}

variable "ado_azmdp_name" {
  type     = string
  nullable = false
}

variable "gatekeepers_group_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.gatekeepers_group_id))
    error_message = "The gatekeepers_group_id variable must be a valid GUID in standard UUID/GUID format (e.g., 123e4567-e89b-12d3-a456-426614174000)."
  }
}

variable "permitted_pipeline_ids_by_name" {
  type = map(string)
}
