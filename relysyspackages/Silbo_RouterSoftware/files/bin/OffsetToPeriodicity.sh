#!/bin/sh
. /lib/functions.sh

#
# Defaults
#
ConfigFilePath="/etc/config/siaserverconfig"
LogfilePath="/tmp/HealthPeriodicCheck.txt"


ReadConfigurations()
{
    config_load "$ConfigFilePath"
    config_get PERIODIC "siaserverconfig" healthpacketpublishinterval
    config_get enablehealthpacketpublish "siaserverconfig" enablehealthpacketpublish
    
}

ReadConfigurations                     
ReadConfigurationsRetVal=$?            
if [ "$ReadConfigurationsRetVal" != 0 ]                           
then                                                              
    echo "No configuration to Periodic interval" >> "$LogfilePath"
    return 1                                                      
                                                                          
fi
if [ "$enablehealthpacketpublish" =  "1" ]
then	
		current_time=$(date "+%H:%M:%S")
		echo "Started periodicity of $PERIODIC == ""$current_time" >> "$LogfilePath"
		
		CURRENT=$(date "+%M")
		printf $CURRENT
		#CURRENT=59
		#printf "$CURRENT"
		
		sed -i '/HealthPeriodic.sh/d' /etc/crontabs/root
		if [ "$CURRENT" -gt "0" ] && [ "$CURRENT" -lt "$PERIODIC" ]
		then
		 echo "$CURRENT-59/$PERIODIC * * * * /bin/HealthPeriodic.sh" >> /etc/crontabs/root
		elif [ "$CURRENT" -ge "$PERIODIC" ] && [ "$CURRENT" -le "59" ]
		then
			OFFSET=$((CURRENT%PERIODIC))
			echo "$OFFSET-59/$PERIODIC * * * * /bin/HealthPeriodic.sh" >> /etc/crontabs/root
		else
			echo "*/$PERIODIC * * * * /bin/HealthPeriodic.sh" >> /etc/crontabs/root 
		fi
else
	sed -i '/HealthPeriodic.sh/d' /etc/crontabs/root	 
fi
/etc/init.d/cron restart
sleep 2
