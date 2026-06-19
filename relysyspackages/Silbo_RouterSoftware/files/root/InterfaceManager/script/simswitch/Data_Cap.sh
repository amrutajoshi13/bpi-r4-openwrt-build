#!/bin/sh

. /lib/functions.sh

EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
#Cheching if Cellular is disabled.
if [ "$EnableCellular" = "0" ]
then
	exit 0
fi

Simswitch=$(uci get simswitchconfig.simswitchconfig.simswitch)
#Checking if simswitch is selected as none
if [ "$Simswitch" = "none" ]
then
	exit 0
fi

#Sysconfig Configurations
Cellular_Mode=$(uci get sysconfig.sysconfig.CellularOperationMode)

#Simswitchconfig Configurations
Sim1DataLimit=$(uci get simswitchconfig.simswitchconfig.sim1datausagelimit)

#Threshold value
Data_Storage_Threshold=1

SimNumFile="/tmp/simnumfile"
Sim1DataFile="/etc/sim1data"
TmpSim1DataFile="/tmp/sim1data"
Sim2DataFile="/etc/sim2data"
TmpSim2DataFile="/tmp/sim2data"

#Getting the current date
current_date=$(date +%Y-%m-%d)

Periodicity=$(uci get simswitchconfig.simswitchconfig.cellulardatausagemanagerperiodicity)

ResetFlagFileSim1="/root/InterfaceManager/script/simswitch/Sim1DataCap.txt"
ResetFlagFileSim2="/root/InterfaceManager/script/simswitch/Sim2DataCap.txt"

################### Date Reset Logic ################################

ResetDataForSIM1()
{	
	#Getting the current date
	current_date=$(date +%Y-%m-%d)
	#Converting the current date into epoch time(in seconds).
	currentdate_epoch=$(date -d "$current_date" +%s)
	echo "$currentdate_epoch"
	
	#Getting the date from the /etc/sim1data file
	stored_data=$(cat "$Sim1DataFile" | cut -d "," -f 2)
	#Converting the stored date into epoch time(in seconds).
	storeddate_epoch=$(date -d "$stored_data" +%s)
	echo "$storeddate_epoch"

	#Extract year and month from that date
	year=$(date -d "$stored_data" +%Y)
	month=$(date -d "$stored_data" +%m)
	
	#Getting the dayofmonth value from webpage.
	dayofmonth=$(uci get simswitchconfig.simswitchconfig.dayofmonth)
	#dayofmonth value will be in this format(1,2 etc).Converting that in this format YYYY-MM-DD.
	user_date="${year}-${month}-$(printf '%02d' $dayofmonth)"
	echo "$user_date"
	#Converting the user date into epoch time(in seconds).
	userdate_epoch=$(date -d "$user_date" +%s)
		
	#Checking if the simswitch periodicity is selected as daily.	
	if [ "$Periodicity" = "daily" ]
	then
		#Checking if the date stored in sim1datafile is not same to the current date. 
		if [ "$storeddate_epoch" -ne "$currentdate_epoch" ]
		then 	
			#Resetting the temp file.
			if [ -f "$TmpSim1DataFile" ]                                            
			then              
				echo "0" > "$TmpSim1DataFile"                                         
			fi
			
			#Resetting the temp file.
			if [ -f "$Sim1DataFile" ]                                            
			then              
				echo "0,$current_date" > "$Sim1DataFile"                                         
			fi
		fi
	#Checking if the simswitch periodicity is selected as monthly. 		
	elif [ "$Periodicity" = "monthly" ]
	then
		flag=`cat "$ResetFlagFileSim1"` 
		#Checking if the date given from the user in GUI to switch is same as the current date. 
		#If yes then it will reset the tmp file, etc file.
		if [ "$userdate_epoch" -eq "$currentdate_epoch" ]
		then
			if [ "$flag" = "0" ]
			then
				#Resetting the temp file.
				if [ -f "$TmpSim1DataFile" ]                                            
				then              
					echo "0" > "$TmpSim1DataFile"                                         
				fi
			
				#Resetting the flash file.
				if [ -f "$Sim1DataFile" ]                                            
				then              
					echo "0,$current_date" > "$Sim1DataFile"                                         
				fi
				echo "1" > "$ResetFlagFileSim1"
			fi
		else
			if [ "$flag" = "1" ]
			then	
				echo "0" > "$ResetFlagFileSim1"
			fi
		fi	
	fi
}

ResetDataForSIM2()
{	
	current_date=$(date +%Y-%m-%d)
	#In sec.
	currentdate_epoch=$(date -d "$current_date" +%s)
	echo "$currentdate_epoch"

	stored_data=$(cat "$Sim2DataFile" | cut -d "," -f 2)
	#In sec.
	storeddate_epoch=$(date -d "$stored_data" +%s)
	echo "$storeddate_epoch"

	# Extract year and month from that date
	year=$(date -d "$stored_data" +%Y)
	month=$(date -d "$stored_data" +%m)
	
	#Getting the dayofmonth value from webpage.
	dayofmonth=$(uci get simswitchconfig.simswitchconfig.dayofmonth)
	#dayofmonth value will be in this format(1,2 etc).Converting that in this format YYYY-MM-DD.
	user_date="${year}-${month}-$(printf '%02d' $dayofmonth)"
	echo "$user_date"
	#Converting the user date into epoch time(in seconds).
	userdate_epoch=$(date -d "$user_date" +%s)
	
	#Checking if the date in the etc is file is not same as the current date.
	
	if [ "$Periodicity" = "daily" ]
	then
		if [ "$storeddate_epoch" -ne "$currentdate_epoch" ]
		then 	
			#Resetting the temp file.
			if [ -f "$TmpSim2DataFile" ]                                            
			then              
				echo "0" > "$TmpSim2DataFile"                                         
			fi
			
			#Resetting the temp file.
			if [ -f "$Sim2DataFile" ]                                            
			then              
				echo "0,$current_date" > "$Sim2DataFile"                                         
			fi
		
			/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
			sleep 10

			[ ! -f /tmp/InterfaceStatus/CWAN1_1Status ] && touch /tmp/InterfaceStatus/CWAN1_1Status                                  
			echo "`date` Interface CWAN1_1 DOWN" >> /tmp/InterfaceStatus/CWAN1_1Status  
			echo "Sim Switch"		
			
		fi	
	elif [ "$Periodicity" = "monthly" ]
	then
		flag=`cat "$ResetFlagFileSim2"` 
	
		if [ "$userdate_epoch" -eq "$currentdate_epoch" ]
		then
			if [ "$flag" = "0" ]
			then
				#Resetting the temp file.
				if [ -f "$TmpSim2DataFile" ]                                            
				then              
					echo "0" > "$TmpSim2DataFile"                                         
				fi
			
				#Resetting the flash file.
				if [ -f "$Sim2DataFile" ]                                    
				then              
					echo "0,$current_date" > "$Sim2DataFile"                                         
				fi
				echo "1" > "$ResetFlagFileSim2"
				
				/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
				sleep 10

				[ ! -f /tmp/InterfaceStatus/CWAN1_1Status ] && touch /tmp/InterfaceStatus/CWAN1_1Status                                  
				echo "`date` Interface CWAN1_1 DOWN" >> /tmp/InterfaceStatus/CWAN1_1Status  
				echo "Sim Switch"		
			fi
		else
			if [ "$flag" = "1" ]
			then	
				echo "0" > "$ResetFlagFileSim2"
			fi
		fi	
	fi
}
################### Date Reset Logic ################################

#Checking for cellular mode.
if [ "${Cellular_Mode}" = "singlecellulardualsim" ]
then
	sim=`cat "$SimNumFile"`
	#Checking which sim is active.
	if [ "$sim" = "1" ]
	then
		if [ ! -f "$TmpSim1DataFile" ]
		then
			touch "$TmpSim1DataFile"
			echo "0" > "$TmpSim1DataFile"
		fi
		if [ ! -f "$Sim1DataFile" ]
		then
			touch "$Sim1DataFile"
			current_date=$(date +%Y-%m-%d)
			echo "0,$current_date" > "$Sim1DataFile"
		fi
		
		#Getting ifname, whether the protocol is cdc ether(usb0) or qmi(wwan0) for CWAN1_0.
		ifname=$(uci get modem.CWAN1_0.interfacename)
		
		#Get the data.
		tx_data=$(cat /sys/class/net/$ifname/statistics/tx_bytes)
		rx_data=$(cat /sys/class/net/$ifname/statistics/rx_bytes)
		#summing tx and rx.
		sum=`expr $tx_data + $rx_data`
		#Converting total sum to Megabytes.
		data_used=$(($sum / 1048576))
		tmp_data_used=`cat "$TmpSim1DataFile"`
		data_difference=`expr $data_used - $tmp_data_used`
		
		#Checking if the data_difference1 value is a negative number, 
		#Then take the total data from ifconfig and add it to the respective values in tmp that is data_difference. 
		if [ $data_difference1 -lt 0 ]
		then
			data_difference="$data_used"
		fi
		
		#Checking if the data_difference value is greater than the threshold value.
		#Note (for negative data_difference1 values): The new value obtained in the data_difference from the 
		#above "if" loop, which is now positive, enters the below "if" loop as well. 
		if [ $data_difference -ge $Data_Storage_Threshold ]
		then
			#Writing the newly added value to tmp file.
			echo "$data_used" > "$TmpSim1DataFile"
			#Reading the previous sum from flash file (etc).
			raw_data_used=`cat "$Sim1DataFile"`
			flash_data_used=$(echo "$raw_data_used" | cut -d "," -f 1)
			stored_data=$(echo "$raw_data_used" | cut -d "," -f 2)
			#Adding the difference value to the previous sum (etc+tmp values).
			new_flash_data=`expr $flash_data_used + $data_difference`
			#Writing sum value to flash (etc).
			#echo "${new_flash_data},$stored_data" > "$Sim1DataFile"
			printf "%d,%s" "$new_flash_data" "$stored_data" > "$Sim1DataFile"
		fi
		#Checking if the total data from /etc/sim1data file is greater/equal to the Sim1DataLimit value. 
		if [ $new_flash_data -ge $Sim1DataLimit ]
		then
			#If it is greater, then sim switch script is called.
			/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
			[ ! -f /tmp/InterfaceStatus/CWAN1_0Status ] && touch /tmp/InterfaceStatus/CWAN1_0Status                                  
			 echo "`date` Interface CWAN1_0 DOWN" >> /tmp/InterfaceStatus/CWAN1_0Status  
			 echo "Sim Switch"
		fi
	#If Sim2 is active, same steps as sim1 is followed.
	else		 
		if [ ! -f "$TmpSim2DataFile" ]
		then
			touch "$TmpSim2DataFile"
			echo "0" > "$TmpSim2DataFile"
		fi
		if [ ! -f "$Sim2DataFile" ]
		then
			touch "$Sim2DataFile"
			current_date=$(date +%Y-%m-%d)
			echo "0,$current_date" > "$Sim2DataFile"
		fi
		
		#Getting ifname, whether the protocol is cdc ether(usb0) or qmi(wwan0) for CWAN1_1.
		ifname=$(uci get modem.CWAN1_1.interfacename)

		#Get the data.
		tx_data=$(cat /sys/class/net/$ifname/statistics/tx_bytes)
		rx_data=$(cat /sys/class/net/$ifname/statistics/rx_bytes)
		#summing tx and rx.
		sum=`expr $tx_data + $rx_data`
		#Converting total sum to Megabytes.
		data_used=$(($sum / 1048576))
		tmp_data_used=`cat "$TmpSim2DataFile"`
		data_difference=`expr $data_used - $tmp_data_used`
		
		#Checking if the data_difference1 value is a negative number, 
		#Then take the total data from ifconfig and add it to the respective values in tmp that is data_difference. 
		if [ $data_difference1 -lt 0 ]
		then
			data_difference="$data_used"
		fi
		
		#Checking if the data_difference value is greater than the threshold value.
		#Note (for negative data_difference1 values): The new value obtained in the data_difference from the 
		#above "if" loop, which is now positive, enters the below "if" loop as well. 
		if [ $data_difference -ge $Data_Storage_Threshold ]
		then
			#Writing the newly added value to tmp file.
			echo "$data_used" > "$TmpSim2DataFile"
			#Reading the previous sum from flash file (etc).
			raw_data_used=`cat "$Sim2DataFile"`
			flash_data_used=$(echo "$raw_data_used" | cut -d "," -f 1)
			stored_data=$(echo "$raw_data_used" | cut -d "," -f 2)
			#Adding the difference value to the previous sum (etc+tmp values).
			new_flash_data=`expr $flash_data_used + $data_difference`
			#Writing sum value to flash (etc).
			#echo "${new_flash_data},$stored_data" > "$Sim2DataFile"
			printf "%d,%s" "$new_flash_data" "$stored_data" > "$Sim2DataFile"
		fi
		#Checking if the total data from /etc/sim1data file is greater/equal to the Sim2DataLimit value. 
		
	fi	
fi

ResetDataForSIM1
ResetDataForSIM2
