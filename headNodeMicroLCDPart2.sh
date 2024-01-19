#!/bin/bash

lcd=$(cat microLCDservice)
mkdir /tmp/playground
git clone https://github.com/UCTRONICS/SKU_RM0004.git /tmp/playground/
make -C /tmp/playground/
echo "$lcd" | sudo bash -c 'cat > /lib/systemd/system/microlcd.service'
sudo mkdir /etc/opt/microLCD
sudo cp /tmp/playground/display /etc/opt/microLCD/
sudo rm -r /tmp/playground
sudo systemctl daemon-reload
sudo systemctl enable microlcd.service
sudo reboot
