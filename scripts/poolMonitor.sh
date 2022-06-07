#! /bin/bash
# Monitor my ZFS pools' status (simple) and report if any disks or pools are
# not in an ONLINE state.

declare -A pools

pools=(
    [homePool]=0
    [fastAccessPool]=0
)

for pool in ${!pools[@]}
do
    pools["$pool"]=$(zpool status "$pool" -vP \
        | grep -oP "(UNAVAIL|OFFLINE|DEGRADED)" | wc -l)
done

args=()

# TODO: There's no reason at all to loop over this a second time, unless you have a hella lotta pools (which is unlikely), so this could be re-written.
for pool in ${!pools[@]}
do
    if [ ${pools[$pool]} -ne 0 ]
    then
        args+=("$pool")
    fi
done

if [ ${#args[@]} -eq 1 ]
then
    spd-say -t female3 "The pool ${args[*]} are not in good health." -r -50 -w
elif [ ${#args[@]} -gt 1 ]
then
    string="$(printf "%s, " "${args[@]}")"
    spd-say -t female3 "The pools $string are not in good health." -r -50 -w
fi

#php /home/brandon/cronscripts/mail.php "${args[@]}"
#
#php /home/brandon/cronscripts/mail.php "homePool"
