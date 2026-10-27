output "ado_pipeline_ids_by_name" {
  value = local.pipeline_ids_by_name
  precondition {
    condition     = length(local.pipeline_ids_by_name) == length(toset(var.ado_pipeline_names))
    error_message = "The resolved pipeline ID map must contain one entry per unique input pipeline name."
  }
  precondition {
    condition = alltrue([
      for pipeline_id in values(local.pipeline_ids_by_name) :
      can(regex("^[0-9]+$", tostring(pipeline_id)))
    ])
    error_message = "Every resolved pipeline ID must be an integer represented by decimal digits."
  }
}
