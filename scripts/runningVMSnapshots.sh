#! /bin/bash
# Take a snapshot of running VMs with virsh on a recurring schedule, and store
# them in their disks' mountpoint (based on the first disk's mountpoint).
#
# Notes:
#   - Make sure there are no *.ISOs still attached to the VMs while these snaps
#     are taken.
#   - For quiesced snapshots, you will need to expose the domain to the guest
#     agent via a serial port with the following --
#
#         <channel type='unix'>
#           <source mode='bind' path='/var/lib/libvirt/qemu/f16x86_64.agent'/
#           <target type='virtio' name='org.qemu.guest_agent.0'/>
#         </channel>
#
#     The host must also have the guest agent installed (qemu-guest-agent).


TIME="$(date +%s)"
MEM_SNAP=false

while getopts "hm" opt
do
    case "${opt}" in
        h ) printf "Usage:\\n\\t-h\\t display help\\n\\t-m\\tcapture memory\\n" \
            1>&2
        ;;
        # Create a checkpoint. Otherwise, create a consistent snapshot.
        m ) MEM_SNAP=true
            printf "WARNING: this option may pause your VMs momentarily.\\n"
        ;;
        \?) printf "Please provide a valid argument, received %s\\n" \
            "$OPTARG" 1>&2
        ;;
    esac
done


##
# Return a valid memory file name.
MEM_FILE()
{
    echo "mem_$TIME.mem"
}


##
# Return a valid disk file name.
DISK_FILE()
{
    local disk

    disk="$1"

    echo "${disk}_$TIME.disk"
}


##
# Create a snapshot of this VM and store it in the mountpoint of the disks.
snap()
{
    local VM disk1 path dev devs

    VM="$1"

    # Get the mountpoint to write data to and create it if it does not exist.
    disk1="$(virsh domblklist "$VM" | tail -n +3 | head -n 1 \
        | awk '{ print $2 }')"
    disk1="$(dirname "$disk1")"

    echo "$disk1"

    # Make snapshots subdirectory in VM's subdir. on the array if it DNE.
    if [ "${disk1##*/}" != "snapshots" ]
    then
        path="$disk1/snapshots"

        if ! [ -d "$path" ]
        then
            zfs create "${path#/*}"
        fi
    else
        path="$disk1"

        # Ensure that mountpoint is clean.
        if [ -n "$(ls -A "$path")" ]
        then
            rm "$path/"*
        fi
    fi

    # Append all the disks to a string iteratively.
    devs=""
    for dev in $(virsh domblklist "$VM" | tail -n +3 | head -n -1 \
        | awk '{ print $1 }')
    do
        devs="$devs --diskspec $dev,snapshot=external,file=$path/$(DISK_FILE "$dev")"
    done

    echo "$devs"

    # Take the virsh-based snapshot.
    if $MEM_SNAP
    then
        # Capture memory state as well.
        eval "virsh snapshot-create-as --domain $VM --atomic --memspec file=$path/$(MEM_FILE),snapshot=external$devs"
    else
        # Disks only, quiesce, use VSS for Windows machines.
        eval "virsh snapshot-create-as --domain $VM --atomic --disk-only --quiesce $devs"
    fi

    # Snapshot the mountpoint.
    # zfs snapshot "${path#/*}@$(date +%s)"

    # Clean up for the next snapshot.
    # rm "$path/"*
}


main()
{
    snap SQL2016

    # TODO: try this script on a test virtual machine / windows machine and see
    #       if we can't get it to work as intended.
    #local VM
    #
    #for VM in $(virsh list --all | tail -n +3 | head -n -1 \
    #    | awk '{ if ($3 == "running") { printf "%s\n",$2 } }')
    #do
    #    snap "$VM"
    #done
}


main

unset -f main snap MEM_FILE DISK_FILE
unset TIME MEM_SNAP PATH
