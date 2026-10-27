Once the Azure-side MDP resources exist _(see [the "BB" Azure provisioning](../BB-tf-as-cicd/) and [its "AA" ADO-config prereq](../AA-tf-as-adoadmin/))_, it's wise to add at least 1 manual-human Check Approval to the MDP's Agent Queue in Azure DevOps, for security.

It's also convenient to pre-clear some ADO pipelines, if you know their names in advance, to run on the MDP's Agent Queue, so that people don't have to do so on first run.
