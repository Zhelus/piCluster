#!/bin/bash

LDAPsearchBase=$(sudo cat /etc/sssd/LDAPsearchBase)
binddnAcct=$(sudo cat /etc/sssd/binddnAcct)
#yes there the -Y flag to point to the password file, but I want it owned by root so this script doesn't have to be run elevated
binddnPW=$(sudo cat /etc/sssd/binddnPW)
LDAPserver=$(sudo cat /etc/sssd/LDAPserver)
#SG=$(sudo cat /etc/sssd/securityGroup)
SG=$(sudo awk '/#beginSGconfig/{flag=1; next} /#endSGconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)

ldapsearch -H "$LDAPserver" -x -D "$binddnAcct" -w "$binddnPW" -b "$LDAPsearchBase" "(cn=$SG)" | grep member: | awk -F'CN=' '{print $2}' | awk -F',' '{print $1}' | awk '{print tolower($0)}' > groupMembership

members=$(cat "groupMembership")
echo $SG
for i in $members
do
	if [ -d "/home/$i" ]; then
   		echo "$i NFS resources already exist. Skipping $i."
	else
		echo "Creating NFS resources for $i"	
		sudo mkdir /home/$i
		sudo chown -R $i /home/$i >/dev/null
		echo "/home/$i *(rw,sync,subtree_check)" | sudo tee -a /etc/exports >/dev/null
	fi
done

sudo exportfs -a
rm groupMembership
