#!/bin/bash

sudo apt install make -y
sudo apt install gcc -y
sudo tee -a /boot/firmware/config.txt <<< 'dtparam=i2c_arm=on,i2c_arm_baudrate=400000' > /dev/null
sudo tee -a /boot/firmware/config.txt <<< 'dtoverlay=gpio-shutdown,gpio_pin=4,active_low=1,gpio_pull=up' > /dev/null
sudo reboot
