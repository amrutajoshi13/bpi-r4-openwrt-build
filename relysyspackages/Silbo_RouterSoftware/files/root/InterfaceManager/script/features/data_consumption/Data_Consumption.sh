#!/bin/sh

. /lib/functions.sh

EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
Cellular_Mode=$(uci get sysconfig.sysconfig.CellularOperationMode)

Data_Storage_Threshold=1

SimNumFile="/tmp/simnumfile"
Sim1DataFile="/etc/sim1datausage"
TmpSim1DataFile="/tmp/sim1datausage"
Sim2DataFile="/etc/sim2datausage"
TmpSim2DataFile="/tmp/sim2datausage"
Dailydatasusagesim1="/etc/dailyusagesim1data"
Dailydatasusagesim2="/etc/dailyusagesim2data"

cwan1sim1modemenable=$(uci get modem.CWAN1_0.modemenable)
cwan1sim2modemenable=$(uci get modem.CWAN1_1.modemenable)

current_date=$(date +%Y-%m-%d)

#To remove 2 years older files of Data Consumption
current_year=$(echo "$current_date" | cut -d'-' -f1)
result=$((current_year - 2))
datausagefile_to_be_deleted_Sim1="${Dailydatasusagesim1}_${result}"
datausagefile_to_be_deleted_Sim2="${Dailydatasusagesim2}_${result}"

#rm -f "$datausagefile_to_be_deleted_Sim"
rm -f "$datausagefile_to_be_deleted_Sim1"
rm -f "$datausagefile_to_be_deleted_Sim2"
 
 
DailyDataUsageForSIM1()
{
	
	current_date=$(date +%Y-%m-%d)
	#In sec.
	currentdate=$(date -d "$current_date" +%s)
	echo "$currentdate"

	present_date=$(cat "$Sim1DataFile" | cut -d "," -f 4)
	#In sec.
	presentdate=$(date -d "$present_date" +%s)
	echo "$presentdate"

	#Checking if the date in the etc is file is not same as the current date.
	if [ "$presentdate" -ne "$currentdate" ]
	then 
		#Resetting the temp file.
		if [ -f "$TmpSim1DataFile" ]                                            
		then              
			echo "0,0,0 " > "$TmpSim1DataFile"                                         
		fi
		
		#Before resetting the flash file, copying the tx,rx,sum and date value in /etc/dailyusagesim1data	   
		if [ -f "$Sim1DataFile" ]                                            
		then
			# Extract the 4th field from the file - date
			fourth_field=$(awk -F "," '{print $4}' "$Sim1DataFile")
			year=$(echo "$fourth_field" | cut -d'-' -f1)
			month=$(echo "$fourth_field" | cut -d'-' -f2)
			
			flash_data_used=`cat "$Sim1DataFile"`  
			tx1=$(echo "$flash_data_used" | cut -d "," -f 1)
			rx1=$(echo "$flash_data_used" | cut -d "," -f 2)
			sum1=$(echo "$flash_data_used" | cut -d "," -f 3)
			cur_date1=$(echo "$flash_data_used" | cut -d "," -f 4)
			echo "Upload=$tx1 MB  Download=$rx1 MB  Total=$sum1 MB  Date=$cur_date1" >> "${Dailydatasusagesim1}_${year}"                      
			echo "0,0,0,$current_date" > "$Sim1DataFile"  
			echo "0,0,0 " > "$TmpSim1DataFile"
			/root/InterfaceManager/script/features/data_consumption/Msent_Mreceived_Data.sh $month $year   						                                     
		fi  
   fi	  
}


DailyDataUsageForSIM2()
{
	
	current_date=$(date +%Y-%m-%d)
	#In sec.
	currentdate=$(date -d "$current_date" +%s)
	echo "$currentdate"

	present_date=$(cat "$Sim2DataFile" | cut -d "," -f 4)
	#In sec.
	presentdate=$(date -d "$present_date" +%s)
	echo "$presentdate"
	
	#Checking if the date in the etc is file is not same as the current date.
	if [ "$presentdate" -ne "$currentdate" ]
	then 
		#Resetting the temp file.
		if [ -f "$TmpSim2DataFile" ]                                            
		then              
			echo "0,0,0 " > "$TmpSim2DataFile"                                         
		fi
         
        #Before resetting the flash file, copying the tx,rx,sumand date value in /etc/dailyusagesim1data           
		if [ -f "$Sim2DataFile" ]                                            
		then      
			# Extract the 4th field from the file
			fourth_field=$(awk -F "," '{print $4}' "$Sim2DataFile")
			year=$(echo "$fourth_field" | cut -d'-' -f1)
			month=$(echo "$fourth_field" | cut -d'-' -f2)
		
			flash_data_used=`cat "$Sim2DataFile"`  
			tx2=$(echo "$flash_data_used" | cut -d "," -f 1)
			rx2=$(echo "$flash_data_used" | cut -d "," -f 2)
			sum2=$(echo "$flash_data_used" | cut -d "," -f 3)
			cur_date2=$(echo "$flash_data_used" | cut -d "," -f 4)
			echo "Upload=$tx2 MB  Download=$rx2 MB  Total=$sum2 MB  Date=$cur_date2" >> "${Dailydatasusagesim2}_${year}"                      
			echo "0,0,0,$current_date" > "$Sim2DataFile"
			echo "0,0,0 " > "$TmpSim2DataFile"
			/root/InterfaceManager/script/features/data_consumption/Msent_Mreceived_Data.sh $month $year     						    
		fi    
	fi	
}

SimDataUsage() {
    ifname="$1"
    tmp_file="$2"
    flash_file="$3"

    # Initial tmp file
    if [ ! -f "$tmp_file" ]
    then
        touch "$tmp_file"
        echo "0,0,0" > "$tmp_file"
    fi

    # Initial flash file
    if [ ! -f "$flash_file" ]
    then
        touch "$flash_file"
        current_date=$(date +%Y-%m-%d)
        echo "0,0,0,$current_date" > "$flash_file"
    fi
	
	#Get the data.
    tx_data=$(cat /sys/class/net/$ifname/statistics/tx_bytes)
    rx_data=$(cat /sys/class/net/$ifname/statistics/rx_bytes)
    
	#Convert the data into Megabytes.
    tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
    rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
    data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
	
	#Read the previous data in the tmp file.
    tmp_data_used=$(cat "$tmp_file")
    tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
    rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
    total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)
	#Check the difference. 
    tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
    rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
    data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
    
    #Converting data_difference(floating point) value to decimal.
    data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")

	#Checking if the data_difference1 value is a negative number, 
	#Then take the tx,rx and total data from ifconfig and add it to the respective values in tmp. 
	#That is, tx_difference,rx_difference,data_difference.
    if [ $data_difference1 -lt 0 ]
    then
        tx_difference="$tx_in_megabytes"
        rx_difference="$rx_in_megabytes"
        data_difference="$data_used"
        data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
    fi

	#Checking if the data_difference1 value is greater than the threshold value.
	#Note (for negative data_difference1 values): The new value obtained in the data_difference1 from the 
	#above "if" loop, which is now positive, enters the below "if" loop as well. 
    if [ $data_difference1 -ge $Data_Storage_Threshold ]
    then
		#Writing the newly added values to tmp file.
        printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$tmp_file"

		#Reading the previous tx ,rx and sum from flash file (etc).
        flash_data_used=$(cat "$flash_file")
        tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
        rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
        total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
        present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
		
		#Adding the difference value to the previous tx,rx and sum (etc+tmp values).
        new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}")
        new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")
        new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
		#Writing tx,rx,sum and date to flash (etc).
        printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date" > "$flash_file"
    fi
}

#Checking for cellular mode.
#Dualcellularsinglesim.
if [ "$Cellular_Mode" = "dualcellularsinglesim" ] || [ "$Cellular_Mode" = "singlecellularsinglesim" ]; then
	
	#Getting ifname, whether the protocol is cdc ether(usb0) or qmi(wwan0) for modem1.
    if [ "$(uci get modem.CWAN1.modemenable)" = "1" ]; then
        ifname1=$(uci get modem.CWAN1.interfacename)
        SimDataUsage "$ifname1" "$TmpSim1DataFile" "$Sim1DataFile"
    fi
    
	#Getting ifname, whether the protocol is cdc ether(usb0) or qmi(wwan0) for modem2.
    if [ "$(uci get modem.CWAN2.modemenable)" = "1" ]; then
        ifname2=$(uci get modem.CWAN2.interfacename)
        SimDataUsage "$ifname2" "$TmpSim2DataFile" "$Sim2DataFile"
    fi

#Singlecellulardualsim or Singlecellularsinglesim.
elif [ "${Cellular_Mode}" = "singlecellulardualsim" ]; then
	#Reading which sim is currently active.
    sim=$(cat "$SimNumFile")
    
	#Getting ifname, whether the protocol is cdc ether(usb0) or qmi(wwan0) for sim1.
    if [ "$sim" = "1" ] && [ "$cwan1sim1modemenable" = "1" ]; then
        ifname=$(uci get modem.CWAN1_0.interfacename)
        SimDataUsage "$ifname" "$TmpSim1DataFile" "$Sim1DataFile"
        
	#Getting ifname, whether the protocol is cdc ether(usb0) or qmi(wwan0) for sim2.
    elif [ "$sim" = "2" ] && [ "$cwan1sim2modemenable" = "1" ]; then
        ifname=$(uci get modem.CWAN1_1.interfacename)
        SimDataUsage "$ifname" "$TmpSim2DataFile" "$Sim2DataFile" 
    fi
fi
		
					
DailyDataUsageForSIM1
DailyDataUsageForSIM2
