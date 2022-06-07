#! /bin/bash
# Start the following VMs one-by-one with virsh on system reboot.

toStart=(
    docker
)

for vm in ${toStart[@]}
do
    sleep 120
    virsh start "$vm"
done
