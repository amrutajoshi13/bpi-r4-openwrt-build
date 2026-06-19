#!/bin/sh
date=$(date) 
echo "script invoked $date" 
if [ -d /root/openwisp_backup/config ]; then
  echo "Directory exists."
else
    /root/InterfaceManager/script/Post_Reload_Script.sh > /dev/null 2>&1 
    echo "Directory does not exist"
     mkdir /root/openwisp_backup
     mkdir /root/openwisp_backup/config/
     cp /etc/openwisp/remote/etc/config/* /root/openwisp_backup/config/
fi

 
if [ -z "$( ls -A '/root/openwisp_backup/config' )" ];
then
    cp /etc/openwisp/remote/etc/config/* /root/openwisp_backup/config/
        /root/InterfaceManager/script/Post_Reload_Script.sh > /dev/null 2>&1 & 

fi
 
 
var=$(diff -qr /etc/openwisp/remote/etc/config/ /root/openwisp_backup/config)
if [ -z "$var" ]
then
     echo "configuration is same"
else
     cp /etc/openwisp/remote/etc/config/* /root/openwisp_backup/config
    /root/InterfaceManager/script/Post_Reload_Script.sh > /dev/null 2>&1 & 
fi
