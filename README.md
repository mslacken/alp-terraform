# Terraform ALP config
The `qcow2` image of ALP always needs to be configured in order to boot.
This can be done via 

* coreboot/ignition
* combustion

Ignition can store its configuration in KVM registers, but I did not get 
it working with terraform.
Combustion is just a single script file, *but* this file must be on another
volume labeled with ignition combustion.
The script `create-img.sh` will create such an image and add the password `linux` 
for the root user.

After creating such an image, download an ALP image, set the right path in `alp.tf` 
and start a machine with
```
sudo terraform apply
```

Have Fun.
