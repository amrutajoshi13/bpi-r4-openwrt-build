#!/bin/sh

. /lib/functions.sh 

EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
if [ "$enablecellular" = "0" ]
then
	exit 0
fi

Simswitch=$(uci get simswitchconfig.simswitchconfig.simswitch)
if [ "$Simswitch" = "none" ]
then
	exit 0
fi

#getting RSRP ans SINR values from Update_Analytics_data.sh script and storing it in Sig.txt file
echo  "$1 $2" >>  /tmp/Sig.txt

num_intervals=5

rsrp_total=0
sinr_total=0
rsrp_count=0
sinr_count=0

#threshold_rsrp=-100
#threshold_sinr=15

#Get the number of lines in the file /tmp/Sig.txt and store it in the variable 'line'
line=$(wc -l < /tmp/Sig.txt)

#Check if the number of lines is greater than or equal to the number of intervals
if [ $line -gt $((num_intervals-1)) ]
then 
	# Loop from 1 to num_intervals	
	for i in $(seq 1 $num_intervals)
	do 
		# Extract the RSRP (first field) from the i-th line of /tmp/Sig.txt
		rsrp=$(cat /tmp/Sig.txt | head -$i | tail -1 | cut -d " " -f 1)
		# Extract the SINR (second field) from the i-th line of /tmp/Sig.txt
		sinr=$(cat /tmp/Sig.txt | head -$i | tail -1 | cut -d " " -f 2)
		#Add current RSRP and SINR value to rsrp_total and sinr_total
		rsrp_total=$(expr $rsrp_total + $rsrp) 
		sinr_total=$(expr $sinr_total + $sinr)   
	done
	# Calculate the average RSRP and average SINR
	rsrp_avg=$(expr $rsrp_total / $num_intervals) 
	sinr_avg=$(expr $sinr_total / $num_intervals)

	threshold_rsrp=$(uci get simswitchconfig.simswitchconfig.threshrsrp)
	threshold_sinr=$(uci get simswitchconfig.simswitchconfig.threshsinr)

	#Checking if RSRP average and SINR average is less than thheir respective Threshold values.
	if [[ "$rsrp_avg" -lt "$threshold_rsrp" ]] &&  [[ "$sinr_avg" -lt "$threshold_sinr" ]]
	then
		#Reading which is is currently active.
		simnum=$(cat /tmp/simnumfile)
		#If sim 1 is active then the sim will switch from sim1 to sim2, if sim 2 is active then vice versa.
		if [ "$simnum" = "1" ];then
			/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
		else
			/root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
		fi
		#Removing Sig.txt file once the sim is switched to read the new values.
		  rm -rf /tmp/Sig.txt
	fi

	echo "$(cat /tmp/Sig.txt | tail -$(($num_intervals-1)))" > /tmp/Sig.txt

fi


