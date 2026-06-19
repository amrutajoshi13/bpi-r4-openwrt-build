#!/bin/sh

. /lib/functions.sh

PortBasedVLANFile=/etc/config/portbasedvlanconfig
NoOfSectionCount=0

DeletePortBased()
{
 readportbased="$1"
 
  config_get redirect "$readportbased" redirect
  config_get  vlanid "$readportbased" vlanid
  
  uci delete network.$vlanid
  
  uci commit network
}

config_load "$PortBasedVLANFile" 
config_foreach DeletePortBased redirect

exit 0
