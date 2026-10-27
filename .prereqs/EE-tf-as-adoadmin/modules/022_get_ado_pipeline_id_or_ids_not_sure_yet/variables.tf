variable "ado_project_id" {
  type     = string
  nullable = false
}

variable "ado_pipeline_names" {
  type = list(string)
  validation {
    condition = alltrue([
      for nm in var.ado_pipeline_names : nm != ""
    ])
    error_message = "No pipeline name may be blank."
  }
}
