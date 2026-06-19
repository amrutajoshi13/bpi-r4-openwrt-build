#!/bin/sh

. /lib/functions.sh

PortBasedVLANFile=/etc/config/portbasedvlanconfig
NoOfSectionCount=0

ReadPortBasedVLANConfigFile()
{
   config_load "$PortBasedVLANFile"
   config_foreach UpdatePortBasedVLANConfigFile redirect
}

UpdatePortBasedVLANConfigFile()
{
	
 readportbased="$1"
 #echo "$readportbased"
 #echo "NoOfSectionCount is $NoOfSectionCount"

 config_get vlanid "$readportbased" vlanid	
 config_get port0 "$readportbased" port0
 config_get port1 "$readportbased" port1
 config_get port2 "$readportbased" port2
 config_get port3 "$readportbased" port3
 config_get port4 "$readportbased" port4
 config_get interface "$readportbased" interface
 echo "$interface"
 
 uci set network.$vlanid="switch_vlan"
 uci set network.$vlanid.device="switch0"
 uci set network.$vlanid.vlan="$vlanid"
 
a=""
 
 for i in $(seq 0 4) 
 do 
 port=$(uci get portbasedvlanconfig.@redirect[$NoOfSectionCount].port${i})
 if [ "$port" = "tagged" ]
 then
	a=$(echo "$a${i}t ")
elif [ "$port" = "untagged" ]
    then
      a=$(echo "$a${i} ")
else 
      a=$(echo "$a")    	
fi
 done
 uci set network.$vlanid.ports="$a 6t"
 
 NoOfSectionCount=$((NoOfSectionCount + 1))
 uci commit network
} 

	  
ReadPortBasedVLANConfigFile	  
#UpdatePortBasedVLANConfigFile

exit 0	  
	  
	  
	
