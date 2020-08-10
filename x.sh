#!/bin/bash


## Downloading nginx 'default' file

if [[ $(ls default | grep default) ]]; 
then
  echo "# 'default' file exist. Deleting.. Then download a new one"
      rm default*
       wget https://raw.githubusercontent.com/jmcausing/LXCWP/master/files/default
else
   echo "# Downloading nginx default file to files/default"
   wget https://raw.githubusercontent.com/jmcausing/LXCWP/master/files/default
  
fi

