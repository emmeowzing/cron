#! /bin/bash
# Copy config files on this machine to a subdirectory of
# /homePool/home/configBackup and snapshot it.

dataset="homePool/home/configBackup"
destination="$(zfs get mountpoint -Ho value "$dataset")"
deletionlog="deletionhistory.log"

b350_gaming_pc=(
    "/home/brandon/.vimrc"
    "/home/brandon/.bashrc"
    "/home/brandon/.bash_aliases"
    "/home/brandon/.tmux.conf"
    "/home/brandon/.ssh/config"
    "/home/brandon/scripts/"
    "/home/brandon/cronscripts/"
    "/home/brandon/.password-store/"
    "/etc/ansible/ansible.cfg"
    "/etc/ansible/hosts"
    "/etc/network/interfaces"
    "/etc/samba/smb.conf"
    "/etc/aliases"
    "/etc/exports"
    "/etc/fstab"
    "/etc/hosts"
    "/etc/logrotate.conf"
    "/etc/modules"
    "/etc/sudoers"
    "/etc/ssh/sshd_config"
    "/etc/ssh/ssh_config"
    "/etc/logrotate.conf"
    "/etc/logrotate.d/auditd"
    "/etc/logrotate.d/apache2"
    "/etc/logrotate.d/alternatives"
    "/etc/logrotate.d/libvirtd"
    "/etc/logrotate.d/speech-dispatcher"
    "/etc/logrotate.d/telegraf"
    "/etc/modprobe.d/qemu-system-x86.conf"
    "/etc/modprobe.d/cuda.conf"
    "/etc/sanoid/sanoid.conf"
    "/home/brandon/.telegraf/telegraf.conf"
    "/etc/libvirt/qemu/"
)


##
# Clear a mountpoint of any content whatsoever, except the deletion log.
clearMntPt()
{
    # Clear the mountpoint.
    if isNotEmpty "$destination"
    then
        # Dump a list of all files to the deletion log.
        printf "%s\\n\\n" "$(date)" >> "$destination/$deletionlog"
        find "$destination" -mindepth 1 >> "$destination/$deletionlog"
        printf "\\n" >> "$destination/$deletionlog"
        # Now delete those files.
        find "$destination" -mindepth 1 ! -name "$deletionlog" -delete
    fi
}


##
# Loop over defined files and copy them to my storage array.
main()
{
    clearMntPt

    for file in ${b350_gaming_pc[@]}
    do
        # Make the path to the files so that a chroot would look like `/`.
        if ! [ -d "${destination}$(dirname "$file")" ]
        then
            mkdir -p "${destination}$(dirname "$file")"
        fi
        cp -r "$file" "${destination}${file}"
    done

    crontab -l > "$destination/crontab"

    zfs snapshot "${dataset}@$(date +%s)"

    clearMntPt
}


main

unset -f clearMntPt main
unset destination b350_gaming_pc file dataset deletionlog
