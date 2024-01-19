#!/bin/bash

hosts=$(sudo awk '/#beginHOSTSconfig/{flag=1; next} /#endHOSTSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)
banner=$(sudo awk '/#beginBANNERconfig/{flag=1; next} /#endBANNERconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)
prompt=$(sudo awk '/#beginPROMPTconfig/{flag=1; next} /#endPROMPTconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)

for i in $hosts
do
	
    echo "Updating node $i welcome banner"
    ssh $i sudo chmod -x /etc/update-motd.d/*
    echo "$banner" | ssh $i 'sudo bash -c "cat > /etc/update-motd.d/00-custom-header"'	
    ssh $i sudo chmod +x /etc/update-motd.d/00-custom-header
    echo "$prompt" | ssh $i 'sudo bash -c "cat >> /etc/bash.bashrc"'	
    echo "" | ssh $i 'sudo bash -c "cat > /etc/legal"'	
    
done

