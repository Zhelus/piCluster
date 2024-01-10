#initialize head node
#!/bin/bash
#make the folder and download the github repository 
#mkdir piClustertest2
#git clone git@github.com:Zhelus/piCluster.git ~/piClustertest2 
sudo apt update
sudo apt upgrade
chmod 666 ~/piClustertest2/*
chmod 777 ~/piClustertest2/*.sh

echo "Copying masterConfig file to home directory."
cp ~/piClustertest2/masterConfigTEMPLATE ~/masterConfig

echo "Before continuing with the installation, take a moment to fill in the masterConfig file with your sites pertinent data."
