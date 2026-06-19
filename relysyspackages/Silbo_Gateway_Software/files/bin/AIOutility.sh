#!/bin/sh

ADCChannelNumber="$1"
range=2

. /usr/local/bin/Testscripts/testscriptconfig.cfg


#for ADCChannelNumber in 1 2; do
case "$ADCChannelNumber" in
    1)
          
	   ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType1) 
	   
	   
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        current=$(echo "$last_line" | awk '{print $3}')
        voltage=$(echo "$last_line" | awk '{print $3}')
        
		if [[ "$ChannelType" == "1" ]]; then
			if awk -v curr="$current" -v min="$minimumcurrent" -v max="$maximumcurrent" 'BEGIN { exit !(curr >= min && curr <= max) }'; then
				echo "Current $current is present in the correct range."
			else
				echo "Current $current is not present in the given range."
			fi
		else
			if awk -v volt="$voltage" -v min="$minimumvoltage" -v max="$maximumvoltage" 'BEGIN { exit !(volt >= min && volt <= max) }'; then
				echo "Voltage $voltage is present in the correct range."
			else
				echo "Voltage $voltage is not present in the given range."
			fi
		fi
		  
        
        
        ;;
    2)
          
          ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType2) 
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        current=$(echo "$last_line" | awk '{print $3}')
        voltage=$(echo "$last_line" | awk '{print $3}')
        
		if [[ "$ChannelType" == "1" ]]; then
			if awk -v curr="$current" -v min="$minimumcurrent" -v max="$maximumcurrent" 'BEGIN { exit !(curr >= min && curr <= max) }'; then
				echo "Current $current is present in the correct range."
			else
				echo "Current $current is not present in the given range."
			fi
		else
			if awk -v volt="$voltage" -v min="$minimumvoltage" -v max="$maximumvoltage" 'BEGIN { exit !(volt >= min && volt <= max) }'; then
				echo "Voltage $voltage is present in the correct range."
			else
				echo "Voltage $voltage is not present in the given range."
			fi
		fi
		  
        
        
        ;;
    3)
          
          ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType3) 
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        current=$(echo "$last_line" | awk '{print $3}')
        voltage=$(echo "$last_line" | awk '{print $3}')
        
		if [[ "$ChannelType" == "1" ]]; then
			if awk -v curr="$current" -v min="$minimumcurrent" -v max="$maximumcurrent" 'BEGIN { exit !(curr >= min && curr <= max) }'; then
				echo "Current $current is present in the correct range."
			else
				echo "Current $current is not present in the given range."
			fi
		else
			if awk -v volt="$voltage" -v min="$minimumvoltage" -v max="$maximumvoltage" 'BEGIN { exit !(volt >= min && volt <= max) }'; then
				echo "Voltage $voltage is present in the correct range."
			else
				echo "Voltage $voltage is not present in the given range."
			fi
		fi
		  
        
        
        ;;
    4)
          
          ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType4) 
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        current=$(echo "$last_line" | awk '{print $3}')
        voltage=$(echo "$last_line" | awk '{print $3}')
        
		if [[ "$ChannelType" == "1" ]]; then
			if awk -v curr="$current" -v min="$minimumcurrent" -v max="$maximumcurrent" 'BEGIN { exit !(curr >= min && curr <= max) }'; then
				echo "Current $current is present in the correct range."
			else
				echo "Current $current is not present in the given range."
			fi
		else
			if awk -v volt="$voltage" -v min="$minimumvoltage" -v max="$maximumvoltage" 'BEGIN { exit !(volt >= min && volt <= max) }'; then
				echo "Voltage $voltage is present in the correct range."
			else
				echo "Voltage $voltage is not present in the given range."
			fi
		fi
		  
        
        
        ;;
    
    *)
        echo "Error: ADCChannelNumber should only accept 1 to 4"
        exit 1
        ;;
esac


#done
    
