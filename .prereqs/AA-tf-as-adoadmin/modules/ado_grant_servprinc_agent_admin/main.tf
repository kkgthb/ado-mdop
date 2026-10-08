# ----------- ADO org-level resources ------------

data "azuredevops_client_config" "current_azuredevops_config" {
  lifecycle {
    postcondition {
      condition     = self.organization_url != null && self.organization_url != ""
      error_message = "We are not logged into ADO as expected."
    }
  }
}

# The "azuredevops_service_principal_entitlement" resource type has pretty cool behavior even without existing TFState:
# If var.entra_grantee_principal_object_id is already an ADO user, then it'll just set its license type to Stakeholder, 
# which is fine, because we're purposely using a var.entra_grantee_principal_object_id that should never need more than that.
# If var.entra_grantee_principal_object_id is not yet an ADO user 
# (which would cause an error with the "azuredevops_service_principal" data resource), 
# then it'll add it to the ADO org's users in Stakeholder status.
# Plus, it's got a "descriptor" output property 
# that's pefect for all the rest of the work we need to do.
# WARNING:  That said, one disadvantage of this approach is that when you do a Terraform Destroy, 
# you'll probably end up removing var.entra_grantee_principal_object_id from being an ADO user, 
# which might be surprising to everyone else at your workplace if it already was one.
# So if you're more concerned about that, then stick to letting the "azuredevops_service_principal" data resource 
# just error out, and do the ADO org user creation manually.
resource "azuredevops_service_principal_entitlement" "grantee_sp" {
  origin_id            = var.entra_grantee_principal_object_id
  origin               = "aad"
  account_license_type = "stakeholder"
}

# # ----------- ADO org-level group that should not have to exist but oh well ------------

# Allegedly, org-wide agent pools access was no longer needed as of October 2025
# (https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/features-timeline?view=azure-devops#october-2025), 
# but in practice, Microsoft seems to have misimplemented the enhancement, 
# and deleting Azure Managed DevOps pools, or recreating one of the same name after having deleted an Azure MDP, 
# still errors out without org-wide agent pool administrator permissions.

# Find or create an org-level ADO group named the way I want
locals {
  desired_org_group_name = "Project Collection Agent Pool Administrators"
}
data "external" "ado_org_pooladmins_group" {
  program = ["pwsh", "-NoProfile", "-NonInteractive", "-File", "${path.module}/Get-ExistingAdoGroupByName.ps1"]
  query = {
    desired_group_name = local.desired_org_group_name
    scope              = "organization"
    organization_url   = data.azuredevops_client_config.current_azuredevops_config.organization_url
  }
}
locals {
  org_group_exists = data.external.ado_org_pooladmins_group.result.exists == "true"
}
resource "azuredevops_group" "ado_org_pooladmins_group" {
  count        = local.org_group_exists ? 0 : 1 # Create if wasn't in existing groups
  display_name = local.desired_org_group_name
  description  = "Members of this group can add, modify, and delete agent pool configurations for this organization."
}
locals {
  # And now use whichever one was relevant, going forward
  org_group_descriptor = local.org_group_exists ? data.external.ado_org_pooladmins_group.result.descriptor : azuredevops_group.ado_org_pooladmins_group[0].descriptor
  org_group_id         = local.org_group_exists ? data.external.ado_org_pooladmins_group.result.id : azuredevops_group.ado_org_pooladmins_group[0].group_id
}

# Now make sure the group has only 1 member -- var.entra_grantee_principal_object_id
resource "azuredevops_group_membership" "ado_org_pooladmins_members" {
  # WARNING:  Sadly, if this group already existed with some differet members, 
  # you are now overwriting and losing those details forever, with the way I coded this.
  # In my case, I don't care, because I always want local.desired_org_group_name to look like this 
  # if it exists, and the next-best fallback actually would be no members, 
  # which is what would happen to the membership for local.desired_org_group_name 
  # if it already existed as a "data" and therefore didn't get destroyed 
  # upon Terraform Destroy.
  # Anyway, point is, if the local.desired_org_group_name survives Terraform Destroy, 
  # Terraform Destroy will, thanks to this resource, leave it with an empty membership list, 
  # rather than turning membership back to whatever it "used to be" before we 
  # brought the permissions of local.desired_org_group_name into Terraform management at all.
  mode    = "overwrite"
  group   = local.org_group_descriptor
  members = [azuredevops_service_principal_entitlement.grantee_sp.descriptor]
}

# Now make sure this group has admin rights over Agent Pools for the ADO org
resource "azuredevops_securityrole_assignment" "ado_org_pooladmins_agent_pool_admin" {
  identity_id = local.org_group_id                    # the ADO org-level group
  resource_id = "0"                                   # presumed to be the ADO org's all-agent-pools node
  scope       = "distributedtask.globalagentpoolrole" # the category of role the ADO group should have
  role_name   = "Administrator"                       # the specific role the ADO group should have, part 2 of 2
}

# Also, make sure the group can't do anything else.
data "azuredevops_security_namespace" "ado_org_security_namespace" {
  name = "Collection"
}
locals {
  ado_org_pooladmins_desired_permissions = {
    for action in data.azuredevops_security_namespace.ado_org_security_namespace.actions :
    action.name => action.name == "GENERIC_READ" ? "notset" : "deny"
  }
}
data "azuredevops_security_namespace_token" "ado_org_security_namespace_token" {
  namespace_name = "Collection"
}
resource "azuredevops_security_permissions" "ado_org_pooladmins_permissions" {
  # WARNING:  Sadly, if this group already existed with some fancy permissions, 
  # you are now overwriting and losing those details forever, with the way I coded this.
  # In my case, I don't care, because I always want local.desired_org_group_name to look like this 
  # if it exists, and the next-best fallback actually would be across-the-board "Not Set" permissions, 
  # which is what would happen to the permissions for local.desired_org_group_name 
  # if it already existed as a "data" and therefore didn't get destroyed 
  # upon Terraform Destroy.
  # Anyway, point is, if the local.desired_org_group_name survives Terraform Destroy, 
  # Terraform Destroy will, thanks to this resource, turn all of its permissions 
  # to "Not Set," rather than turning them back to whatever they "used to be" before we 
  # brought the permissions of local.desired_org_group_name into Terraform management at all.
  replace      = true
  principal    = local.org_group_descriptor                                                       # the ADO org-level group
  permissions  = local.ado_org_pooladmins_desired_permissions                                     # the permissions the ADO group should have
  namespace_id = data.azuredevops_security_namespace.ado_org_security_namespace.id                # the parent ADO org
  token        = data.azuredevops_security_namespace_token.ado_org_security_namespace_token.token # not sure why, but this for the parent ADO org too
}

# ----------- ADO project-level resources ------------

data "azuredevops_project" "the_ado_project" {
  name = var.ado_project_name
  lifecycle {
    postcondition {
      condition     = self.name == var.ado_project_name
      error_message = "The project data was not fetched out of ADO"
    }
  }
}

# # ----------- ADO project-level group ------------

# Find or create an project-level ADO group named the way I want
locals {
  desired_proj_group_name = "Project Agent Pool Administrators"
}
data "external" "ado_proj_pooladmins_group" {
  program = ["pwsh", "-NoProfile", "-NonInteractive", "-File", "${path.module}/Get-ExistingAdoGroupByName.ps1"]
  query = {
    desired_group_name = local.desired_proj_group_name
    scope              = "project"
    organization_url   = data.azuredevops_client_config.current_azuredevops_config.organization_url
    project_name       = data.azuredevops_project.the_ado_project.name
  }
}
locals {
  proj_group_exists = data.external.ado_proj_pooladmins_group.result.exists == "true"
}
resource "azuredevops_group" "ado_proj_pooladmins_group" {
  count        = local.proj_group_exists ? 0 : 1 # Create if wasn't in existing groups
  display_name = local.desired_proj_group_name
  description  = "Members of this group can add, modify, and delete agent pool configurations for this project."
}
locals {
  # And now use whichever one was relevant, going forward
  proj_group_descriptor = local.proj_group_exists ? data.external.ado_proj_pooladmins_group.result.descriptor : azuredevops_group.ado_proj_pooladmins_group[0].descriptor
  proj_group_id         = local.proj_group_exists ? data.external.ado_proj_pooladmins_group.result.id : azuredevops_group.ado_proj_pooladmins_group[0].group_id
}

# Now make sure the group has only 1 member -- var.entra_grantee_principal_object_id
resource "azuredevops_group_membership" "ado_proj_pooladmins_members" {
  # WARNING:  Sadly, if this group already existed with some differet members, 
  # you are now overwriting and losing those details forever, with the way I coded this.
  # In my case, I don't care, because I always want local.desired_proj_group_name to look like this 
  # if it exists, and the next-best fallback actually would be no members, 
  # which is what would happen to the membership for local.desired_proj_group_name 
  # if it already existed as a "data" and therefore didn't get destroyed 
  # upon Terraform Destroy.
  # Anyway, point is, if the local.desired_proj_group_name survives Terraform Destroy, 
  # Terraform Destroy will, thanks to this resource, leave it with an empty membership list, 
  # rather than turning membership back to whatever it "used to be" before we 
  # brought the permissions of local.desired_proj_group_name into Terraform management at all.
  mode    = "overwrite"
  group   = local.proj_group_descriptor
  members = [azuredevops_service_principal_entitlement.grantee_sp.descriptor]
}

# Now make sure this group has admin rights over Agent Queues for the ADO project
resource "azuredevops_securityrole_assignment" "ado_proj_pooladmins_agent_queues_admin" {
  identity_id = local.proj_group_id                         # the ADO project-level group
  resource_id = data.azuredevops_project.the_ado_project.id # presumed to be the ADO project's all-agent-queues node.  Possibly should be:  format("%s_", data.azuredevops_project.the_ado_project.id)
  scope       = "distributedtask.globalagentqueuerole"      # the category of role the ADO group should have
  role_name   = "Administrator"                             # the specific role the ADO group should have, part 2 of 2
}

# Also, make sure the group can't do anything else.
data "azuredevops_security_namespace" "ado_project_security_namespace" {
  name = "Project"
}
locals {
  ado_proj_pooladmins_desired_permissions = {
    for action in data.azuredevops_security_namespace.ado_project_security_namespace.actions :
    action.name => action.name == "GENERIC_READ" ? "notset" : "deny"
  }
}
data "azuredevops_security_namespace_token" "ado_project_security_namespace_token" {
  namespace_name = "Project"
  identifiers = {
    project_id = data.azuredevops_project.the_ado_project.id
  }
}
resource "azuredevops_security_permissions" "ado_proj_pooladmins_permissions" {
  # WARNING:  Sadly, if this group already existed with some fancy permissions, 
  # you are now overwriting and losing those details forever, with the way I coded this.
  # In my case, I don't care, because I always want local.desired_proj_group_name to look like this 
  # if it exists, and the next-best fallback actually would be across-the-board "Not Set" permissions, 
  # which is what would happen to the permissions for local.desired_proj_group_name 
  # if it already existed as a "data" and therefore didn't get destroyed 
  # upon Terraform Destroy.
  # Anyway, point is, if the local.desired_proj_group_name survives Terraform Destroy, 
  # Terraform Destroy will, thanks to this resource, turn all of its permissions 
  # to "Not Set," rather than turning them back to whatever they "used to be" before we 
  # brought the permissions of local.desired_proj_group_name into Terraform management at all.
  replace      = true
  principal    = local.proj_group_descriptor                                                          # the ADO project-level group
  permissions  = local.ado_proj_pooladmins_desired_permissions                                        # the permissions the ADO group should have
  namespace_id = data.azuredevops_security_namespace.ado_project_security_namespace.id                # the parent ADO project
  token        = data.azuredevops_security_namespace_token.ado_project_security_namespace_token.token # not sure why, but this for the parent ADO project too
}
