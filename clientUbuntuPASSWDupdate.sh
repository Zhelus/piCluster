#!/bin/bash

hosts=$(sudo awk '/#beginHOSTSconfig/{flag=1; next} /#endHOSTSconfig/{flag=0} flag' /etc/opt/piLab/masterConfig)

#ensure var do not match at start of program
str2="1"
ubuntuAccountPassword="0"

#-s suppress user input (don't show typed password) -p print to terminal what is in parethesis

echo "Create password for ubuntu account:"
while [ "$ubuntuAccountPassword" != "$str2" ]; do
        read -s -p "New password:" ubuntuAccountPassword
        echo ""
        read -s -p "Retype new password:" str2
        echo ""

        if [ "$ubuntuAccountPassword" != "$str2" ]; then
            echo "Passwords do not match."
            echo ""
        fi
    done

for i in $hosts
do
    #adds target machine ssh_key to known_hosts2
    ssh-keyscan -t ed25519 $i >> ~/.ssh/known_hosts2 2>/dev/null

    echo "Updating node $i"
    echo "Setting password for ubuntu"

    expect << EOF
    spawn ssh $i
    # Respond to prompts to update password on all new ubuntu images
    expect {
        -re "ubuntu@$i's password:" {
            send "ubuntu\n"
            exp_continue
        }
        -re ".*Current password: " {
            send "ubuntu\n"
            exp_continue
        }
        -re "New password: " {
            send "$ubuntuAccountPassword\n"
            exp_continue
        }
        -re "Retype new password: " {
            send "$ubuntuAccountPassword\n"
            exp_continue
        }
    }
    interact

EOF
done



