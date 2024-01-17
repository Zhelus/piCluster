#!/bin/bash

hosts=$(awk '/#beginHOSTSconfig/{flag=1; next} /#endHOSTSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)


read -p "Input the account you would like to lock accross the cluster: " USER


#lock the service account and prevent direct login
sudo usermod -L $USER


#This code is commented out until the final implementation
for i in $hosts
do

#lock the service account and prevent direct login
    ssh $i sudo usermod -L $USER

done &
