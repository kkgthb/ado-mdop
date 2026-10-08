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
