#! /bin/bash
# Download and save configuration files from pfSense and snapshot with ZFS.

IPs=( "192.168.1.1" )
login="bjd2385"
password="Einsteinium99!@$"
PATH_="/homePool/home/VMs/pfSenseBackups"
dataset="homePool/home/VMs/pfSenseBackups"


main()
{
    if [ -n "$(ls -A "$PATH_")" ]
    then
        rm "$PATH_/"*
    fi

    for IP in "${IPs[@]}"
    do
        # Get token.
        wget -T 1 -t 1 -qO- --keep-session-cookies --save-cookies \
            "$PATH_/cookies.txt" --no-check-certificate "https://$IP/diag_backup.php" \
            | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > "$PATH_/csrf.txt"

        # Log in.
        wget -T 1 -t 1 -qO- --keep-session-cookies --load-cookies "$PATH_/cookies.txt" \
            --save-cookies "$PATH_/cookies.txt" --no-check-certificate \
            --post-data "login=Login&usernamefld=$login&passwordfld=$password&__csrf_magic=$(cat "$PATH_/csrf.txt")" \
            "https://$IP/diag_backup.php"  | grep "name='__csrf_magic'" \
            | sed 's/.*value="\(.*\)".*/\1/' > "$PATH_/csrf2.txt"

        # Download XML config file.
        wget -T 5 -t 1 --keep-session-cookies --load-cookies "$PATH_/cookies.txt" \
            --no-check-certificate \
            --post-data "download=download&__csrf_magic=$(head -n 1 "$PATH_/csrf2.txt")" \
            "https://$IP/diag_backup.php" -O "$PATH_/config-$IP-$(date +%s).xml"
    done

    # Clean up.
    if [ -n "$(ls -A "$PATH_/"*.txt)" ]
    then
        rm "$PATH_/"*.txt
    fi

    # Snapshot the mount point with only the *.xml files.
    zfs snapshot "$dataset@$(date +%s)"

    # Now clean up the rest.
    if [ -n "$(ls -A "$PATH_")" ]
    then
        rm "$PATH_/"*
    fi
}


main

unset login password PATH_ IPs dataset PATH
unset -f main
