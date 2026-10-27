# ----------- Entra tenant auth spot-check ------------
data "azuread_client_config" "current_entra_context" {
  provider = azuread.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into Entra as expected."
    }
  }
}

# ----------- ADO org auth spot-check ------------
data "azuredevops_client_config" "current_ado_context" {
  provider = azuredevops.demo
  lifecycle {
    postcondition {
      condition     = self.tenant_id == var.entra_tenant_id
      error_message = "We are not logged into ADO as expected."
    }
  }
}

# ----------- ADO project data spot-check ------------
data "azuredevops_project" "the_ado_project" {
  provider = azuredevops.demo
  name     = var.ado_project_name
  lifecycle {
    postcondition {
      condition     = self.name == var.ado_project_name
      error_message = "The project data was not fetched out of ADO"
    }
  }
}

# ----------- ADO identity translations ------------
module "ado_012_current_user_id" {
  depends_on = [data.azuread_client_config.current_entra_context]
  source     = "./modules/012_get_ado_user_id_by_entra_id"
  providers = {
    azuredevops = azuredevops.demo
  }
  entra_user_object_id = data.azuread_client_config.current_entra_context.object_id
}
module "ado_014_gatekeepers_group_id" {
  depends_on = [data.azuread_client_config.current_entra_context]
  source     = "./modules/014_get_ado_group_id_by_display_name"
  providers = {
    azuredevops = azuredevops.demo
  }
  entra_group_display_name = var.entra_gatekeepers_group_display_name
}

# ----------- ADO existing pipelines data ------------
module "ado_022_preapproved_pipeline_ids" {
  depends_on = [data.azuread_client_config.current_entra_context]
  source     = "./modules/022_get_ado_pipeline_id_or_ids_not_sure_yet"
  providers = {
    azuredevops = azuredevops.demo
  }
  ado_project_id     = data.azuredevops_project.the_ado_project.id
  ado_pipeline_names = var.ado_preapproved_pipeline_names
}

# ----------- ADO configure the MDP ------------
module "ado_042_ado_mdp_config" {
  depends_on = [module.ado_014_gatekeepers_group_id, module.ado_022_preapproved_pipeline_ids]
  source     = "./modules/042_ado_mdp_configurations"
  providers = {
    azuredevops = azuredevops.demo
  }
  ado_project_id                 = data.azuredevops_project.the_ado_project.id
  ado_azmdp_name                 = var.ado_azmdp_name
  gatekeepers_group_id           = module.ado_014_gatekeepers_group_id.ado_id_for_entra_group
  permitted_pipeline_ids_by_name = module.ado_022_preapproved_pipeline_ids.ado_pipeline_ids_by_name
}
