#!/bin/bash

sudo cat /etc/sssd/sssd.conf | grep ldap_search_base | awk -F ',' '{print $2","$3}' | awk -F '?' '{print $1}' | sudo tee /etc/sssd/LDAPsearchBase >/dev/null
sudo cat /etc/sssd/sssd.conf | grep ldap_uri | awk -F 'ldap_uri = ' '{print $2}' | sudo tee /etc/sssd/LDAPserver >/dev/null
sudo cat /etc/sssd/sssd.conf | grep ldap_default_bind_dn | awk -F 'ldap_default_bind_dn = ' '{print $2}' | sudo tee /etc/sssd/binddnAcct >/dev/null
sudo cat /etc/sssd/sssd.conf | grep ldap_default_authtok | awk -F 'ldap_default_authtok = ' '{print $2}' | sudo tee /etc/sssd/binddnPW >/dev/null
#sudo cat /etc/sssd/sssd.conf | grep ldap_access_filter | awk -F 'ldap_access_filter = memberOf=' '{print $2}' | awk -F ',' '{print "("$1")"}' | sudo tee /etc/sssd/securityGroup >/dev/null
