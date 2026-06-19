#!/bin/sh

. /lib/functions.sh

ComPortSymLink="$1"
InterfaceName="$2"
qnetdevctl="$3"

if [ "$qnetdevctl" = "qnetdevctl1" ]
then
	qnetdevctl1_value=$(cat /tmp/qnetdevctl1)
	
	if [ "$qnetdevctl1_value" = "1" ]
	then
		exit 0
	fi
fi

if [ "$qnetdevctl" = "qnetdevctl2" ]
then
	qnetdevctl2_value=$(cat /tmp/qnetdevctl2)
	
	if [ "$qnetdevctl2_value" = "1" ]
	then
		exit 0
	fi
fi
	
#if [ "$InterfaceName" = "CWAN2" ]
#then
	#Logfile1="/root/ConfigFiles/Logs/all_logs_mod2.txt"
#else
	#Logfile1="/root/ConfigFiles/Logs/all_logs_mod1.txt"
#fi

#LogrotateConfigFile1="/etc/logrotate.d/alllogsmod1"
#LogrotateConfigFile2="/etc/logrotate.d/alllogsmod2"

#Logfile1="/tmp/all_logs_mod1.txt"

sleep 120

Qnetdevctl_status()
{
	ComPortSymLink=$1
	AltComPortSymLink=$2
	
	Status_ok=$(/bin/at-cmd "$ComPortSymLink" AT+QNETDEVCTL=1,1,1 | awk NR==2 | tr -d '\011\012\013\014\015\040')

	#If response is ok; then break.
	if [ "$Status_ok" = "OK" ]
	then
		echo "<qnetdevctl.sh> AT+QNETDEVCTL=$Status_ok" >> $Logfile1
		break 
	#If no response, then try again 3 times
	else
		sleep 2
		echo "<qnetdevctl.sh> AT+QNETDEVCTL=$Status_ok" >> $Logfile1
		
		for i in 1 2 3                                                                                                                   
		do
			Status=$(/bin/at-cmd "$ComPortSymLink" AT+QNETDEVCTL=1,1,1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
			
			if [ "$Status" = "OK" ]
			then
				echo "<qnetdevctl.sh> AT+QNETDEVCTL=$Status" >> $Logfile1
				
				#Set got_ok as 1, if received ok as response. So as not to switch to alt comport port.
				got_ok=1
				break 
			else
				sleep 2
				echo "<qnetdevctl.sh> AT+QNETDEVCTL=$Status" >> $Logfile1
			fi
		done
		
		if [ "$got_ok" = "1" ]
		then
			break
		
		#If no response on comport, then switch to alt comport.
		else
			echo "<qnetdevctl.sh> No response on AT+QNETDEVCTL; switching to alternate comport" >> $Logfile1
			
			for i in 1 2 3                                                                                                                   
			do
				Status_alt=$(/bin/at-cmd "$AltComPortSymLink" AT+QNETDEVCTL=1,1,1 | awk NR==2 | tr -d '\011\012\013\014\015\040')
				
				if [ "$Status_alt" = "OK" ]
				then
					echo "<qnetdevctl.sh> AT+QNETDEVCTL=$Status_alt for AltComPort" >> $Logfile1
					break 
				else
					sleep 2
					echo "<qnetdevctl.sh> AT+QNETDEVCTL=$Status_alt for AltComPort" >> $Logfile1
				fi
			done
		fi
	fi
}


if [ "$InterfaceName" = "CWAN1_0" ]
then
	pdp=$(uci get sysconfig.sysconfig.pdp)
elif [ "$InterfaceName" = "CWAN1_1" ]
then
	pdp=$(uci get sysconfig.sysconfig.sim2pdp)
fi
ifname=usb0
operstate=$(cat /sys/class/net/${ifname}/operstate)

#Get AltComPortSymLink for qnetdevctl.
AltComPortSymLink=$(uci get modem.$InterfaceName.AltComPortSymLink)
	
echo "<qnetdevctl.sh> $ifname is $operstate." >> $Logfile1

if [ "$InterfaceName" = "CWAN1_0" ] || [ "$InterfaceName" = "CWAN1" ]
then
	IPV6InterfaceName="wan6c1"
elif [ "$InterfaceName" = "CWAN1_1" ] || [ "$InterfaceName" = "CWAN2" ]
then
	IPV6InterfaceName="wan6c2"
fi

if [ "$pdp" = "IPV4" ] 				
then
	
	echo "<qnetdevctl.sh> Since, pdp is $pdp, Checking for ipv4 addr." >> $Logfile1
	
	ipv4=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
	
	if [ -z "$ipv4" ]
	then
		Qnetdevctl_status $ComPortSymLink $AltComPortSymLink
		
		echo "<qnetdevctl.sh> Waiting 60s to check for IP address." >> $Logfile1
		
		sleep 60
		
		check_ipv4=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
		
		if [ -z "$check_ipv4" ]
		then
			echo "<qnetdevctl.sh> No IP address on $InterfaceName, Hence, rebooting." >> $Logfile1
			
			if [ "$InterfaceName" = "CWAN2" ]
			then
				/root/usrRPC/script/Recycle_WAN2_PWR_Script.sh $ComPortSymLink & 
			else
				/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh $ComPortSymLink &
			fi
		else
			echo "<qnetdevctl.sh>1) The ipv4 addr is present. Hence, do nothing." >> $Logfile1
			echo "<qnetdevctl.sh>1) Triggering mwan3 ifup $InterfaceName & $IPV6InterfaceName." >> $Logfile1
			
			sleep 1
			mwan3 ifup "$InterfaceName" > /dev/null 2>&1
			sleep 1
			mwan3 ifup "$IPV6InterfaceName" > /dev/null 2>&1
		fi
		
	else
		echo "<qnetdevctl.sh>2) The ipv4 addr is present. Hence, do nothing." >> $Logfile1
		echo "<qnetdevctl.sh>2) Triggering mwan3 ifup $InterfaceName & $IPV6InterfaceName." >> $Logfile1
		sleep 1
		mwan3 ifup "$InterfaceName" > /dev/null 2>&1
		sleep 1
		mwan3 ifup "$IPV6InterfaceName" > /dev/null 2>&1
	fi
	
elif [ "$pdp" = "IPV6" ]
then
	
	echo "<qnetdevctl.sh> Since, pdp is $pdp, Checking for ipv6 addr." >> $Logfile1
	
	ipv6=$(ifconfig "$ifname" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
	
	if [ -z "$ipv6" ]
	then
		Qnetdevctl_status $ComPortSymLink $AltComPortSymLink
		
		echo "<qnetdevctl.sh> Waiting 60s to check for IP address." >> $Logfile1
		
		sleep 60
		
		check_ipv6=$(ifconfig "$ifname" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
		
		if [ -z "$check_ipv6" ]
		then
			echo "<qnetdevctl.sh> No IP address on $InterfaceName, Hence, rebooting." >> $Logfile1
			
			if [ "$InterfaceName" = "CWAN2" ]
			then
				/root/usrRPC/script/Recycle_WAN2_PWR_Script.sh $ComPortSymLink & 
			else
				/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh $ComPortSymLink &
			fi
		else
			echo "<qnetdevctl.sh>1) The ipv6 addr is present. Hence, do nothing." >> $Logfile1
			echo "<qnetdevctl.sh>1) Triggering mwan3 ifup $InterfaceName & $IPV6InterfaceName." >> $Logfile1
			sleep 1
			mwan3 ifup "$InterfaceName" > /dev/null 2>&1
			sleep 1
			mwan3 ifup "$IPV6InterfaceName" > /dev/null 2>&1
		fi
	else
		echo "<qnetdevctl.sh>2) The ipv6 addr is present. Hence, do nothing." >> $Logfile1
		echo "<qnetdevctl.sh>2) Triggering mwan3 ifup $InterfaceName & $IPV6InterfaceName." >> $Logfile1
		sleep 1
		mwan3 ifup "$InterfaceName" > /dev/null 2>&1
		sleep 1
		mwan3 ifup "$IPV6InterfaceName" > /dev/null 2>&1
	fi
	
elif [ "$pdp" = "IPV4V6" ] 
then
	
	echo "<qnetdevctl.sh> Since, pdp is $pdp, Checking for ipv4 & ipv6 addr." >> $Logfile1
	
	ipv4=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
	ipv6=$(ifconfig "$ifname" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
	
	if [ -z "$ipv4" ] || [ -z "$ipv6" ]
	then
		Qnetdevctl_status $ComPortSymLink $AltComPortSymLink
		
		echo "<qnetdevctl.sh> Waiting 60s to check for IP address." >> $Logfile1
		
		sleep 60
		
		check_ipv4=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
		check_ipv6=$(ifconfig "$ifname" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
		
		if [ -z "$check_ipv4" ] || [ -z "$check_ipv6" ]
		then
			echo "<qnetdevctl.sh> No IP address on $InterfaceName, Hence, rebooting." >> $Logfile1
			
			if [ "$InterfaceName" = "CWAN2" ]
			then
				/root/usrRPC/script/Recycle_WAN2_PWR_Script.sh $ComPortSymLink & 
			else
				/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh $ComPortSymLink &
			fi
		else
			echo "<qnetdevctl.sh>1) The ipv4 & ipv6 addr are present. Hence, do nothing." >> $Logfile1
			echo "<qnetdevctl.sh>1) Triggering mwan3 ifup $InterfaceName & $IPV6InterfaceName." >> $Logfile1
			sleep 1
			mwan3 ifup "$InterfaceName" > /dev/null 2>&1
			sleep 1
			mwan3 ifup "$IPV6InterfaceName" > /dev/null 2>&1
		fi
		
	else
		echo "<qnetdevctl.sh> The ipv4 & ipv6 addr are present. Hence, do nothing." >> $Logfile1
		echo "<qnetdevctl.sh>2) Triggering mwan3 ifup $InterfaceName & $IPV6InterfaceName." >> $Logfile1
		sleep 1
		mwan3 ifup "$InterfaceName" > /dev/null 2>&1
		sleep 1
		mwan3 ifup "$IPV6InterfaceName" > /dev/null 2>&1
	fi
fi

logrotate "$LogrotateConfigFile1"
logrotate "$LogrotateConfigFile2"
exit 0
