
#!/bin/sh


Monitscript="/usr/bin/monit -I"
TCPRunning="/root/TCPSLAVE/TCP_Slave_Utility_project"
TCPProcess="TCP_Slave_Utility_project"
AppStart="sh -x /etc/init.d/GD44AppManager"
AppRunningStatus=$(uci get applist_config.appconfig.running)
EnableTCP=$(uci get tcpconfig.tcpconfig.enabletcp)

#if [ $AppRunningStatus = 1 ]
#then
   # logger -t "FlowMeterProjectUtilities" "cron run monit"
     PSOutput=$(ps x)
     
    if echo "$PSOutput" | grep -q "$Monitscript"              
    then
		echo "monit daemon already running"
    else
        ${AppStart} stop  
        ${AppStart} start  
        echo "restarting monit daemon process"
    fi
#fi

if [ "$EnableTCP" = 1 ]
then
 PSOutput=$(ps x)
     
    if echo "$PSOutput" | grep -q "$Monitscript"              
    then
    		echo "monit daemon already running"
	else
		/etc/monit start
		cp /Web_Page_Gateway_Apps/Common_GW_Files/monit.d/Monitor_TCP_Slave_Utility_project  /etc/monit.d/Monitor_TCP_Slave_Utility_project
	fi
	
    if echo "$PSOutput" | grep -q "$TCPRunning"              
    then
    		echo "TCPSLAVE already running"
	else
			sh -x /bin/TCP_Monit.sh
	fi
	
	
	else
	
	/usr/bin/killall -9 "$TCPProcess"
	
	mv /etc/monit.d/Monitor_TCP_Slave_Utility_project /Web_Page_Gateway_Apps/Common_GW_Files/monit.d/Monitor_TCP_Slave_Utility_project  
fi
exit 0
