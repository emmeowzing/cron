#! /bin/bash
# A bash script containing a bunch of curl requests to publish additional metrics to my influxdb.

host="http://192.168.4.154:8086/write?db=grafana"
global_timeout=10

for i in 1 2
do
    # VM counts.
    curl -m $global_timeout -i -XPOST "$host" --data-binary "active_vms,vmhost=1 value=$(virsh list | grep running | wc -l)" &
    curl -m $global_timeout  -i -XPOST "$host" --data-binary "active_vms,vmhost=2 value=$(virsh -c qemu+ssh://perchost.bjd2385.com/system list | grep running | wc -l)" &
    curl -m $global_timeout -i -XPOST "$host" --data-binary "active_vms,vmhost=3 value=$(virsh -c qemu+ssh://routerhost.bjd2385.com/system list | grep running | wc -l)" &

    # ZFS dataset count.
    curl -m $global_timeout -i -XPOST "$host" --data-binary "zfs_dataset_count,vmhost=1,pool=homePool value=$(zfs list -Hro name homePool | wc -l)" &
    curl -m $global_timeout -i -XPOST "$host" --data-binary "zfs_dataset_count,vmhost=1,pool=fastAccessPool value=$(zfs list -Hro name fastAccessPool | wc -l)" &
    curl -m $global_timeout -i -XPOST "$host" --data-binary "zfs_dataset_count,vmhost=4,pool=homePool value=$(ssh root@perchost.bjd2385.com zfs list -Hro name VMPool | wc -l)" &
    curl -m $global_timeout -i -XPOST "$host" --data-binary "zfs_dataset_count,vmhost=2,pool=VMPool value=$(ssh root@replication.bjd2385.com zfs list -Hro name homePool | wc -l)" &
    curl -m $global_timeout -i -XPOST "$host" --data-binary "zfs_dataset_count,vmhost=4,pool=homePool/b350-gaming-pc value=$(ssh root@replication.bjd2385.com zfs list -Hro name homePool/b350-gaming-pc | wc -l)" &
    curl -m $global_timeout -i -XPOST "$host" --data-binary "zfs_dataset_count,vmhost=4,pool=homePool/perchost value=$(ssh root@replication.bjd2385.com zfs list -Hro name homePool/perchost | wc -l)" &

    if [ $i = 1 ]
    then
        sleep 30
    fi
done
