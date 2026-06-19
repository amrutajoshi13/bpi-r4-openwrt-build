#!/bin/sh
. /lib/functions.sh
. /root/ConfigFiles/RouterAppConfig/routerapplocalconfig.cfg
date=$(date)
Logfile="/root/ConfigFiles/RouterAppConfig/Logs/RouterAppLogs.txt"
cellularmode=$(uci get modem.cellularmodule.singlesimsinglemodule)
AddIfaceRunningstatus=$(cat /tmp/AddIfaceRunningstatus | cut -d "=" -f2)
if [ "$AddIfaceRunningstatus" = "1" ] 
then 
    if [ "$cellularmode" = "1" ]
    then
		echo "$date : Modem Initializing,executing first sleep 30" >> "$Logfile" 
		sleep 30
	else 
		echo "$date : Modem Initializing,executing first sleep 60" >> "$Logfile" 
		sleep 60
	fi
fi
date=$(date)
AddIfaceRunningstatus=$(cat /tmp/AddIfaceRunningstatus | cut -d "=" -f2)
if [ "$AddIfaceRunningstatus" = "1" ] 
then 
	if [ "$cellularmode" = "1" ]
	then
		echo "$date : Modem Initializing,executing second sleep 30" >> "$Logfile" 
		sleep 30
	else 
		echo "$date : Modem Initializing,executing second sleep 60" >> "$Logfile" 
		sleep 60
	fi
fi

RouterPingTestAppScript="/bin/RouterlocalpingTestApp.sh"


RestartBoardFile="/root/ConfigFiles/RouterAppConfig/RestartlocalFile.txt"
RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"

LogrotateConfigFile="/etc/logrotate.d/RouterAppLogrotateConfig"
mkdir -p /root/ConfigFiles/RouterAppConfig/Logs

[ ! -d  "/tmp/Log" ] && mkdir -p "/tmp/Log"

ModemRestart="/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh"
iretries=0

ReadSystemGpioFile()                               
{                                                    
        config_load "$SystemGpioConfig"              
        config_get Modem1PowerGpio gpio modem1powergpio
        config_get Modem1PowerOnValue gpio modem1poweronvalue
        config_get Modem1PowerOffValue gpio modem1poweroffvalue
}
SystemGpioConfig="/etc/config/systemgpio"


ReadSystemGpioFile

RouterapplicationFile()                                                  
{                                                                        
        config_load "$RouterApplicationconfig"                           
        config_get EnableSecondLevel  routerapplicationlocalconfig  enablesecondlevel
        config_get SecondLevelActionFailure  routerapplicationlocalconfig  secondlevelactiononfailure
        config_get SecondLevelactionthreshold  routerapplicationlocalconfig  secondlevelactionthreshold
}                                                                                                      
RouterApplicationconfig="/etc/config/routerapplicationconfig"                                          
                                                                                                       
RouterapplicationFile                                                                                  
                                                                                                       
	echo noofretries=$noofretries
    while [ $iretries -le $noofretries ]
	do
        pingtest=$($RouterPingTestAppScript)
        pingres=$(cat /tmp/RouterlocalpingTestApp.txt)

		if [ "$pingres" = "0" ]
		then
			now=$(date)
			echo "$now : WAN is up" >> "$Logfile"
			if [ "$EnableSecondLevel" = "1" ]                                                       
			then             
				echo 0 > "$RestartBoardFile"
			fi  
			break
        else
            sleep $sleepinterval          
		fi
            iretries=$(( $iretries + 1 ))
    done 
        
		if [ "$pingres" = "2" ]
		then        
            if [ "$failureaction" = "restart" ] 
            then 
				now=$(date)
				echo "$now : WAN is down" >> "$Logfile"
				echo "$now : Restarting the board" >> "$Logfile"
				date=$(date)
				echo "$date:[Cellular Internet failure]:2" >> "$RebootLogfile"
				echo "$date:[Cellular Internet failure]:2" > "$RebootreasonLogfile"
				res=$(/root/usrRPC/script/Board_Recycle_12V_Script.sh)
            elif [ "$failureaction" = "restartipsec" ]
            then
				now=$(date)
				echo "$now : WAN is down" >> "$Logfile"
				echo "$now : Restarting the board" >> "$Logfile"
				res=$(/bin/RouterIPsec.sh)   
            elif [ "$failureaction" = "restartmodem" ]
            then
				now=$(date)
				echo "$now : WAN is down" >> "$Logfile"
				echo "$now : Restarting the modem" >> "$Logfile"
				logger -t customs.err -p ModemMonitor "Wan is down,Restarting the modem"
				if [ "$EnableSecondLevel" = "1" ]                                                     
				then                                                                                
					var=$(cat /root/ConfigFiles/RouterAppConfig/RestartlocalFile.txt)                 
					let "var++"                                                                     
					echo "$var" > "$RestartBoardFile"                                                 
					if [ "$var" = "$SecondLevelactionthreshold" ]                                  
					then
						now=$(date)                                                                           
						echo "$now : WAN is down" >> "$Logfile"                                               
						echo "$now : Restarting the Board" >> "$Logfile"                                                                            
						echo 0 > "$RestartBoardFile"  
						date=$(date)
						echo "$date:[Cellular Internet failure]:2" >> "$RebootLogfile"
						echo "$date:[Cellular Internet failure]:2" > "$RebootreasonLogfile"
						res=$(/root/usrRPC/script/Board_Recycle_12V_Script.sh)               																  
					fi                                                           
				fi   
				echo "$Modem1PowerOffValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
				sleep 5
				echo "$Modem1PowerOnValue" > /sys/class/gpio/gpio$Modem1PowerGpio/value
			fi
		fi
		logrotate "$LogrotateConfigFile"
exit 0 
