#!/bin/bash


## Downloading nginx 'default' file

if [[ $(ls play.yml | grep play.yml) ]]; 
then
   echo "# Existing play.yml detected. Deleting and downloading a new one."
   rm play.yml
   wget https://github.com/jmcausing/LXCWP/raw/master/play.yml
else
   echo "Downloading play.yml playbook"
   wget https://github.com/jmcausing/LXCWP/raw/master/play.yml
fi

