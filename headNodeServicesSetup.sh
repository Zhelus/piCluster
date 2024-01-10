#!/bin/bash
#HAProxysetup.sh

fw=$(awk '/#beginFWconfig/{flag=1; next} /#endFWconfig/{flag=0} flag' ~/masterConfig)
haproxy=$(awk '/#beginHAPROXYconfig/{flag=1; next} /#endHAPROXYconfig/{flag=0} flag' ~/masterConfig)
sshAdminPort=$(awk '/#beginSSHconfig/{flag=1; next} /#endSSHconfig/{flag=0} flag' ~/masterConfig)

sudo ufw allow $fw
sudo ufw enable

sudo apt install nfs-kernel-server -y
sudo systemctl start nfs-kernel-server.service

sudo apt install haproxy -y

#ensure that this port is open by your institution and opened by ufw with sudo ufw status
#the ssh port to the server has to get reassigned for HAProxy to take over managing port 22
sudo awk -i inplace '{gsub(/Port 22/, "Port '"$sshAdminPort"'"); print}' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "$haproxy" | sudo bash -c 'cat > /etc/haproxy/haproxy.cfg'
#create the error files:

sudo touch /etc/haproxy/errors/400.http /etc/haproxy/errors/403.http /etc/haproxy/errors/408.http /etc/haproxy/errors/500.http /etc/haproxy/errors/502.http /etc/haproxy/errors/503.http /etc/haproxy/errors/504.http
sudo systemctl restart haproxy.service
