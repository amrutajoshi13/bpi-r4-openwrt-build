#!/bin/sh

. /lib/functions.sh

TaggedBasedVLANFile=/etc/config/tagbasedvlanconfig
NoOfSectionCount=0

ReadTaggedBasedVLANConfigFile()
{
   config_load "$TaggedBasedVLANFile"
   config_foreach UpdateTaggedBasedVLANFile rule
}

UpdateTaggedBasedVLANFile()
{
	
 readtaggedbased="$1"
 #echo "$readportbased"
 #echo "NoOfSectionCount is $NoOfSectionCount"

 config_get name "$readtaggedbased" name	
 config_get type "$readtaggedbased" type
 config_get ifname "$readtaggedbased" ifname
 
 uci set network.$name="device"
 uci set network.$name.name="$name"
 uci set network.$name.type="8021q"
 uci set network.$name.ifname="$ifname"
 
 uci commit network
} 

	  
ReadTaggedBasedVLANConfigFile	  
#UpdatePortBasedVLANConfigFile
logger -t config -p customs.info "network configuration changed"
exit 0	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	
	
	
	
	
	
	
	
	
	

