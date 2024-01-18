#!/bin/bash

hosts=$(sudo awk '/#beginHOSTSconfig/{flag=1; next} /#endHOSTSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)
nfs=$(sudo awk '/#beginNFSconfig/{flag=1; next} /#endNFSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)

for i in $hosts
do
    echo "Updating node $i mkdir .ssh"
    ssh $i sudo -S apt install nfs-common -y
    ssh $i sudo -S apt install autofs -y
    ssh $i "sudo bash -c 'echo \"/home /etc/home.map\" >> /etc/auto.master'"
    ssh $i "sudo bash -c 'echo \"* -fstype=nfs,rw,nosuid,hard $nfs:/home/&\" >> /etc/home.map'"
    ssh $i sudo -S reboot
done

