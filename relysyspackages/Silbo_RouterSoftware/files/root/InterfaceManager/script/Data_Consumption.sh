#!/bin/sh

. /lib/functions.sh

EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
Cellular_Mode=$(uci get sysconfig.sysconfig.CellularOperationMode)
Protocol=$(uci get sysconfig.sysconfig.protocol1)

Data_Storage_Threshold=1

sysconfigfile="/etc/config/sysconfig"

#ReadSysConfig

SimNumFile="/tmp/simnumfile"
Sim1DataFile="/etc/sim1datausage"
TmpSim1DataFile="/tmp/sim1datausage"
Sim2DataFile="/etc/sim2datausage"
TmpSim2DataFile="/tmp/sim2datausage"
SimDataFile="/etc/simdatausage"
TmpSimDataFile="/tmp/simdatausage"
Dailydatasusage="/etc/dailyusagesim1data"
Dailydatasusagesim2="/etc/dailyusagesim2data"
DailydatasusageSinglesim="/etc/dailyusagesinglesimdata"
NMS_Enable=$(uci get remoteconfig.nms.nmsenable)

cwan1sim1modemenable=$(uci get modem.CWAN1_0.modemenable)
cwan1sim2modemenable=$(uci get modem.CWAN1_1.modemenable)
cwan1modemenable=$(uci get modem.CWAN1.modemenable)

current_date=$(date +%Y-%m-%d)

#To remove 2 years older files of Data Consumption
current_year=$(echo "$current_date" | cut -d'-' -f1)
result=$((current_year - 2))
#datausagefile_to_be_deleted_Sim="${DailydatasusageSinglesim}_${result}"
datausagefile_to_be_deleted_Sim1="${Dailydatasusage}_${result}"
datausagefile_to_be_deleted_Sim2="${Dailydatasusagesim2}_${result}"

 #rm -f "$datausagefile_to_be_deleted_Sim"
 rm -f "$datausagefile_to_be_deleted_Sim1"
 rm -f "$datausagefile_to_be_deleted_Sim2"
 
 
DailyDataUsageForSIM1()
{
	
current_date=$(date +%Y-%m-%d)
present_date=$(cat "$Sim1DataFile" | cut -d "," -f 4)

presentdate=$(date -d "$present_date" +%s)
echo "$presentdate"
currentdate=$(date -d "$current_date" +%s)
echo "$currentdate"

		if [ "$presentdate" -ne "$currentdate" ]
		then 
			if [ -f "$TmpSim1DataFile" ]                                            
			then              
				echo "0,0,0 " > "$TmpSim1DataFile"                                         
			fi
                   
				if [ -f "$Sim1DataFile" ]                                            
				then
					#################################################          
					# Extract the 4th field from the file
					fourth_field=$(awk -F "," '{print $4}' "$Sim1DataFile")
					echo "$fourth_field"
					year=$(echo "$fourth_field" | cut -d'-' -f1)
					month=$(echo "$fourth_field" | cut -d'-' -f2)

					# Check if the 4th field is empty
					if [ -z "$fourth_field" ]; then
						echo "Empty 4th field. Deleting the file."
						echo "Upload=0 MB  Download=0  MB Total=0 MB  Date=$fourth_field" >> "${Dailydatasusage}_${year}"
						current_date=$(date +%Y-%m-%d)
						echo "0,0,0,$current_date" > "$Sim1DataFile" 
						echo "0,0,0 " > "$TmpSim1DataFile"
						/root/InterfaceManager/script/Msent_Mreceived_Data.sh $month $year
					else
						# Check if the 4th field matches the date format YYYY-MM-DD
						year=$(echo "$fourth_field" | cut -d'-' -f1)
						month=$(echo "$fourth_field" | cut -d'-' -f2)
						day=$(echo "$fourth_field" | cut -d'-' -f3)

						if [ ${#year} -eq 4 ] && [ ${#month} -eq 2 ] && [ ${#day} -eq 2 ] 
						then
							flash_data_used=`cat "$Sim1DataFile"`  
							tx1=$(echo "$flash_data_used" | cut -d "," -f 1)
							#echo "$tx1" >> /etc/tx1.txt
							rx1=$(echo "$flash_data_used" | cut -d "," -f 2)
							#echo "$rx1" >> /etc/rx1.txt
							sum1=$(echo "$flash_data_used" | cut -d "," -f 3)
							#echo "$sum1" >> /etc/sum1.txt
							cur_date1=$(echo "$flash_data_used" | cut -d "," -f 4)
							#echo "$cur_date1" >> /etc/cur_date1.txt
							echo "Upload=$tx1 MB  Download=$rx1 MB  Total=$sum1 MB  Date=$cur_date1" >> "${Dailydatasusage}_${year}"                      
							echo "0,0,0,$current_date" > "$Sim1DataFile"  
							echo "0,0,0 " > "$TmpSim1DataFile"
							/root/InterfaceManager/script/Msent_Mreceived_Data.sh $month $year   						
						else
							echo "Upload=0 MB  Download=0 MB  Total=0 MB  Date=$fourth_field" >> "${Dailydatasusage}_${year}"
							current_date=$(date +%Y-%m-%d)
							echo "0,0,0,$current_date" > "$Sim1DataFile" 
							echo "0,0,0 " > "$TmpSim1DataFile"
							/root/InterfaceManager/script/Msent_Mreceived_Data.sh $month $year
						fi
					fi                                                    
			   fi  
		  fi	  
}


DailyDataUsageForSIM2()
{
	
current_date=$(date +%Y-%m-%d)
present_date=$(cat "$Sim2DataFile" | cut -d "," -f 4)

presentdate=$(date -d "$present_date" +%s)
echo "$presentdate"
currentdate=$(date -d "$current_date" +%s)
echo "$currentdate"

		if [ "$presentdate" -ne "$currentdate" ]
		then 
			if [ -f "$TmpSim2DataFile" ]                                            
			then              
				echo "0,0,0 " > "$TmpSim2DataFile"                                         
			fi
                   
			if [ -f "$Sim2DataFile" ]                                            
			then      
				# Extract the 4th field from the file
				fourth_field=$(awk -F "," '{print $4}' "$Sim2DataFile")
				year=$(echo "$fourth_field" | cut -d'-' -f1)
				month=$(echo "$fourth_field" | cut -d'-' -f2)

				# Check if the 4th field is empty
				if [ -z "$fourth_field" ]; then
					echo "Empty 4th field. Deleting the file."
					echo "Upload=0 MB  Download=0 MB  Total=0 MB  Date=$fourth_field" >> "${Dailydatasusagesim2}_${year}"
					echo "0,0,0,$current_date" > "$Sim2DataFile" 
					echo "0,0,0 " > "$TmpSim2DataFile"
					/root/InterfaceManager/script/Msent_Mreceived_Data.sh $month $year
				else
					# Check if the 4th field matches the date format YYYY-MM-DD
					year=$(echo "$fourth_field" | cut -d'-' -f1)
					month=$(echo "$fourth_field" | cut -d'-' -f2)
					day=$(echo "$fourth_field" | cut -d'-' -f3)

					if [ ${#year} -eq 4 ] && [ ${#month} -eq 2 ] && [ ${#day} -eq 2 ] 
					then
						flash_data_used=`cat "$Sim2DataFile"`  
						tx2=$(echo "$flash_data_used" | cut -d "," -f 1)
						#echo "$tx2" >> /etc/tx2.txt
						rx2=$(echo "$flash_data_used" | cut -d "," -f 2)
						#echo "$rx2" >> /etc/rx2.txt
						sum2=$(echo "$flash_data_used" | cut -d "," -f 3)
						#echo "$sum2" >> /etc/sum2.txt
						cur_date2=$(echo "$flash_data_used" | cut -d "," -f 4)
						#echo "$cur_date2" >> /etc/cur_date2.txt
						echo "Upload=$tx2 MB  Download=$rx2 MB  Total=$sum2 MB  Date=$cur_date2" >> "${Dailydatasusagesim2}_${year}"                      
						echo "0,0,0,$current_date" > "$Sim2DataFile"
						echo "0,0,0 " > "$TmpSim2DataFile"
						/root/InterfaceManager/script/Msent_Mreceived_Data.sh $month $year     						
					else
						echo "Upload=0 MB  Download=0 MB  Total=0 MB  Date=$fourth_field" >> "${Dailydatasusagesim2}_${year}"
						echo "0,0,0,$current_date" > "$Sim2DataFile" 
						echo "0,0,0 " > "$TmpSim2DataFile"
						/root/InterfaceManager/script/Msent_Mreceived_Data.sh $month $year
					fi
				fi            
			fi    
		fi	
}

if [ "$EnableCellular" = "1" ]
then
				sim=`cat "$SimNumFile"`
				if [ "$sim" = "1" ] && { [ "$cwan1sim1modemenable" = "1" ] || [ "$cwan1modemenable" = "1" ]; };
				then 
					SIM="$sim"
					if [ ! -f "$TmpSim1DataFile" ]
					then
						touch "$TmpSim1DataFile"
						echo "0,0,0 " > "$TmpSim1DataFile"
					fi
					if [ ! -f "$Sim1DataFile" ]
					then
						touch "$Sim1DataFile"
						current_date=$(date +%Y-%m-%d)
						echo "0,0,0,$current_date" > "$Sim1DataFile"
					else
						# Extract the 4th field from the file
						fourth_field=$(awk -F "," '{print $4}' "$Sim1DataFile")

						# Check if the 4th field is empty
						if [ -z "$fourth_field" ]; then
						echo "Empty 4th field. Deleting the file."
						rm "$Sim1DataFile"
						else
							# Check if the 4th field matches the date format YYYY-MM-DD
							year=$(echo "$fourth_field" | cut -d'-' -f1)
							month=$(echo "$fourth_field" | cut -d'-' -f2)
							day=$(echo "$fourth_field" | cut -d'-' -f3)

							if [ ${#year} -eq 4 ] && [ ${#month} -eq 2 ] && [ ${#day} -eq 2 ] 
							then
								echo "File exists and the date format is correct: $fourth_field"
							else
								echo "Invalid date format in 4th field. Deleting the file."
								rm "$Sim1DataFile"
							fi
						fi      
					fi
					if [ "$Protocol" = "cdcether" ]                           
					then
						tx_data=$(cat /sys/class/net/usb0/statistics/tx_bytes)
						rx_data=$(cat /sys/class/net/usb0/statistics/rx_bytes)

						tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
						rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
						data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
     
						tmp_data_used=$(cat "$TmpSim1DataFile")
						tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
						rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
						total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)

						tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
						rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
						data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
						data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						
						if [ $data_difference1 -lt 0 ]
						then
							tx_difference="$tx_in_megabytes"
							rx_difference="$rx_in_megabytes"
							data_difference="$data_used"
							data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						fi
						if [ $data_difference1 -ge $Data_Storage_Threshold ]
						then
							printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$TmpSim1DataFile"
							flash_data_used=$(cat "$Sim1DataFile")
							tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
							rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
							total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
							present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
							new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}") 
							new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")   
							new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
							printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date"  > "$Sim1DataFile"
							new_flash_data=$(awk "BEGIN {printf \"%.0f\", $total_data_used+$data_difference}")
						fi
				         
					elif [ "$Protocol" = "qmi" ]
					then
						tx_data=$(cat /sys/class/net/wwan0/statistics/tx_bytes)
						rx_data=$(cat /sys/class/net/wwan0/statistics/rx_bytes)
    
						tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
						rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
						data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
     
						tmp_data_used=$(cat "$TmpSim1DataFile")
						tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
						rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
						total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)

						tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
						rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
						data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
						data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						
						if [ $data_difference1 -lt 0 ]
						then
							tx_difference="$tx_in_megabytes"
							rx_difference="$rx_in_megabytes"
							data_difference="$data_used"
							data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						fi
            
						if [ $data_difference1 -ge $Data_Storage_Threshold ]
						then
							printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$TmpSim1DataFile"
							flash_data_used=$(cat "$Sim1DataFile")
							tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
							rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
							total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
							present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
							new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}") 
							new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")   
							new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
							printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date"  > "$Sim1DataFile"
							new_flash_data=$(awk "BEGIN {printf \"%.0f\", $total_data_used+$data_difference}")
						fi
	              
					else
						tx_data=$(cat /sys/class/net/3g-CWAN1_0/statistics/tx_bytes)     
						rx_data=$(cat /sys/class/net/3g-CWAN1_0/statistics/rx_bytes)   
				
						tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
						rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
						data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
     
						tmp_data_used=$(cat "$TmpSim1DataFile")
						tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
						rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
						total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)

						tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
						rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
						data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
						data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						
						if [ $data_difference1 -lt 0 ]
						then
							tx_difference="$tx_in_megabytes"
							rx_difference="$rx_in_megabytes"
							data_difference="$data_used"
							data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						fi
            
						if [ $data_difference1 -ge $Data_Storage_Threshold ]
						then
							printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$TmpSim1DataFile"
							flash_data_used=$(cat "$Sim1DataFile")
							tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
							rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
							total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
							present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
							new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}") 
							new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")   
							new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
							printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date"  > "$Sim1DataFile"
							new_flash_data=$(awk "BEGIN {printf \"%.0f\", $total_data_used+$data_difference}")
						fi
					fi
					
				elif [[ "$sim" = "2" ]] && [[ "$cwan1sim2modemenable" = "1" ]]
				then 
					if [ ! -f "$TmpSim2DataFile" ]
					then
						touch "$TmpSim2DataFile"
						echo "0,0,0 " > "$TmpSim2DataFile"
					fi
					if [ ! -f "$Sim2DataFile" ]
					then
						touch "$Sim2DataFile"
						current_date=$(date +%Y-%m-%d)
						echo "0,0,0,$current_date" > "$Sim2DataFile"
					else
						#Extract the 4th field from the file
						fourth_field=$(awk -F "," '{print $4}' "$Sim2DataFile")

						# Check if the 4th field is empty
						if [ -z "$fourth_field" ]; then
							echo "Empty 4th field. Deleting the file."
							rm "$Sim2DataFile"
						else
							# Check if the 4th field matches the date format YYYY-MM-DD
							year=$(echo "$fourth_field" | cut -d'-' -f1)
							month=$(echo "$fourth_field" | cut -d'-' -f2)
							day=$(echo "$fourth_field" | cut -d'-' -f3)

							if [ ${#year} -eq 4 ] && [ ${#month} -eq 2 ] && [ ${#day} -eq 2 ] 
							then
								echo "File exists and the date format is correct: $fourth_field"
							else
								echo "Invalid date format in 4th field. Deleting the file."
								rm "$Sim2DataFile"
							fi
						fi          
					fi
					if [ "$Protocol" = "cdcether" ]                                
					then  
						tx_data=$(cat /sys/class/net/usb0/statistics/tx_bytes)
						rx_data=$(cat /sys/class/net/usb0/statistics/rx_bytes)

						tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
						rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
						data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
				 
						tmp_data_used=$(cat "$TmpSim2DataFile")
						tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
						rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
						total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)

						tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
						rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
						data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
						data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						
						if [ $data_difference1 -lt 0 ]
						then
							tx_difference="$tx_in_megabytes"
							rx_difference="$rx_in_megabytes"
							data_difference="$data_used"
							data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						fi
            
						if [ $data_difference1 -ge $Data_Storage_Threshold ]
						then
							printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$TmpSim2DataFile"
							flash_data_used=$(cat "$Sim2DataFile")
							tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
							rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
							total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
							present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
							new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}") 
							new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")   
							new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
							printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date"  > "$Sim2DataFile"
							new_flash_data=$(awk "BEGIN {printf \"%.0f\", $total_data_used+$data_difference}")
						fi
						
					elif [ "$Protocol" = "qmi" ]                                   
					then 
						tx_data=$(cat /sys/class/net/wwan0/statistics/tx_bytes)     
						rx_data=$(cat /sys/class/net/wwan0/statistics/rx_bytes)
		    
						tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
						rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
						data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
				 
						tmp_data_used=$(cat "$TmpSim2DataFile")
						tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
						rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
						total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)

						tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
						rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
						data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
						data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						
						if [ $data_difference1 -lt 0 ]
						then
							tx_difference="$tx_in_megabytes"
							rx_difference="$rx_in_megabytes"
							data_difference="$data_used"
							data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						fi
						
						if [ $data_difference1 -ge $Data_Storage_Threshold ]
						then
							printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$TmpSim2DataFile"
							flash_data_used=$(cat "$Sim2DataFile")
							tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
							rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
							total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
							present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
							new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}") 
							new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")   
							new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
							printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date"  > "$Sim2DataFile"
							new_flash_data=$(awk "BEGIN {printf \"%.0f\", $total_data_used+$data_difference}")
						fi
		         
					else		
						tx_data=$(cat /sys/class/net/3g-CWAN1_1/statistics/tx_bytes)
						rx_data=$(cat /sys/class/net/3g-CWAN1_1/statistics/rx_bytes)
						
						tx_in_megabytes=$(awk "BEGIN {print $tx_data/1048576}")
						rx_in_megabytes=$(awk "BEGIN {print $rx_data/1048576}")
						data_used=$(awk "BEGIN {print $tx_in_megabytes+$rx_in_megabytes}")
				 
						tmp_data_used=$(cat "$TmpSim2DataFile")
						tx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 1)
						rx_tmp=$(echo "$tmp_data_used" | cut -d "," -f 2)
						total_tmp_data_used=$(echo "$tmp_data_used" | cut -d "," -f 3)

						tx_difference=$(awk "BEGIN {print $tx_in_megabytes-$tx_tmp}")
						rx_difference=$(awk "BEGIN {print $rx_in_megabytes-$rx_tmp}")
						data_difference=$(awk "BEGIN {print $data_used-$total_tmp_data_used}")
						data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						
						if [ $data_difference1 -lt 0 ]
						then
							tx_difference="$tx_in_megabytes"
							rx_difference="$rx_in_megabytes"
							data_difference="$data_used"
							data_difference1=$(awk "BEGIN {printf \"%.0f\", $data_difference}")
						fi
            
						if [ $data_difference1 -ge $Data_Storage_Threshold ]
						then
							printf "%.3f,%.3f,%.3f" "$tx_in_megabytes" "$rx_in_megabytes" "$data_used" > "$TmpSim2DataFile"
							flash_data_used=$(cat "$Sim2DataFile")
							tx_data_used=$(echo "$flash_data_used" | cut -d "," -f 1)
							rx_data_used=$(echo "$flash_data_used" | cut -d "," -f 2)
							total_data_used=$(echo "$flash_data_used" | cut -d "," -f 3)
							present_date=$(echo "$flash_data_used" | cut -d "," -f 4)
							new_tx_data=$(awk "BEGIN {print $tx_data_used+$tx_difference}") 
							new_rx_data=$(awk "BEGIN {print $rx_data_used+$rx_difference}")   
							new_flash_data=$(awk "BEGIN {print $total_data_used+$data_difference}")
							printf "%.3f,%.3f,%.3f,%s" "$new_tx_data" "$new_rx_data" "$new_flash_data" "$present_date"  > "$Sim2DataFile"
							new_flash_data=$(awk "BEGIN {printf \"%.0f\", $total_data_used+$data_difference}")
						fi	
					  fi
					fi					
		
fi		    

DailyDataUsageForSIM1
DailyDataUsageForSIM2

		   
