#!/bin/sh

. /lib/functions.sh

FirewallUCIPath=/etc/config/macidconfig

guestwifi_Enable=$(uci get sysconfig.guestwifi.guestwifienable)

ReadFirewallUCIConfig() {
       config_load "$FirewallUCIPath"
       config_foreach FirewallConfigParameters macidconfig
}

FirewallConfigParameters() {
       local FirewallConfigSection="$1"
       config_get macidblock "$FirewallConfigSection" MACID
       config_get MACfiltering "$FirewallConfigSection" Accesspolicy
       config_get Entry "$FirewallConfigSection" EEnable
       config_get Disable "$FirewallConfigSection" MACfilteringSwitch
       config_get NetworkName "$FirewallConfigSection" NetworkMode

       if [ "$NetworkName" = "1" ]; then
              if [ "$MACfiltering" = "whitelist" ] || [ "$MACfiltering" = "blacklist" ]; then
                     {

                            if [[ -z $var ]]; then
                                   var=$macidblock
                            else
                                   var="$var;$macidblock"
                            fi
                            if [ "$MACfiltering" = "whitelist" ]; then
                                   AccessPolicyvalue=1

                            elif [ "$MACfiltering" = "blacklist" ]; then
                                   AccessPolicyvalue=2
                            fi

                     }
              fi

       elif [ "$NetworkName" = "2" ]; then
              if [ "$MACfiltering" = "whitelist" ] || [ "$MACfiltering" = "blacklist" ]; then
                     {

                            if [[ -z $var1 ]]; then
                                   var1=$macidblock
                            else
                                   var1="$var1;$macidblock"
                            fi
                            if [ "$MACfiltering" = "whitelist" ]; then
                                   AccessPolicyGuestwifivalue=1

                            elif [ "$MACfiltering" = "blacklist" ]; then
                                   AccessPolicyGuestwifivalue=2
                            fi

                     }
              fi

       fi

       if [ "$Disable" = "0" ] && [ "$NetworkName" = "2" ]; then
              if [[ -z $var2 ]]; then
                     var2=$macidblock
              else
                     var2="$var2;$macidblock"
              fi
       fi

}

ReadFirewallUCIConfig

iwpriv ra0 set AccessPolicy="$AccessPolicyvalue"
echo AccessPolicy is "$AccessPolicyvalue"

iwpriv ra0 set ACLAddEntry="$var"
echo var is "$var"

iwpriv ra0 set ACLShowAll="$Entry"
echo "$Entry"

# Check if guest WiFi is enabled (assuming enabled is 1)
if [ "$guestwifi_Enable" -eq 1 ]; then

       iwpriv ra1 set AccessPolicy=$AccessPolicyGuestwifivalue
       echo AccessPolicyGuestwifivalue is "$AccessPolicyGuestwifivalue"

       iwpriv ra1 set ACLAddEntry="$var1"
       echo "ra1 is var1 is $var1"

       iwpriv ra1 set ACLDelEntry="$var2"
       echo "ra1 is var2 is $var2"

       iwpriv ra1 set ACLShowAll=$Entry
       echo ra1 is $Entry
fi
