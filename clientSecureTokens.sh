#refined steps2-5.sh
#!/bin/bash
#this script should be run as the cluster service account
#This allows for direct ssh to any node in the cluster without the use of the sshpass protocol

#-s suppress user input (don't show typed password) -p print to terminal what is in parethesis
#read -p "Enter management account:" acct
read -s -p "Enter account password:" password

file="./hosts"
hosts=$(cat "$file")

#ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<< "y" > /dev/null 2>&1
ssh-add ~/.ssh/id_rsa
#revist this as I am not sure why I did this in the first place, delete this in the final attempt as it doesn't make sense to have the 
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

#local sshHostKey Code
    ed25519=$(sudo cat /etc/ssh/ssh_host_ed25519_key)
    ed25519pub=$(sudo cat /etc/ssh/ssh_host_ed25519_key.pub)
 

for i in $hosts
do
    #should this be known_hosts2?
    ssh-keyscan -t ed25519 $i >> ~/.ssh/known_hosts
#this allows for remote access without password using RSA key pairs
    echo "Copying authorized_keys to node $i"
#new code
    sshpass -p "$password" ssh-copy-id $i
    sudo systemctl restart sshd    
#remote sshHostKey Code (new)
#this fixes the man in the middle issue by making all of the nodes have the same ssh key, this may need to be expanded to other key encryption types but works with tested systems
    echo "Copying ed25519 keys to node $i"
    ssh $i "sudo bash -c 'echo \"$ed25519\" > /etc/ssh/ssh_host_ed25519_key'" #ensure that permissions are 600
    ssh $i "sudo bash -c 'echo \"$ed25519pub\" > /etc/ssh/ssh_host_ed25519_key.pub'" #ensure that permissions are 644
done

#clean up original device ssh host keys
rm ~/.ssh/known_hosts2

#this is needed for the advanced commented code below
sssdConf=$(sudo cat /etc/sssd/sssd.conf)

for i in $hosts
do
    #Update ssh_known_hosts with modified keys
    ssh-keyscan -t ed25519 $i | sudo tee -a /etc/ssh/ssh_known_hosts > /dev/null
    #perform first update of new os

    ssh $i sudo apt update --yes

    echo "Installing sssd-tools on node $i"
    ssh $i sudo apt install sssd-tools --yes

    echo "Copying sssd.conf to node $i"
    ssh $i "sudo bash -c 'echo \"$sssdConf\" > /etc/sssd/sssd.conf'"

    #Update sssd.conf to the required owndership 600
    ssh $i sudo chmod 600 /etc/sssd/sssd.conf    
    ssh $i sudo systemctl restart sssd.service
done


#This code is commented out until the final implementation 
#file="./hosts"
#hosts=$(cat "$file")
#for i in $hosts
#do
#lock the service account and prevent direct login
#    ssh $acct@$i sudo usermod -L $USER
#done


