#!/bin/bash

file="./hosts"
hosts=$(cat "$file")
nfs=$(cat nfsFQDN)

for i in $hosts
do
    echo "Updating node $i mkdir .ssh"
    ssh $i sudo -S apt install nfs-common -y
    ssh $i sudo -S apt install autofs -y
    ssh $i "sudo bash -c 'echo \"/home /etc/home.map\" >> /etc/auto.master'"
    ssh $i "sudo bash -c 'echo \"* -fstype=nfs,rw,nosuid,hard $nfs:/home/&\" >> /etc/home.map'"
    ssh $i sudo -S reboot
done

