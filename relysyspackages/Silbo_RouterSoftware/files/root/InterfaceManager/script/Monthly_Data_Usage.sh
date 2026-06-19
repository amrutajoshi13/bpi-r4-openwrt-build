#!/bin/sh

. /lib/functions.sh

#sysconfigfile="/etc/config/sysconfig"

SimNumFile="/tmp/simnumfile"

Sim1DataFile="/etc/sim1datausage"
Sim2DataFile="/etc/sim2datausage"
SimDataFile="/etc/simdatausage"

Celluar_mode=$(uci get sysconfig.sysconfig.CellularOperationMode)

# Accessing from webpage selected $1 month,$2 year and $3 Sim 
echo  "$1 $2 $3"  > /tmp/monthly_data.txt

Selected_month=$(cat /tmp/monthly_data.txt | head -1 | cut -d " " -f 1)
echo "$Selected_month"
Selected_year=$(cat /tmp/monthly_data.txt | head -1 | cut -d " " -f 2)
echo "$Selected_year"
Selected_Sim=$(cat /tmp/monthly_data.txt | head -1 | cut -d " " -f 3)
echo "$Selected_Sim"

#read Selected_month
January=1
Febuary=2
March=3
April=4
May=5
June=6
July=7
August=8
September=9
October=10
November=11
December=12


		if [ "$Selected_Sim" = "SIM1" ]
		then
			if [ -f "$Sim1DataFile" ]                                            
			then
				monthNumber=$(($Selected_month))
				temp=${#monthNumber}
				#echo "Month $temp" 
				if [ $temp -eq 1 ]
				then
					monthNumber=$(echo "0${monthNumber}")
				fi
				#echo "$Selected_year-$(($Selected_month))"
				Monthy_records_1=$(cat /etc/dailyusagesim1data_${Selected_year} | cut -d " " -f 1,4,7,10| grep -i "$Selected_year-$monthNumber")
				echo "$Monthy_records_1" > /tmp/monthly_records_1 

				total_tx_data=0
				total_rx_data=0
				total_total_data=0

				while IFS= read -r line; do

				tx_data=$(echo "$line" | awk '{print $1}' | cut -d "=" -f 2)
				rx_data=$(echo "$line" | awk '{print $2}' | cut -d "=" -f 2)
				total_data=$(echo "$line" | awk '{print $3}' | cut -d "=" -f 2)
	
				total_tx_data=$(awk "BEGIN {print $total_tx_data + $tx_data}")
				total_rx_data=$(awk "BEGIN {print $total_rx_data + $rx_data}")
			    total_total_data=$(awk "BEGIN {print $total_total_data + $total_data}")
				done < /tmp/monthly_records_1

				if [[ -z "$total_total_data" ]]
				then
					echo 
				else
					echo "Total TX Data: $total_tx_data"
					echo "Total RX Data: $total_rx_data"
					echo "Total: $total_total_data"
					echo "Upload=$total_tx_data MB  Download=$total_rx_data MB Total=$total_total_data MB" > /etc/each_month_data_usage.txt

				fi
			fi
		fi

		if [ "$Selected_Sim" = "SIM2" ]
		then
			if [ -f "$Sim2DataFile" ]                                            
			then
				monthNumber=$(($Selected_month))
				temp=${#monthNumber}
				#echo "Month $temp" 
				if [ $temp -eq 1 ]
				then
					monthNumber=$(echo "0${monthNumber}")
				fi
				#echo "$Selected_year-$(($Selected_month))"
				Monthy_records_2=$(cat /etc/dailyusagesim2data_${Selected_year} | cut -d " " -f 1,4,7,10| grep -i "$Selected_year-$monthNumber")
				echo "$Monthy_records_2" > /tmp/monthly_records_2 

				total_tx_data=0
				total_rx_data=0
				total_total_data=0

				while IFS= read -r line; do

				tx_data=$(echo "$line" | awk '{print $1}' | cut -d "=" -f 2)
				rx_data=$(echo "$line" | awk '{print $2}' | cut -d "=" -f 2)
				total_data=$(echo "$line" | awk '{print $3}' | cut -d "=" -f 2)
 
 
				total_tx_data=$(awk "BEGIN {print $total_tx_data + $tx_data}")
				total_rx_data=$(awk "BEGIN {print $total_rx_data + $rx_data}")
				total_total_data=$(awk "BEGIN {print $total_total_data + $total_data}")
				done < /tmp/monthly_records_2

				if [[ -z "$total_total_data" ]]
				then
					echo 
				else
					echo "Total TX Data: $total_tx_data"
					echo "Total RX Data: $total_rx_data"
					echo "Total: $total_total_data"
					echo "Upload=$total_tx_data MB  Download=$total_rx_data MB Total=$total_total_data MB" > /etc/each_month_data_usage.txt

				fi
			fi
		fi

