output "ado_pipeline_ids_by_name" {
  value = local.pipeline_ids_by_name
  precondition {
    condition     = length(local.pipeline_ids_by_name) == length(toset(var.ado_pipeline_names))
    error_message = "The resolved pipeline ID map must contain one entry per unique input pipeline name."
  }
}
