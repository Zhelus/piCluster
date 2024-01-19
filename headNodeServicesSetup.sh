#!/bin/bash
#HAProxysetup.sh

fw=$(sudo awk '/#beginFWconfig/{flag=1; next} /#endFWconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)
haproxy=$(sudo awk '/#beginHAPROXYconfig/{flag=1; next} /#endHAPROXYconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)
sshAdminPort=$(sudo awk '/#beginSSHconfig/{flag=1; next} /#endSSHconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)
sssdConf=$(sudo awk '/#beginSSSDconfig/{flag=1; next} /#endSSSDconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)


#Setup and initialize firewall
for i in $fw
do	
	echo "Adding firewall rule $i"
	sudo ufw allow $i
done

echo "Ensure ssh port has been added above"
sudo ufw enable
sudo ufw reload


#Install and start nfs service
sudo apt install nfs-kernel-server -y
sudo systemctl start nfs-kernel-server.service


#Update SSH admin port
#ensure that this port is open by your institution and opened by ufw with sudo ufw status
#the ssh port to the server has to get reassigned for HAProxy to take over managing port 22
echo "Updating SSH port to $sshAdminPort"
sudo awk -i inplace '{gsub(/#Port/, "Port '"$sshAdminPort"'"); print}' /etc/ssh/sshd_config
sudo systemctl restart ssh


#install and start haproxy service
sudo apt install haproxy -y
echo "$haproxy" | sudo bash -c 'cat > /etc/haproxy/haproxy.cfg'
#create the error files:
sudo touch /etc/haproxy/errors/400.http /etc/haproxy/errors/403.http /etc/haproxy/errors/408.http /etc/haproxy/errors/500.http /etc/haproxy/errors/502.http /etc/haproxy/errors/503.http /etc/haproxy/errors/504.http
sudo systemctl restart haproxy.service


#Setup and initialize SSSD
sudo apt install sssd-tools --yes
echo "Copying sssd.conf to node $i"
echo "$sssdConf" | sudo bash -c 'cat > /etc/sssd/sssd.conf'
#Update sssd.conf to the required owndership 600
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd.service
sudo cat /etc/sssd/sssd.conf | grep ldap_search_base | awk -F ',' '{print $2","$3}' | awk -F '?' '{print $1}' | sudo tee /etc/sssd/LDAPsearchBase >/dev/null
sudo cat /etc/sssd/sssd.conf | grep ldap_uri | awk -F 'ldap_uri = ' '{print $2}' | sudo tee /etc/sssd/LDAPserver >/dev/null
sudo cat /etc/sssd/sssd.conf | grep ldap_default_bind_dn | awk -F 'ldap_default_bind_dn = ' '{print $2}' | sudo tee /etc/sssd/binddnAcct >/dev/null
sudo cat /etc/sssd/sssd.conf | grep ldap_default_authtok | awk -F 'ldap_default_authtok = ' '{print $2}' | sudo tee /etc/sssd/binddnPW >/dev/null
