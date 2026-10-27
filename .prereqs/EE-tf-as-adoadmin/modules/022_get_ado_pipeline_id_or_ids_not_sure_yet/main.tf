data "azuredevops_build_definition" "the_pipelines" {
  for_each   = toset(var.ado_pipeline_names)
  project_id = var.ado_project_id
  name       = each.value
}

locals {
  pipeline_ids_by_name = {
    for pipeline_name, definition in data.azuredevops_build_definition.the_pipelines :
    pipeline_name => definition.id
  }
}
