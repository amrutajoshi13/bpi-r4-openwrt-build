#!/bin/sh

. /lib/functions.sh

SimNumFile="/tmp/simnumfile"

Sim1DataFile="/etc/sim1datausage"
Sim2DataFile="/etc/sim2datausage"
SimDataFile="/etc/simdatausage"

Cellular_mode=$(uci get sysconfig.sysconfig.CellularOperationMode)

# Accessing from webpage selected - $1 from_date,$2 To_date and $3 Sim
echo  "$1 $2 $3"  > /tmp/test.txt

From_date=$(cat /tmp/test.txt | head -1 | cut -d " " -f 1)
echo "$From_date" > /tmp/fromdate.txt
To_date=$(cat /tmp/test.txt | head -1 | cut -d " " -f 2)
echo "$To_date" > /tmp/todate.txt
Selected_Sim=$(cat /tmp/test.txt | head -1 | cut -d " " -f 3)
echo "$Selected_Sim"

current_date="$From_date"
till_date="$To_date"

Selected_year=$(cat /tmp/fromdate.txt | head -1 | cut -d "-" -f 1)
echo "$Selected_year"
#Selected_year_to=$(cat /tmp/todate.txt | head -1 | cut -d "-" -f 1)
#echo "$Selected_year_to"

         if [ "$Selected_Sim" = "SIM1" ]
         then
            if [ -f "$Sim1DataFile" ]                                            
             then
				while [ "$current_date" != "$till_date" ]; do
					grep "$current_date" /etc/dailyusagesim1data_${Selected_year} >> /tmp/grepdata.txt
					current_date_in_seconds=$(date -d "$current_date" +%s)
					current_date_in_seconds=$((current_date_in_seconds + 86400))
					current_date=$(date -d "@$current_date_in_seconds" +%Y-%m-%d)
				done
				grep "$till_date" /etc/dailyusagesim1data_${Selected_year} >> /tmp/grepdata.txt
   
				cat /tmp/grepdata.txt
   
				total_tx_data=0
				total_rx_data=0
				total_total_data=0

				while IFS= read -r line; do
					tx_data=$(echo "$line" | awk '{print $1}' | cut -d "=" -f 2)
					echo "$tx_data"
					rx_data=$(echo "$line" | awk '{print $3}' | cut -d "=" -f 2)
					echo "$rx_data"
					total_data=$(echo "$line" | awk '{print $5}' | cut -d "=" -f 2)
					echo "$total_data"
	 
					total_tx_data=$(awk "BEGIN {print $total_tx_data + $tx_data}")
					total_rx_data=$(awk "BEGIN {print $total_rx_data + $rx_data}")
					total_total_data=$(awk "BEGIN {print $total_total_data + $total_data}")
				done < /tmp/grepdata.txt

				echo "Total Upload=$total_tx_data MB  Total Download=$total_rx_data MB Total=$total_total_data MB" >> /tmp/grepdata.txt
            fi
         fi

         if [ "$Selected_Sim" = "SIM2" ]
         then
           if [ -f "$Sim2DataFile" ]                                            
           then
				while [ "$current_date" != "$till_date" ]
				do
					grep "$current_date" /etc/dailyusagesim2data_${Selected_year}  >> /tmp/grepdata.txt
					current_date_in_seconds=$(date -d "$current_date" +%s)
					current_date_in_seconds=$((current_date_in_seconds + 86400))
					current_date=$(date -d "@$current_date_in_seconds" +%Y-%m-%d)
				done
                grep "$till_date" /etc/dailyusagesim2data_${Selected_year} >> /tmp/grepdata.txt
                
                 cat /tmp/grepdata.txt
   
				total_tx_data=0
				total_rx_data=0
				total_total_data=0

				while IFS= read -r line; do
					tx_data=$(echo "$line" | awk '{print $1}' | cut -d "=" -f 2)
					echo "$tx_data"
					rx_data=$(echo "$line" | awk '{print $3}' | cut -d "=" -f 2)
					echo "$rx_data"
					total_data=$(echo "$line" | awk '{print $5}' | cut -d "=" -f 2)
					echo "$total_data"
	 
					total_tx_data=$(awk "BEGIN {print $total_tx_data + $tx_data}")
					total_rx_data=$(awk "BEGIN {print $total_rx_data + $rx_data}")
					total_total_data=$(awk "BEGIN {print $total_total_data + $total_data}")
				done < /tmp/grepdata.txt

				echo "Total Upload=$total_tx_data MB  Total Download=$total_rx_data MB Total=$total_total_data MB" >> /tmp/grepdata.txt

            fi
         fi
     
