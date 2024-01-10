#!/bin/bash
#this script should be run as the cluster service account
#This allows for direct ssh to any node in the cluster without the use of the sshpass protocol

#-s suppress user input (don't show typed password) -p print to terminal what is in parethesis
#read -p "Enter management account:" acct


LDAPsearchBase=$(sudo cat /etc/sssd/LDAPsearchBase)
binddnAcct=$(sudo cat /etc/sssd/binddnAcct)
#yes there the -Y flag to point to the password file, but I want it owned by root so this script doesn't have to be run elevated
binddnPW=$(sudo cat /etc/sssd/binddnPW)
SG=$(sudo cat /etc/sssd/securityGroup)
LDAPserver=$(sudo cat /etc/sssd/LDAPserver)


ldapsearch -H "$LDAPserver" -x -D "$binddnAcct" -w "$binddnPW" -b "$LDAPsearchBase" "$SG" | grep member: | awk -F'CN=' '{print $2}' | awk -F',' '{print $1}' | awk '{print tolower($0)}' > groupMembership

members=$(cat "groupMembership")

for i in $members
do
	sudo mkdir /home/$i
	sudo chown -R $i /home/$i
	echo "/home/$i *(rw,sync,subtree_check)" | sudo tee -a /etc/exports	
done
rm groupMembership

