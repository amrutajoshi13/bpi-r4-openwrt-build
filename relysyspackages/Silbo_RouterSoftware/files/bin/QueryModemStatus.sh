#!/bin/sh

. /lib/functions.sh

modemUCIPath=/etc/config/modem
sysconfigsection="interface"

ReadConfig()
{
  var1="$1"
  config_get ModemEnable "$var1" modemenable	
  config_get MonitorEnable "$var1" monitorenable	
}

RunAnalytics()
{
  var="$1"	
  ReadConfig "$var"
  if [ "$ModemEnable" = "1" ] && [ "$MonitorEnable" = "1" ]
  then 
 #   /root/InterfaceManager/script/InterfaceAnalyticsManager.sh "$var" "<,3,cron,>"
    ubus call interfacemanager laststatus {\"interface\":\"$var\"}
  fi
  
}

rm -rf /bin/querymodemstatusoutput
touch /bin/querymodemstatusoutput
chmod 0777 /bin/querymodemstatusoutput


config_load "$modemUCIPath"
config_foreach RunAnalytics interface


 #~ if [ "$CellularOperationMode" = "dualcellularsinglesim" ]
	 #~ then
			#~ interface1="CWAN1"
			#~ ubus call interfacemanager currentstatus '{"interface" : "CWAN1" }'
			#~ interface2="CWAN2"	      
	 #~ fi
	 
	 #~ if [ "$CellularOperationMode" = "singlecellulardualsim" ]
	 #~ then
	 
			#~ interface1="CWAN1_0"
			#~ ubus call interfacemanager currentstatus '{"interface" : "CWAN1_0" }'
			#~ interface2="CWAN1_1"	
	 #~ fi
	 
	 #~ if [ "$CellularOperationMode" = "singlecellularsinglesim" ]
	 #~ then
	     
	       #~ interface1="CWAN1"
	       #~ ubus call interfacemanager currentstatus '{"interface" : "CWAN1" }'
	 #~ fi

#~ #interface="WAN1"
#~ ubus call interfacemanager currentstatus '{"interface" : "$interface1" }'

#~ ubus call interfacemanager currentstatus '{"interface" : "$interface2" }'

echo "Status Updated" > /bin/querymodemstatusoutput
exit 0
