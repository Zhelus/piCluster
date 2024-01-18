#refined step0.sh
#!/bin/bash

#Since 90-cloud-init-users exists ubuntu is passwordless by default
#open hosts file

hosts=$(sudo awk '/#beginHOSTSconfig/{flag=1; next} /#endHOSTSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)

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
password='ubuntu'

echo "Create password for ubuntu account:"


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



#create service account on cluster
for i in $hosts
do
    #adds target machine ssh_key to known_hosts2
    ssh-keyscan -t ed25519 $i >> ~/.ssh/known_hosts2 2>/dev/null

    echo "Updating node $i"

    echo "Setting password for ubuntu"
    echo -e "$password\n$serviceAccountPassword\n$serviceAccountPassword" | sshpass -p $password ssh $i hostname 
done



