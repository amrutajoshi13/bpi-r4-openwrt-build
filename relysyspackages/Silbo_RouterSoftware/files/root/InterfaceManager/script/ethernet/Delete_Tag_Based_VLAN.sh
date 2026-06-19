#!/bin/sh

. /lib/functions.sh

TaggedBasedVLANFile=/etc/config/tagbasedvlanconfig
NoOfSectionCount=0


DeleteTagBased()
{
 readtagbased="$1"
 
  config_get rule "$readtagbased" rule
  config_get Name "$readtagbased" name
  
  uci delete network.$Name
  
  uci commit network
}

config_load "$TaggedBasedVLANFile"
config_foreach DeleteTagBased rule
logger -t config -p customs.info "network configuration changed"

exit 0



	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	  
	
	
	
	
	
	
	
	
	
	

