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
    config_get periodic "siaserverconfig" healthpacketpublishinterval
    config_get enablehealthpacketpublish "siaserverconfig" enablehealthpacketpublish
    
}

ReadConfigurations                     
ReadConfigurationsRetVal=$?            
if [ "$ReadConfigurationsRetVal" != 0 ]                           
then                                                              
    return 1                                                      
                                                                          
fi

curTme=$(date "+%H:%M:%S")
echo "$curTme"
PeriodicTme=$(date -d@"$(( `date +%s`+$periodic*60))" +%H:%M:%S)
echo "$PeriodicTme"
Hrs=$(echo "$PeriodicTme" | awk -F':' '{ printf("%d\n", $1); }')
Mns=$(echo "$PeriodicTme" | awk -F':' '{ printf("%d\n", $2); }')
printf "$Hrs\n"
printf "$Mns\n"
sed -i '/HealthPeriodic.sh/d' /etc/crontabs/root
echo "$Mns $Hrs * * * /bin/HealthPeriodic.sh" >> /etc/crontabs/root
/etc/init.d/cron restart
sleep 2
echo "Started periodicity of $periodic == ""$curTme" > "$LogfilePath"

exit 0
