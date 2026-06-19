#!/bin/sh

. /lib/functions.sh

FirewallUCIPath=/etc/config/urlipconfig                                                                                                        

ReadFirewallUCIConfig()
{
        config_load "$FirewallUCIPath"
        config_foreach FirewallConfigParameters urlipconfig
}

FirewallConfigParameters()
{
    local FirewallConfigSection="$1"
    NoOfSectionCount=$((NoOfSectionCount + 1))
    echo "NoOfSectionCount is $NoOfSectionCount"

    config_get  urlblock      "$FirewallConfigSection"   RS485ConfigSectionName
    echo "url is $urlblock"
    
    config_get  Enableurlvalue    "$FirewallConfigSection"   UrlfilteringSwitch
    echo "url is $Enableurlvalue"

    if [ "$Enableurlvalue" = "1" ]
    then 
	uci add_list dhcp.@dnsmasq[0].server=$urlblock
   fi
	uci commit dhcp
}
uci delete dhcp.@dnsmasq[0].server

ReadFirewallUCIConfig

/etc/init.d/dnsmasq restart
