#!/bin/bash

file="./hosts"
hosts=$(cat "$file")


for i in $hosts
do

    echo "Updating node $i"
    ssh $i sudo apt install make -y
    ssh $i sudo apt install gcc -y
    ssh $i sudo tee -a /boot/firmware/config.txt <<< 'dtparam=i2c_arm=on,i2c_arm_baudrate=400000' > /dev/null
    ssh $i sudo tee -a /boot/firmware/config.txt <<< 'dtoverlay=gpio-shutdown,gpio_pin=4,active_low=1,gpio_pull=up' > /dev/null
    ssh $i sudo reboot
done
