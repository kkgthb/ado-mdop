Whoopsie, I think I never quite finished [the `BB` Azure-side provisioning code](.prereqs/BB-tf-as-cicd/).

Anyway, first the [the `AA` ADO-config stuff](.prereqs/AA-tf-as-adoadmin/) has to get done, to give the Entra principal that'll be running `BB` appropriate privileges within ADO.

And after `BB` has finished, there's some ADO-config followup work to do _(for security and convenience)_ by running [the `EE` ADO-config stuff](.prereqs/EE-tf-as-adoadmin/).
