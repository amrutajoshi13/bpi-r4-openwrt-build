#!/bin/sh
. /lib/functions.sh

echo "$1"

Hostnm=$(uci get system.system.ipkname)

if [ "$1" = "install" ]
then 
response=$(opkg --force-overwrite install /tmp/*.ipk)
    if [ "$?" -ne 0 ]
	then
	
		echo "{\"code\":1,\"output\":\"FAILURE :${Hostnm} Router Software Install\"}"
		exit 1
	else
			Appver=$(opkg list | grep -i "${Hostnm}_RouterSoftwareEC" | awk '{ print $3 }')
			echo "Appver=$Appver"
		echo "{\"code\":0,\"output\":\"SUCCESS :${Hostnm} Router Software Uninstall\"}"
		
	fi
	exit 0
fi

if [ "$1" = "uninstall" ]
then 
response=$(opkg --force-overwrite install /root/BasicRouterSoftware*.ipk)
sleep 5

    if [ "$?" -ne 0 ]
	then
		echo "{\"code\":1,\"output\":\"FAILURE :${Hostnm} Router Software Uninstall\"}"
		exit 1
	else
		echo "{\"code\":0,\"output\":\"SUCCESS :${Hostnm} Router Software Uninstall\"}"
		exit 0
	fi
fi


	
														 
	
