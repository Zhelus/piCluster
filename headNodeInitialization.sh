#initialize head node
#!/bin/bash
#make the folder and download the github repository 
#mkdir piClustertest2
#git clone git@github.com:Zhelus/piCluster.git ~/piClustertest2 
sudo apt update
sudo apt upgrade
chmod 666 *
chmod 777 *.sh

echo "Copying masterConfig file to /etc/opt/piLab/masterConfig."
sudo mkdir /etc/opt/piLab
sudo cp -n masterConfigTEMPLATE /etc/opt/piLab/masterConfig

echo "Before continuing with the installation, take a moment to fill in the masterConfig file with your sites pertinent data."
