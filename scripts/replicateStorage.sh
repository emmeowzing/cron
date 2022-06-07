#! /bin/bash
# Replicate to my replication server / node via syncoid.

logdir="/fastAccessPool/logging/replication"

# VM datasets to replicate.
declare -a datasets

VMdatasets=(
    "homePool/home/VMs/DC1"
    "homePool/home/VMs/SQL2016"
    "homePool/home/VMs/ubuntusql"
    "homePool/home/VMs/guacamole-restore"
    "homePool/home/VMs/nginx"
    "homePool/home/VMs/home-assistant"
    "homePool/home/VMs/extra_disks"
)

baseVMDestPath="homePool/b350-gaming-pc/home/VMs"

# Regular datasets.
datasets=(
    "homePool/home/configBackup"
    "homePool/home/projects"
    "homePool/home/keys"
    "homePool/home/resume"
    "homePool/home/Pictures"
    "homePool/home/clones"
    "homePool/home/ansiblePlaybooks"
)

baseDestPath="homePool/b350-gaming-pc/home"


##
# Perform the replication.
replicate()
{
    # Sync VM datasets first.
    for ds in ${VMdatasets[@]}
    do
        dst="root@replication.bjd2385.com:$baseVMDestPath/$(basename "$ds")"
        printf "Syncing %s to %s\\n" "$ds" "$dst"  >> "$logdir/$(date +%s)"
        syncoid --no-sync-snap --sshkey=/home/brandon/.ssh/versatileKey "$ds" "$dst"
    done

    # Now sync the rest.
    for ds in ${datasets[@]}
    do
        dst="root@replication.bjd2385.com:$baseDestPath/$(basename "$ds")"
        printf "Syncing %s to %s\\n" "$ds" "$dst" >> "$logdir/$(date +%s)"
        syncoid --no-sync-snap --sshkey=/home/brandon/.ssh/versatileKey "$ds" "$dst"
    done

    return 0
}


replicate


unset -f replication
unset baseVMDestPath datasets baseDestPath logdir baseVMDestPath
