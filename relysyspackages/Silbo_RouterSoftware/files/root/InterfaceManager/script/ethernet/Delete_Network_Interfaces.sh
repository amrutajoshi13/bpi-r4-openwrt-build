#!/bin/sh

. /lib/functions.sh

NetworkInterfacesFile="/etc/config/networkinterfaces"

wifista="WIFI_WAN"
wifiap="ra0"
wifiap1="ra1"

#The interface name, which was deleted from the webpage is parsed as an argument in .js file and stored in the variable "Deleted_Interface".
Deleted_Interface="$1"

DeleteNetworkInterface()
{
     readnetint="$1"
     
     config_get redirect "$readnetint" redirect
     config_get Interfacename "$readnetint" interface
     
      uci delete firewall.${wifista}${Interfacename}
	  uci delete firewall.${wifiap}${Interfacename}
	  uci delete firewall.${wifiap1}${Interfacename}
     
      uci delete network.$Interfacename
      uci delete dhcp.$Interfacename
      uci delete firewall.$Interfacename
    
      uci commit network
      uci commit dhcp
      uci commit firewall
 
}


config_load "$NetworkInterfacesFile" 
config_foreach DeleteNetworkInterface redirect

exit 0;

