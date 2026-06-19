#!/bin/sh

. /lib/functions.sh

DHCPRelayFile="/etc/config/dhcprelayconfig"

#emptying the file /etc/dnsmasq.conf
echo -n > /etc/dnsmasq.conf 

ReadDHCPRelayConfigFile()
{
   config_load "$DHCPRelayFile"
   config_foreach UpdateDHCPRelayConfigFile relay
}

UpdateDHCPRelayConfigFile()
{
 readnetint="$1"
	
 config_get Interfacename "$readnetint" interface
 config_get endip "$readnetint" endip  
 config_get startip "$readnetint" startip
 config_get netmask "$readnetint" netmask
 config_get leasetime "$readnetint" leasetime
 
 	  
 	  echo "dhcp-range=${startip},${endip},${netmask},${leasetime}h" >> /etc/dnsmasq.conf
 	  
	          
     NoOfSectionCount=$((NoOfSectionCount + 1))
    
}      	   
	
#RestartInitScript()
#{
	#/etc/init.d/dnsmasq restart
#}
    
    
ReadDHCPRelayConfigFile    
#RestartInitScript    
    
exit 0    	
	
