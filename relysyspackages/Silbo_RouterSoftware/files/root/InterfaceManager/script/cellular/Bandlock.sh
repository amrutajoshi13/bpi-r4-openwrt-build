#!/bin/sh
. /lib/functions.sh

comport="$1"

#EM06-E has no GSM support, kindly do not enable GSM bands in the web page

echo "******************************Band locking started*****************************************"

#Network Mode selected by the user
Network=$(awk -F"'" '/bandselectenable/ {print $2}' /etc/config/sysconfig)
echo "Uesr Selected Network is \"$Network\""
#Modem selected by the user EC200A,EC25-E or EM06
#Modem=$(awk -F"'" '/model1/ {print $2}' /etc/config/sysconfig)
Modem=$(uci get sysconfig.sysconfig.model1)
i=0
#Selecting Auto bands
if [ "$Network" = "auto" ]; then
#Selecting Auto band in EC200-A
echo "*******************************Band locking Automatic******************************************"
	if [ "$Modem" = "EC200-A" ]; then
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",0 | awk 'NR==2 {print $1}')
			sleep 0
			Auto=$(/bin/at-cmd $comport at+qcfg=\"band\",0,0 | awk 'NR==2 {print $1}')
			sleep 1
			if [ "$Auto" = "OK" ]; then
				sleep 0
				Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' '{print $6}')
				echo "Band latched :"$Bandlatched""
				break
			else
				i=$((i+1))
				echo "Waiting for proper band latching"
			fi
		done
	fi
#Selecting Auto band in EC25-E
	if [ "$Modem" = "EC25-E" ]; then
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",0 | awk 'NR==2 {print $1}')
			sleep 0
			Auto=$(/bin/at-cmd $comport at+qcfg=\"band\",d3,1a0000800d5 | awk 'NR==2 {print $1}')
			sleep 1
			if [ "$Auto" = "OK" ]; then
				sleep 0
				Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
				echo "Band latched :"$Bandlatched""
				break
			else
				i=$((i+1))
				echo "Waiting for proper band latching"
			fi
		done
	fi
#Selecting Auto band in EM06; Specify the proper AT port
	if [ "$Modem" = "EM06-E" ]; then
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",0 | awk 'NR==2 {print $1}')
			sleep 0
			Auto=$(/bin/at-cmd $comport at+qcfg=\"band\",8d0,1a0880800d5 | awk 'NR==2 {print $1}')
			sleep 1
			if [ "$Auto" = "OK" ]; then
				sleep 0
				Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
				echo "Band latched :"$Bandlatched""
				break
			else
				echo $i
				i=$((i+1))
				echo "Waiting for proper band latching"
			fi
		done
	fi

#Selecting Auto band in EM05-G; Specify the proper AT port
	if [ "$Modem" = "EM05-G" ]; then
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",0 | awk 'NR==2 {print $1}')
			sleep 0
			Auto=$(/bin/at-cmd $comport AT+QCFG=\"band\",F,800d5,0,1 | awk 'NR==2 {print $1}')
			sleep 1
			if [ "$Auto" = "OK" ]; then
				sleep 0
				Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
				echo "Band latched :"$Bandlatched""
				break
			else
				echo $i
				i=$((i+1))
				echo "Waiting for proper band latching"
			fi
		done
	fi
	
	#Selecting Auto band in RM500U
	if [ "$Modem" = "RM500U" ]; then
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd /dev/$comport at+qnwprefcfg=\"mode_pref\",AUTO)	
				    
		    if [ "$Networklatch" = "OK" ]; then
					sleep 0
					Bandlatched=$(/bin/at-cmd /dev/$comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
					echo "Band latched :"$Bandlatched""
					break
				else
					echo $i
					i=$((i+1))
					echo "Waiting for proper band latching"
				fi
		done
	fi
fi

#Selecting NR5G:LTE band in RM500U
if [ "$Network" = "5g4g" ]; then
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd /dev/$comport at+qnwprefcfg=\"mode_pref\",NR5G:LTE)	
				    
		    if [ "$Networklatch" = "OK" ]; then
					sleep 0
					Bandlatched=$(/bin/at-cmd /dev/$comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
					echo "Band latched :"$Bandlatched""
					break
				else
					echo $i
					i=$((i+1))
					echo "Waiting for proper band latching"
				fi
		done
fi

#Selecting NR5G bands(RM500U Model)
if [ "$Network" = "5g" ]; then
	
	echo "********************************Band locking NR5G*******************************************"
	Fetching user enabled 5G bands from the sysconfig file
	enabled_5g_bands=$(awk -F"'" '/option nrb*/ {if ($2 == "1") {sub(/^.*nrb/,"nrb",$1); print $1}}' /etc/config/sysconfig)
	Band=0

#For loop is to extract the bands selected by the user from array "enabled_5g_bands"
for band in $enabled_5g_bands; do
        band_num=$(echo $band | sed 's/[^0-9]*//g')

        echo "selected bands $band_num"
done
	sleep 0
	while [[ $i -lt 5 ]]; do
		Networklatch=$(/bin/at-cmd /dev/$comport at+qnwprefcfg=\"mode_pref\",NR5G)
		sleep 0
		Bandlock=$(/bin/at-cmd /dev/$comport at+qnwprefcfg=\"nr5g_band\",$band_num)
		sleep 1
		if [ "$Bandlock" = "OK" ]; then
			sleep 0
			Bandlatched=$(/bin/at-cmd /dev/$comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
			echo "Band latched :"$Bandlatched""
			break
		else
			i=$((i+1))
			echo $i
			echo "Waiting for proper band to latch"
		fi
	done
fi

#Selecting LTE Bands	

if [ "$Network" = "lte" ]; then
	if [ "$Modem" = "RM500U" ]; then	
		echo "********************************Band locking LTE*******************************************"
		#Fetching user enabled LTE bands from the sysconfig file
		enabled_lte_bands=$(awk -F"'" '/option lteb*/ {if ($2 == "1") {sub(/^.*lteb/,"lteb",$1); print $1}}' /etc/config/sysconfig)
		Band=0

		#For loop is to extract the bands selected by the user from array "enabled_lte_bands"
		for band in $enabled_lte_bands; do
			band_num=$(echo $band | sed 's/[^0-9]*//g')
			echo "selected bands $band_num"
		done
		sleep 0
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd /dev/$comport at+qnwprefcfg=\"mode_pref\",LTE)
			sleep 0
			Bandlock=$(/bin/at-cmd /dev/$comport at+qnwprefcfg=\"lte_band\",$band_num)
			sleep 1
			if [ "$Bandlock" = "OK" ]; then
				sleep 0
				Bandlatched=$(/bin/at-cmd /dev/$comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
				echo "Band latched :"$Bandlatched""
				break
			else
				i=$((i+1))
				echo $i
				echo "Waiting for proper band to latch"
			fi
		done
		
	else
	
		echo "********************************Band locking LTE*******************************************"
		#Fetching user enabled LTE bands from the sysconfig file
		enabled_lte_bands=$(awk -F"'" '/option lteb*/ {if ($2 == "1") {sub(/^.*lteb/,"lteb",$1); print $1}}' /etc/config/sysconfig)
		Band=0

		#For loop is to extract the bands selected by the user from array "enabled_lte_bands"
		for band in $enabled_lte_bands; do
			band_num=$(echo $band | sed 's/[^0-9]*//g')
			echo "selected bands $band_num"
			#Finding the band value
			bit_pos=$((band_num - 1))
			band_val=$((2**(bit_pos)))
			hex_val=$(printf '%x\n' $band_val)
			Band=$((Band+hex_val))
		done
		echo "hexadecimal value = $Band"
		sleep 0
		while [[ $i -lt 5 ]]; do
			Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",3 | awk 'NR==2 {print $1}')
			sleep 0
			Bandlock=$(/bin/at-cmd $comport at+qcfg=\"band\",0,$Band | awk 'NR==2 {print $1}')
			sleep 1
			if [ "$Bandlock" = "OK" ]; then
				sleep 0
				Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' 'NR==2 {print $6}')
				echo "Band latched :"$Bandlatched""
				break
			else
				i=$((i+1))
				echo $i
				echo "Waiting for proper band to latch"
			fi
		done
	fi
#Selecting GSM Bands

elif [ "$Network" = "2g" ]; then
	echo "********************************Band locking GSM*******************************************"
	gsm900=00000003 gsm1800=00000002 gsm850=00000004 gsm1900=00000008
	#fetching enabled GSM bands from the sysconfig file
	enabled_gsm_bands=$(awk -F"'" '/option gsm*/ {if ($2 == "1") {sub(/^.*gsm/,"gsm",$1); print $1}}' /etc/config/sysconfig)
	echo "$enabled_gsm_bands"
	Band=0
	#For loop is to extract the bands selected by the user from array "enabled_gsm_bands"
	for band in $enabled_gsm_bands; do
		echo "selected bands $band"
        band_num=$(echo $band)
        Band=$((Band+band_num))
	done
	echo "Total GSM Band values is $Band"
	while [[ $i -lt 5 ]]; do
		Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",1 | awk 'NR==2 {print $1}')
		sleep 0
		Bandlock=$(/bin/at-cmd $comport at+qcfg=\"band\",$Band,0 | awk 'NR==2 {print $1}')
		sleep 1
		if [ "$Bandlock" = "OK" ]; then
			sleep 0
			Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' '{print $6}')
			echo "Band latched :"$Bandlatched""
			break
		else
			i=$((i+1))
			echo "$i"
			echo "Waiting for proper band latching"
		fi
	done
	
#Selecting WCDMA Bands

elif [ "$Network" = "3g" ]; then
	echo "*******************************Band locking WCDMA******************************************"
	wcdma2100=10
	wcdma1900=20
	wcdma850=40
	wcdma900=80
	wcdma800=100
	wcdma1700=200
	wcdma1800=800
	#fetching enabled WCDMA bands from the sysconfig file
	enabled_wcdma_bands=$(awk -F"'" '/option wcdma*/ {if ($2 == "1") {sub(/^.*wcdma/,"wcdma",$1); print $1}}' /etc/config/sysconfig)
	for band in $enabled_wcdma_bands; do
		echo "selected bands $band"
		band_num=$(echo $band)
		Band=$((Band+band_num))
	done
	echo "Total wcdma Band values is $Band"
	while [[ $i -lt 5 ]]; do
		Networklatch=$(/bin/at-cmd $comport at+qcfg=\"nwscanmode\",2 | awk 'NR==2 {print $1}')
		sleep 0
		Band_lock=$(/bin/at-cmd $comport at+qcfg=\"band\",$Band,0 | awk 'NR==2 {print $1}')
		sleep 1
		if [ "$Band_lock" = "OK" ]; then
			sleep 0
			Bandlatched=$(/bin/at-cmd $comport at+qnwinfo | awk -F'"' '{print $6}')
			echo "Band latched :"$Bandlatched""
			break
		else
			i=$((i+1))
			echo "$i"
			echo "Waiting for proper band latching"
		fi
	done
fi
