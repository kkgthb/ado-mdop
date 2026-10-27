output "ado_mdp_id" {
  value = data.azuredevops_agent_queue.ado_project_mdp.id
  precondition {
    condition     = can(regex("^[0-9]+$", tostring(data.azuredevops_agent_queue.ado_project_mdp.id)))
    error_message = "The ado_mdp_id output must be an integer represented by decimal digits."
  }
}

output "ado_check_approval_id" {
  value = azuredevops_check_approval.ado_chkaprv_mdp.id
}

output "ado_pipeline_authorization_ids_by_pipeline_name" {
  value = {
    for name, authorization in azuredevops_pipeline_authorization.ado_pipeauth_mdp :
    name => authorization.id
  }
}
