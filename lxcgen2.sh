#!/bin/bash

clear


echo "#### LXC generator by John Mark C."
echo "# Package: LXC, Nginx"
echo "#"

if [ "$1" == "clean" ]
  then

   #  - START - Clean up ssh keys with lxc string
   #
   if [[ $(ls $HOME/.ssh/ | grep lxc) ]]; 
   then
      echo "# LXC ssh files found! Deleting.."
      rm $HOME/.ssh/*lxc*
   else
      echo "# No LXC SSH key found. Already clean!"
   fi
   #
   # - END -  Clean up ssh keys with lxc string

   #  - START - Clean up for ansible files (hosts and playbook)
   #
   if [[ $(ls | grep _hosts) ]]; 
   then
      echo "# Ansible LXC Host file found! Deleting.."
      rm *_hosts*
   else
      echo "# No Ansible LXC Host file found!  Already clean!"
   fi
   #


   if [[ $(ls | grep _lemp.yml) ]]; 
   then
      echo "# Ansible LXC Playbook file found! Deleting.."
      rm *_lemp.yml*
   else
      echo "# No Ansible LXC Playbook file found Already clean!"
   fi
   #
   # - END -   Clean up for ansible files (hosts and playbook)   



   #  - START - Clean up LXC containers
   #
   if [[ $(lxc list | awk '!/NAME/{print $2}') ]]; 
   then
      echo "# LXC Containers found! Deleting.."
      lxc delete $(lxc list | awk '!/NAME/{print $2}' | awk NF) --force
  
   else
      echo "# No LXC Containers found. Already clean!"
   fi   
   #
   # - END -   Clean up LXC containers

    lxc list
    ls -al $HOME/.ssh/
    echo "#"
    echo "# Done!"
    exit 1
fi


echo "# Hello! Enter the LXC container name please:"

read -p "# Enter LXC name: " lxcname


echo "# Alright! Let's generate the LXC container Ubuntu 18.04: $lxcname"
echo "#"
echo "#"


# 18.04
lxc launch ubuntu:18.04 $lxcname


# 16.04
#lxc launch ubuntu:16.04 $lxcname


echo "#"
echo "# Let's generate SSH-KEY gen for this LXC"
echo "#"
ssh-keygen -f $HOME/.ssh/id_lxc_$lxcname -N '' -C 'key for local LXC'

echo "#"
echo "# - START - Details from ssh key gen"

ls $HOME/.ssh/
cat $HOME/.ssh/id_lxc_$lxcname.pub


echo "#"
echo "#"
echo "# START - Info of LXC: ${lxcname}"


echo "#"
echo "# Trying to get the LXC IP Address.."


LXC_IP=$(lxc list | grep ${lxcname} | awk '{print $6}')

VALID_IP=^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$


# START - SPINNER 
#
sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}
#
# - END SPINNER


while ! [[ "${LXC_IP}" =~ ${VALID_IP} ]]; do
 # sleep 1
 #  echo "LXC ${lxcname} has still no IP "
 #  echo "Checking again.." 
 #  echo "#"
 #  echo "#"
 #  lxc list
    LXC_IP=$(lxc list | grep ${lxcname} | awk '{print $6}')
    spin
 #  echo "IP is: ${LXC_IP}"
done
endspin

echo "# IP Address found!  ${lxcname} LXC IP: ${LXC_IP}"
#lxc info $lxcname
echo "# "

echo "# Checking status of LXC list again.."
lxc list


echo "# Sending public key to target LXC: " ${lxcname}
echo "#"
#echo lxc file push $HOME/.ssh/id_lxc_${lxcname}.pub ${lxcname}/root/.ssh/authorized_keys

#Pause for 2 seconds to make sure we get the IP and push the file.
sleep 4

# Send SSH key file from this those to the target LXC
lxc file push $HOME/.ssh/id_lxc_${lxcname}.pub ${lxcname}/root/.ssh/authorized_keys --verbose

echo "#"
echo "# Fixing root permission for authorized_keys file"
echo "#"
lxc exec ${lxcname} -- chmod 600 /root/.ssh/authorized_keys --verbose
lxc exec ${lxcname} -- chown root:root /root/.ssh/authorized_keys --verbose
echo "#"
echo "# Adding SSH-key for this host so we can SSH to the target LXC."
echo "#"
eval $(ssh-agent); 
ssh-add $HOME/.ssh/id_lxc_$lxcname
echo "#"
echo "# Done! Ready to connect?"
echo "#"
echo "# Connect to this: ssh -i ~/.ssh/id_lxc_${lxcname} root@${LXC_IP}"
echo "#"
echo "#"


# ssh key variable location
SSHKEY=~/.ssh/id_lxc_${lxcname}




# echo "# Let's install WordPress with LEMP stack using Ansible."
# echo "# Creating playbook lemp.yml and host file"
# echo "- hosts: all

#   vars:
#     ansible_host_key_checking: false

#     # Workaround if LXC target host does not have python 3 (not by default).
#     ansible_python_interpreter: "/usr/bin/python3"

#   become: true
#   become_user: root

#   tasks:
#     - name: apt clean
#       shell: apt clean
#       become: true
#       become_user: root

#     - name: apt update
#       shell: apt update
#       become: true
#       become_user: root

#     - name: Install Nginx latest version
#       apt: name=nginx state=latest
#     - name: start nginx
#       service:
#           name: nginx
#           state: started" >  ${lxcname}_lemp.yml


echo "[lxc]
${LXC_IP} ansible_user=root "> ${lxcname}_hosts




# Downloading ansible files 
# Playbook yml file
if [[ $(ls play.yml | grep play.yml) ]]; 
then
   echo "# Existing play.yml detected. Deleting and downloading a new one."
   echo "#"
   echo "#"
   rm play.yml
   wget https://github.com/jmcausing/LXCWP/raw/master/play.yml
   echo "#"
   echo "# Renaming play.ml to ${lxcname}_lemp.yml"
   mv play.yml ${lxcname}_lemp.yml
else
   echo "#"
   echo "#"
   echo "Downloading play.yml playbook"
   echo "#"
   wget https://github.com/jmcausing/LXCWP/raw/master/play.yml
   mv play.yml ${lxcname}_lemp.yml
fi

# vars file
if [[ $(ls vars.yml | grep vars.yml) ]]; 
then
   echo "# Existing vars.yml detected. Deleting and downloading a new one."+
   echo "#"
   echo "#"
   rm vars.yml
   wget https://github.com/jmcausing/LXCWP/raw/master/vars.yml
   echo "#"
   echo "#"
   echo "# Here's the varls.yml file: "
   cat vars.yml

else
   echo "#"
   echo "#"
   echo "Downloading vars.yml playbook"
   wget https://github.com/jmcausing/LXCWP/raw/master/vars.yml
fi

echo "# Checking files.."
ls -al  ${lxcname}_lemp.yml
ls -al  ${lxcname}_hosts
ls -al vars.yml
echo "#"


echo "#"
echo "# Running playbook with this command:"
echo "#"
echo "# ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ${lxcname}_lemp.yml -i ${lxcname}_hosts --private-key=${SSHKEY} -vvv"
echo "#"

# ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ${lxcname}_lemp.yml -i ${lxcname}_hosts --private-key=~${SSHKEY} 

echo "#"
echo "# Thank you for using this basic LXC SSH setup!"