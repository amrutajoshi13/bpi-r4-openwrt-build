#!/bin/sh

. /lib/functions.sh

ftp_enable=$(uci get importexportconfig.ftpconfig.enableftp)
ftp_time=$(uci get importexportconfig.ftpconfig.time)
ftp_week=$(uci get importexportconfig.ftpconfig.week)
ftp_interval=$(uci get importexportconfig.ftpconfig.interval)


hrs=$(echo "$ftp_time" | cut -d':' -f1)
min=$(echo "$ftp_time" | cut -d':' -f2)        

if [ "$ftp_enable" = "1" ]; then
	sed -i '/Config_upload.sh/d' /etc/crontabs/root
	if [ "$ftp_interval" = "daily" ]; then
		echo "$min $hrs * * * /root/InterfaceManager/script/features/ftp/Config_upload.sh" >>/etc/crontabs/root
	else 
		echo "$min $hrs * * $ftp_week /root/InterfaceManager/script/features/ftp/Config_upload.sh" >>/etc/crontabs/root
	fi
	/etc/init.d/cron restart
	sleep 3
	echo "{\"code\":0,\"output\":\"SUCCESS : FTP Configuration Update\"}"

else
	sed -i '/Config_upload.sh/d' /etc/crontabs/root
	/etc/init.d/cron restart
	sleep 3
	echo "{\"code\":0,\"output\":\"SUCCESS :  FTP Configuration Update\"}"
fi
