#!/bin/sh

. /lib/functions.sh

SimNumFile="/tmp/simnumfile"

Sim1DataFile="/etc/sim1datausage"
Sim2DataFile="/etc/sim2datausage"
SimDataFile="/etc/simdatausage"

Celluar_mode=$(uci get sysconfig.sysconfig.CellularOperationMode)

# Accessing from Data_Consumption.sh script, selected $1 month,$2 year
echo  "$1 $2"  > /tmp/month_data.txt

Selected_month=$(cat /tmp/month_data.txt | head -1 | cut -d " " -f 1)
echo "$Selected_month"
Selected_year=$(cat /tmp/month_data.txt | head -1 | cut -d " " -f 2)
echo "$Selected_year"

#Calculating Monthly Data USage for SingleCellularDualSim SIM1
			if [ -f "$Sim1DataFile" ]                                            
			then
				#echo "$Selected_year-$(($Selected_month))"
				Monthy_records_1=$(cat /etc/dailyusagesim1data_${Selected_year} | cut -d " " -f 1,4,7,10| grep -i "$Selected_year-$Selected_month")
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
					echo "Upload=$total_tx_data MB  Download=$total_rx_data MB Total=$total_total_data MB" > /etc/Current_Month_Sim1_data.txt

				fi
		fi

#Calculating Monthly Data USage for SingleCellularDualSim SIM2
			if [ -f "$Sim2DataFile" ]                                            
			then
				Monthy_records_2=$(cat /etc/dailyusagesim2data_${Selected_year} | cut -d " " -f 1,4,7,10| grep -i "$Selected_year-$Selected_month")
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
					echo "Upload=$total_tx_data MB  Download=$total_rx_data MB Total=$total_total_data MB" > /etc/Current_Month_Sim2_data.txt

				fi
			fi

