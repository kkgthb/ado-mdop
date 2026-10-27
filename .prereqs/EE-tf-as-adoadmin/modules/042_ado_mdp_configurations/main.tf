data "azuredevops_agent_queue" "ado_project_mdp" {
  project_id = var.ado_project_id
  name       = var.ado_azmdp_name
}

resource "azuredevops_check_approval" "ado_chkaprv_mdp" {
  # To prevent accidents and slow down hackers, 
  # lock down the agent queue's use by requiring at least 1 manual human approval 
  # (a 2nd person -- not the person who caused the CI/CD pipeline to run)
  # each time Azure Pipelines tries to use it as a CI/CD pipeline runtime.
  project_id                 = var.ado_project_id
  target_resource_type       = "queue"
  target_resource_id         = data.azuredevops_agent_queue.ado_project_mdp.id
  minimum_required_approvers = 1
  requester_can_approve      = false
  timeout                    = 60
  approvers                  = [var.gatekeepers_group_id]
}

resource "azuredevops_pipeline_authorization" "ado_pipeauth_mdp" {
  # For the specified pipelines, this ensures no one has to approve 
  # using this pool on the specified YAML pipeline's first run.
  # (Note:  the runner of this Terraform code must have at least "Administrator" against that specific 
  # agent queue resource,  just like manual button-clickers would need.)
  # TODO:  check if that's actually the permission needed
  for_each    = var.permitted_pipeline_ids_by_name
  project_id  = var.ado_project_id
  type        = "queue"
  resource_id = data.azuredevops_agent_queue.ado_project_mdp.id
  pipeline_id = each.value
}
