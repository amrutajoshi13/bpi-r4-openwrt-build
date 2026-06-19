#!/bin/sh

. /lib/functions.sh

UpdateWanConfigScript="/bin/UpdateWanConfig.sh"
mwan3failoverscript="/root/InterfaceManager/script/Mwan3_Failover.sh"
validateTrackIPscript="/bin/ValidateTrackIP.sh"

rm -rf /bin/wanpriorities.txt
touch /bin/wanpriorities.txt
chmod 0777 /bin/wanpriorities.txt

ReadPriority()
{
  config=$1
  config_get WanPriority "$config" wanpriority 
  echo $WanPriority >> /bin/wanpriorities.txt
  
}

rm -rf /bin/priorityvalidationoutput.txt
touch  /bin/priorityvalidationoutput.txt
chmod 0777 /bin/priorityvalidationoutput.txt


config_load "/etc/config/mwan3config" 
config_foreach ReadPriority mwan3config


output=$(sort /bin/wanpriorities.txt | uniq -d)
echo "output=$output"

if [ -z "$output" ]  
then 
   echo "Updating Configurations " > /bin/priorityvalidationoutput.txt 
   flag=1
   $mwan3failoverscript
   $UpdateWanConfigScript
   #sh -x "$validateTrackIPscript"
  
else
	 echo "Non Unique Priorities. Cannot update Configurations" > /bin/priorityvalidationoutput.txt
	 flag=0
fi

exit 1
