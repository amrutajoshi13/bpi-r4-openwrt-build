#!/bin/sh

. /lib/functions.sh

mwan3status=$(uci get mwan3config.general.select)
chmod 700 
ReadpptpdUCIConfig() {
    config_load "$PptpdUCIPath"
    config_foreach pptpdConfigParameters service
}

pptpdConfigParameters() {
    
    local pptpdConfigSection="$1"
    
    config_get Name "$pptpdConfigSection" name
	
	#Server
    config_get Type "$pptpdConfigSection" type
    config_get LocalIP "$pptpdConfigSection" localip
    config_get RemoteIP "$pptpdConfigSection" remoteip
    config_get Enabled "$pptpdConfigSection" enabled
    config_get Password "$pptpdConfigSection" password
    config_get UserName "$pptpdConfigSection" username
    #Client
    config_get Proto "$pptpdConfigSection" proto
    config_get Keepalive "$pptpdConfigSection" keepalive
    config_get Metric "$pptpdConfigSection" metric
    config_get Serverip "$pptpdConfigSection" serverip
    config_get UsserName "$pptpdConfigSection" usernamee
    config_get PAssword "$pptpdConfigSection" passwordd
    config_get Defaultroute "$pptpdConfigSection" defaultroute 
    config_get Interface "$pptpdConfigSection" interface
	
	#SERVER
    if [ "$Type" == "SERVER" ];
    then

		uci set pptpd.pptpd=service
		uci set pptpd.pptpd.name=$Name
		uci set pptpd.pptpd.type=$Type                          
		uci set pptpd.pptpd.localip=$LocalIP             
		uci set pptpd.pptpd.remoteip=$RemoteIP     
		uci set pptpd.pptpd.enabled=$Enabled  
		
		uci set pptpd."pptpd_$Name"=login
		uci set pptpd."pptpd_$Name".password=$Password
		uci set pptpd."pptpd_$Name".username=$UserName
		
		uci commit pptpd
		logger -t config -p customs.info "pptpd configuration changed"

	fi

	if [ "$Enabled" == "1" ]                                         
	then                                                      
		 disabled=0                                               
	else                                                      
		 disabled=1                                                  
	fi 
	
	#CLIENT
	if [ "$Type" == "CLIENT" ];                       
	then
		
		#Writes "uci delete network.$Name" to /root/InterfaceManager/script/vpn/pptp/ucidelete.sh & 
		#then deletes that particular name from network config.
		echo uci delete network.$Name                          

		uci set network.$Name=interface
		uci set network.$Name.proto=$Proto
		uci set network.$Name.keepalive="$Keepalive"
		uci set network.$Name.metric=$Metric
		uci set network.$Name.name=$Name
		uci set network.$Name.ifname="pptp-$Name" 
		uci set network.$Name.server=$Serverip
		uci set network.$Name.username=$UsserName
		uci set network.$Name.password=$PAssword
		uci set network.$Name.defaultroute=$Defaultroute
		uci set network.$Name.disabled=$disabled
		
		#Set the interface as empty, if any is selected.
		if [ "$Interface" = "any" ]
		then
			Interface=""
		fi
		uci set network.$Name.interface=$Interface
		
		#Add rule, if it is set as default route.
		#Adding the below rule with precedence 1, will make all the interfaces not route through table 1,2 ... etc,
		#but, via main table.
		if [ "$Defaultroute" = "1" ]
		then
			ip rule add from all lookup main priority 1
		else
			ip rule del from all lookup main priority 1
		fi

		##OLD

		echo uci delete firewall.port_$Name

		##NEW

		echo uci delete firewall.$Name

		uci set firewall.$Name=zone
		uci set firewall.$Name.name="$Name"
		uci set firewall.$Name.input="ACCEPT"
		uci set firewall.$Name.output="ACCEPT"
		uci set firewall.$Name.forward="REJECT"
		uci set firewall.$Name.masq="1"
		uci set firewall.$Name.mtu_fix="1"
		uci set firewall.$Name.network="$Name"

		#Creating the firewall Forwarding ZONE
	    wanCount=$(cat /etc/waninterface.txt | wc -l)
        for j in $(seq 1 ${wanCount}); do
 
                wan=$(cat /etc/waninterface.txt | head -${j} | tail -1)
 
                #Creating the firewall Forwarding ZONE
 
                uci set firewall.src${wan}_$Name="forwarding"
                uci set firewall.src${wan}_$Name.src="$Name"
                uci set firewall.src${wan}_$Name.dest=${wan}
 
                uci set firewall.des${wan}_$Name="forwarding"
                uci set firewall.des${wan}_$Name.src=${wan}
                uci set firewall.des${wan}_$Name.dest="$Name"
 
                echo uci delete firewall.src${wan}_$Name
                echo uci delete firewall.des${wan}_$Name
        done
 
        lanCount=$(cat /etc/internetoverlan.txt | wc -l)
        for k in $(seq 1 ${lanCount}); do
                lan=$(cat /etc/internetoverlan.txt | head -${k} | tail -1)
 
                uci set firewall.src${lan}_$Name="forwarding"
                uci set firewall.src${lan}_$Name.src="$Name"
                uci set firewall.src${lan}_$Name.dest=${lan}
 
                uci set firewall.des${lan}_$Name="forwarding"
                uci set firewall.des${lan}_$Name.src=${lan}
                uci set firewall.des${lan}_$Name.dest="$Name"
 
                echo uci delete firewall.src${lan}_$Name
                echo uci delete firewall.des${lan}_$Name
 
        done
		#Create a firewall rule to open port 1723
		uci set firewall.port_$Name=rule
		uci set firewall.port_$Name.dest_port='1723'
		uci set firewall.port_$Name.src="$Name"
		uci set firewall.port_$Name.name='Allow-pptp-traffic'
		uci set firewall.port_$Name.target='ACCEPT'
		uci set firewall.port_$Name.vpn_type='pptp'
		uci set firewall.port_$Name.proto='tcp'
		uci set firewall.port_$Name.family='ipv4'


		    echo uci delete firewall.srcCWAN1_$Name
			echo uci delete firewall.destCWAN1_$Name

		    echo uci delete firewall.srcCWAN1_0_$Name
            echo uci delete firewall.destCWAN1_0_$Name

			echo uci delete firewall.srcCWAN1_1_$Name
            echo uci delete firewall.destCWAN1_1_$Name

		cellularoperationmode=$(uci get sysconfig.sysconfig.CellularOperationMode)
		if [ "$cellularoperationmode" = "singlecellularsinglesim" ]
		then 
			uci set firewall.srcCWAN1_$Name="forwarding"
			uci set firewall.srcCWAN1_$Name.src="$Name"
			uci set firewall.srcCWAN1_$Name.dest="CWAN1"

			uci set firewall.destCWAN1_$Name="forwarding"
			uci set firewall.destCWAN1_$Name.src="CWAN1"
			uci set firewall.destCWAN1_$Name.dest="$Name"
		else	 
		    uci set firewall.srcCWAN1_0_$Name="forwarding"
			uci set firewall.srcCWAN1_0_$Name.src="$Name"
			uci set firewall.srcCWAN1_0_$Name.dest="CWAN1_0"

			uci set firewall.destCWAN1_0_$Name="forwarding"
			uci set firewall.destCWAN1_0_$Name.src="CWAN1_0"
			uci set firewall.destCWAN1_0_$Name.dest="$Name"

			uci set firewall.srcCWAN1_1_$Name="forwarding"
			uci set firewall.srcCWAN1_1_$Name.src="$Name"
			uci set firewall.srcCWAN1_1_$Name.dest="CWAN1_1"

			uci set firewall.destCWAN1_1_$Name="forwarding"
			uci set firewall.destCWAN1_1_$Name.src="CWAN1_1"
			uci set firewall.destCWAN1_1_$Name.dest="$Name"
         
		 fi

		
		echo uci commit firewall
			
	fi
	
	echo uci commit network
}

rm -rf /var/run/mwan3.lock
#MWAN3 STOP
/etc/init.d/mwan3 stop > /dev/null 2>&1
sleep 5
rm -rf /var/run/mwan3.lock
#Kill MWAN3
pids=$(ps x | grep -i "mwan3" | grep -v grep | awk '{print $1}')
kill -9 $pids

PptpdUCIPath="/etc/config/pptp_i_config"

##Delete pptp_i_config Server###                                             
pptp_name=$(uci get pptpd.pptpd.name)
                                                                  
uci delete pptpd.pptpd                                                                                                     
uci delete pptpd.pptpd_$pptp_name
uci commit pptpd

##Delete PPTP names for Client from the network file.### 
uci="/root/InterfaceManager/script/vpn/pptp/ucidelete.sh"                                                                                                       
chmod 700 /root/InterfaceManager/script/vpn/pptp/ucidelete.sh
#Run the "/root/InterfaceManager/script/vpn/pptp/ucidelete.sh" which deletes the names from the network file.
var=$($uci)       
#Delete the ucidelete.sh and then create a new one for every update button pressed.
rm /root/InterfaceManager/script/vpn/pptp/ucidelete.sh

#PPTP SELECTION CHECK
#Run the script, only if pptp is enabled in general tab.
pptp_status=$(uci get vpnconfig1.general.enablepptpgeneral)
#If pptp isn't selected, then, exit the script.
if [ "$pptp_status" = "0" ]
then
	ip rule del from all lookup main priority 1
	
	ubus call network reload
	
	sleep 1
	
	killall -9 /usr/sbin/pppd > /dev/null 2>&1 &
	
	#fw3 & mwan3 restart in case of delete button pressed/pptp disabled from general page.
	sleep 1
	#Restart firewall
	/sbin/fw3 restart > /dev/null 2>&1

	sleep 1

	#Restart MWAN3
if [ "$mwan3status" = "failover" ] || [ "$mwan3status" = "balanced" ]
then
	/usr/sbin/mwan3 restart > /dev/null 2>&1
	/bin/sleep 2
elif [ "$mwan3status" = "none" ] 
then
    mwan3 stop
fi	
/bin/sleep 2
	rm -rf /var/run/mwan3.lock

	exit 1
fi

#CALLS THE FUNCTION & ECHO VALUE GOES IN UCIDELETE SCRIPT.
#The echo in "pptpdConfigParameters" fn is writen to the /root/InterfaceManager/script/vpn/pptp/ucidelete.sh
ReadpptpdUCIConfig >> /root/InterfaceManager/script/vpn/pptp/ucidelete.sh 

uci commit network 
uci commit firewall 
logger -t config -p customs.info "network configuration changed"
logger -t config -p customs.info "firewall configuration changed"

sleep 1

#Restart firewall
/sbin/fw3 restart > /dev/null 2>&1

sleep 1

#Restart MWAN3
if [ "$mwan3status" = "failover" ] || [ "$mwan3status" = "balanced" ]
then
	/usr/sbin/mwan3 restart > /dev/null 2>&1
	/bin/sleep 2
elif [ "$mwan3status" = "none" ] 
then
    mwan3 stop
fi
rm -rf /var/run/mwan3.lock

sleep 1

#Reload the network for pppd to restart.
ubus call network reload

sleep 1

#Restart pptp init script
/etc/init.d/pptpd restart > /dev/null 2>&1 & 
