#refined step0.sh
#!/bin/bash
#this process assist in the creation of a service account on the head node and pushes it out to all nodes in the cluster.
#Additionally it adds the service account to /etc/sudoers.d/ansible for passwordless authentication

#Since 90-cloud-init-users exists ubuntu is passwordless by default
#open hosts file

hosts=$(awk '/#beginHOSTSconfig/{flag=1; next} /#endHOSTSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)

#install the proper sshpass
if [ -f /etc/lsb-release ]

then
 # Ubuntu
 cmd='sudo apt install sshpass --yes'

else
 # Rocky
 cmd='sudo dnf install sshpass -y'

fi
eval ${cmd}


#ensure var do not match at start of program
str2="1"
serviceAccountPassword="0"

#-s suppress user input (don't show typed password) -p print to terminal what is in parethesis
read -s -p "Input ssh password for cluster:" password
echo ""
read -p "Input name of service account you would like to create for the cluster: " serviceAccount

echo "Create password for service account:"


while [ "$serviceAccountPassword" != "$str2" ]; do
        read -s -p "New password:" serviceAccountPassword
        echo ""
        read -s -p "Retype new password:" str2
        echo ""

        if [ "$serviceAccountPassword" != "$str2" ]; then
            echo "Passwords do not match."
            echo ""
        fi
    done

#create service account on local machine
sudo -S useradd -m -d /home/$serviceAccount $serviceAccount 2>/dev/null
sudo -S chpasswd < <(echo "$serviceAccount:$serviceAccountPassword")
sudo -S chsh -s /bin/bash $serviceAccount
sudo -S bash -c "echo \"$serviceAccount ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$serviceAccount"

#update time zone on local machine   
echo $password | sudo -S timedatectl set-timezone America/Chicago


#create service account on cluster
for i in $hosts
do
    #adds target machine ssh_key to known_hosts2
    ssh-keyscan -t ed25519 $i >> ~/.ssh/known_hosts2 2>/dev/null

    echo "Updating node $i"
    #update time zone on target machine
    sshpass -p $password ssh $i sudo -S timedatectl set-timezone America/Chicago

    #creates an elevated bash to echo into a root file
    #this parenthatezation does work remotely
    sshpass -p $password ssh $i "sudo bash -c 'echo \"$serviceAccount ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$serviceAccount'"
    sshpass -p $password ssh $i sudo -S chmod 440 /etc/sudoers.d/$serviceAccount

    echo "Creating user $serviceAccount"
    #this has to be run before as autofs mounted will break priviladges to create this directory locally
    sshpass -p $password ssh $i sudo -S useradd -m -d /home/$serviceAccount $serviceAccount 2>/dev/null
    sshpass -p $password ssh $i sudo -S chsh -s /bin/bash $serviceAccount 2>/dev/null

    echo "Setting password for $serviceAccount"
    echo -e "$serviceAccountPassword\n$serviceAccountPassword" | sshpass -p $password ssh $i sudo -S passwd $serviceAccount
done



