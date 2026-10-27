data "azuredevops_group" "ado_group_cicdgatekeepers" {
  # Prerequisite:  force var.entra_group_display_name to exist in ADO 
  # by creating a throwaway project-level group 
  # in the web UI admin portal, 
  # and looking up the var.entra_group_display_name within the search box, 
  # and adding it as members to the throwaway group.
  # That forces the parent ADO organization to become aware of the Entra group's existence, 
  # and makes this data query actually work.
  # You can call it something like:  "TEMPORARY group DELETE within minutes"
  # And you can give it a description like:
  # "For some weird reason, Terraform can't find a security group from Entra within ADO 
  # unless the Entra security group has already been used 
  # somewhere like in a member list of a group such as this.
  # This group literally only exists to force ADO to notice the Entra group's existence. 
  # Tear it down manually after you get what you need, hopefully within minutes."
  # Postrequisite:  When tearing everything down via Terraform, remember to tear down this 
  # throwaway project-level group as well, manually.
  name = var.entra_group_display_name
}
