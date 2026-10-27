I suspect I abandoned this?  Can't remember for sure.  Maybe it's done, maybe it's not.  Probably not -- there's a whole lot of VNET-connecting & firewalling stuff I haven't set up the way most enterprises would probably be using Azure Firewall, I believe.

Heck, I'm not even sure I finished subnet/VNET/NSG/NSG-rule/routing stuff.

Anyway, this would provion the Azure MDP.

But make sure to first run [the "AA" ADO-config stuff](../AA-tf-as-adoadmin/), to make sure that the service principal that'll be running this "BB" codebase against Azure actually has sufficient ADO privileges to automatically do the ADO-side stuff Azure's going to try to do.

After this "BB" section's all done & run, don't forget there's [some "EE" ADO-config stuff](../EE-tf-as-adoadmin/) to run as a followup.
