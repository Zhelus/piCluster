#!/bin/bash

file="./hosts"
hosts=$(cat "$file")
lcd=$(cat microLCDservice)

for i in $hosts
do
	ssh $i mkdir /tmp/playground
	ssh $i git clone https://github.com/UCTRONICS/SKU_RM0004.git /tmp/playground/
	ssh $i make -C /tmp/playground/
	ssh $i "sudo bash -c 'echo \"$lcd\" > /lib/systemd/system/microlcd.service'"
	ssh $i sudo mkdir /etc/opt/microLCD
	ssh $i sudo cp /tmp/playground/display /etc/opt/microLCD/
	ssh $i sudo rm -r /tmp/playground
	ssh $i sudo systemctl daemon-reload
	ssh $i sudo systemctl enable microlcd.service
	ssh $i sudo reboot
done
