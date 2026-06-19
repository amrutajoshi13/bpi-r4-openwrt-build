#!/bin/sh
. /lib/functions.sh
. /root/ConfigFiles/RouterAppConfig/routerappremoteconfig.cfg

#Payload="$1"

RouterPingTestAppScript="/bin/RouterRemotepingTestApp.sh"
Logfile="/root/ConfigFiles/RouterAppConfig/Logs/RemoteAppLogs.txt"
RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"

RestartBoardFile="/root/ConfigFiles/RouterAppConfig/RestartRemoteFile.txt"

LogrotateConfigFile="/etc/logrotate.d/RemoteAppLogrotateConfig"
mkdir -p /root/ConfigFiles/RouterAppConfig/Logs

 [ ! -d  "/tmp/Log" ] && mkdir -p "/tmp/Log"

ModemRestart="/root/usrRPC/script/Recycle_WAN1_PWR_Script.sh"

#maxnoofretries=10
#sleepinterval=1
iretries=0

#HealthRequestinfo=$(echo "$Payload" | awk -F[,] '{ print $1 }')

#if [ "$HealthRequestinfo" = "HealthPeriodicReq" ]
#then

RouterapplicationFile()                                                  
{                                                                        
        config_load "$RouterApplicationconfig"                           
        config_get EnableSecondLevel  routerapplicationRemoteconfig enablesecondlevel
        config_get SecondLevelActionFailure  routerapplicationRemoteconfig  secondlevelactiononfailure
        config_get SecondLevelactionthreshold  routerapplicationRemoteconfig  secondlevelactionthreshold
}                                                                                                      
RouterApplicationconfig="/etc/config/routerapplicationconfig"                                          
                                                                                                       
RouterapplicationFile                                                                                  
                                                                                                       

 

  echo noofretries=$noofretries
    while [ $iretries -le $noofretries ]
	do
        pingtest=$($RouterPingTestAppScript)
        pingres=$(cat /tmp/RouterRemotepingTestApp.txt)

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
                 echo "$now : Remote IP is not responding" >> "$Logfile"
                 echo "$now : Restarting the board" >> "$Logfile"
                                       date=$(date)
				echo "$date:[Remote ping failure]:2" >> "$RebootLogfile"
				echo "$date:[Remote ping failure]:2" > "$RebootreasonLogfile"
                 res=$(/root/usrRPC/script/Board_Recycle_12V_Script.sh)
            elif [ "$failureaction" = "restartipsec" ]
            then
				 now=$(date)
                 echo "$now : Restarting Ipsec" >> "$Logfile"
                logger -t customs.err -p RouterMonitor "Unable to ping to the IP,Restarting the ipsec"
                 res=$(/bin/RouterIPsec.sh)
                 
                 if [ "$EnableSecondLevel" = "1" ]                                                     
                     then 
                     var=$(cat /root/ConfigFiles/RouterAppConfig/RestartRemoteFile.txt)                 
                     let "var++"                                                                     
                     echo "$var" > "$RestartBoardFile"
                     #cat "$RestartBoardFile"  
                                                      
                        if [ "$var" = "$SecondLevelactionthreshold" ]                                  
                        then    
                           now=$(date)                                                                       
                           echo "$now : Ipsec is down" >> "$Logfile"                                            
                           echo "$now : Restarting the Board" >> "$Logfile"             
                           echo 0 > "$RestartBoardFile"  
                           date=$(date)
							echo "$date:[Remote ping failure]:2" >> "$RebootLogfile"
							echo "$date:[Remote ping failure]:2" > "$RebootreasonLogfile"
                           res=$(/root/usrRPC/script/Board_Recycle_12V_Script.sh)                                                                                     
                                                                                      
                         fi                                                           
                  fi    
                 
            elif [ "$failureaction" = "restartmodem" ]
            then
				 now=$(date)
                 echo "$now : WAN is down" >> "$Logfile"
                 echo "$now : Restarting the modem" >> "$Logfile"
                 res=$($ModemRestart) 
   
                     if [ "$EnableSecondLevel" = "1" ]                                                     
                     then 
                     var=$(cat /root/ConfigFiles/RouterAppConfig/RestartRemoteFile.txt)                 
                     let "var++"                                                                     
                     echo "$var" > "$RestartBoardFile"
                     #cat "$RestartBoardFile"  
                                                      
                        if [ "$var" = "$SecondLevelactionthreshold" ]                                  
                        then    
                           now=$(date)                                                                       
                           echo "$now : WAN is down" >> "$Logfile"                                            
                           echo "$now : Restarting the Board" >> "$Logfile"             
                           echo 0 > "$RestartBoardFile"  
                           date=$(date)
							echo "$date:[Remote ping failure]:2" >> "$RebootLogfile"
							echo "$date:[Remote ping failure]:2" > "$RebootreasonLogfile"
                           res=$(/root/usrRPC/script/Board_Recycle_12V_Script.sh)                                                                                     
                                                                                      
                         fi                                                           
                  fi    

fi
fi

		    logrotate "$LogrotateConfigFile"
	        
#fi

exit 0 
