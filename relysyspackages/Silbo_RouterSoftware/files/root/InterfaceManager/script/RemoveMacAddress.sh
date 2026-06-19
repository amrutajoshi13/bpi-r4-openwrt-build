#!/bin/sh

. /lib/functions.sh

NetworkInterfacesFile="/etc/config/networkinterfaces"

DeleteMacAddress()
{
     readnetint="$1"
     
     config_get redirect "$readnetint" redirect
     config_get Interfacename "$readnetint" interface
     
      uci delete network.$Interfacename.macaddr
      uci delete networkinterfaces.$Interfacename.macaddress
    
      uci commit network
      uci commit networkinterfaces
 
}

config_load "$NetworkInterfacesFile" 
config_foreach DeleteMacAddress redirect

exit 0;

