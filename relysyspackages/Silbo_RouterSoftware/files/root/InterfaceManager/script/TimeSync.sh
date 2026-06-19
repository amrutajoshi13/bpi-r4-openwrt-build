#!/bin/sh

. /lib/functions.sh

/usr/bin/killall -9 ntpclient


WebConfigFile="/etc/config/webserverconfig"
NtpSyncLogfile="/root/ConfigFiles/NTPSyncLog/NtpSyncLog.txt"
LogrotateConfigFile="/etc/logrotate.d/NtpSyncLogrotateConfig"

ReadSystemConfigFile()
{
   	config_load "$WebConfigFile"
   	config_get EnableNtpSync webserverconfig enablentpsync
   	config_get NtpServer webserverconfig ntpserver
   	config_get NtpSyncInterval webserverconfig ntpsyncinterval
}


ReadSystemConfigFile


echo "NtpServer=$NtpServer"

if [ "$EnableNtpSync" = "1" ]
then
syncsucces=0
   #for i in $(seq 0 3)
   for i in $NtpServer
   do
	server=$i       
        ping -c 3 -w 3 $server >/dev/null
		timeout 10 ntpclient -s -h $server 
		if [ $? -eq 0 ]; then
			syncsucces=1
			break
		else
			timeout 10 ntpclient -s -h $server 
			if [ $? -eq 0 ]; then
			syncsucces=1
			break
			fi
		fi
   done

   if [ "$syncsucces" = "1" ]                                                                                         
    then
                                                                                                           
       /sbin/hwclock -w
        date=$(date)
       echo "NTP sync is Successfull.date set is $date" >> "$NtpSyncLogfile"
       logger -t ntpsync -p customs.info "NTP sync is Successfull"
    else
        
       /sbin/hwclock -s      
       date=$(date)                                                                                           
       echo "NTP sync is failed.date set is $date" >> "$NtpSyncLogfile"
       logger -t ntpsync -p custom.info "NTP sync is Failed"
     fi                                                                                                             
fi

logrotate "$LogrotateConfigFile"

exit 0
