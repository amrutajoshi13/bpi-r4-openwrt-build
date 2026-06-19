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
        #current=$(echo "$last_line" | awk '{print $3}')
        #voltage=$(echo "$last_line" | awk '{print $3}')
        current=$(echo "$last_line" | awk '{print $3" "$4}')
		voltage=$(echo "$last_line" | awk '{print $3" "$4}')
		if [[ "$ChannelType" == "1" ]]; then
				echo "Current Value for channel $ADCChannelNumber is $current."
		else
				echo "Voltage Value for channel $ADCChannelNumber is $voltage."
		fi
		  
        
        
        ;;
    2)
          
          ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType2) 
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        #current=$(echo "$last_line" | awk '{print $3}')
        #voltage=$(echo "$last_line" | awk '{print $3}')
        current=$(echo "$last_line" | awk '{print $3" "$4}')
		voltage=$(echo "$last_line" | awk '{print $3" "$4}')
		if [[ "$ChannelType" == "1" ]]; then
				echo "Current Value for channel $ADCChannelNumber is $current."
		else
				echo "Voltage Value for channel $ADCChannelNumber is $voltage."
		fi
		  
        
        
        ;;
    3)
          
          ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType3) 
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        #current=$(echo "$last_line" | awk '{print $3}')
        #voltage=$(echo "$last_line" | awk '{print $3}')
        current=$(echo "$last_line" | awk '{print $3" "$4}')
		voltage=$(echo "$last_line" | awk '{print $3" "$4}')
        
			if [[ "$ChannelType" == "1" ]]; then
				echo "Current Value for channel $ADCChannelNumber is $current."
		else
				echo "Voltage Value for channel $ADCChannelNumber is $voltage."
		fi

		  
        
        
        ;;
    4)
          
          ChannelType=$(uci get analoginputconfig.analoginputconfig.ChannelType4) 
       AI_Out=$(/root/ADCUtilityComponent/ADCUtility "$ADCChannelNumber" "$range" 2>&1)             
        last_line=$(echo "$AI_Out" | tail -n 1)
        #current=$(echo "$last_line" | awk '{print $3}')
        #voltage=$(echo "$last_line" | awk '{print $3}')
        current=$(echo "$last_line" | awk '{print $3" "$4}')
		voltage=$(echo "$last_line" | awk '{print $3" "$4}')
		if [[ "$ChannelType" == "1" ]]; then
				echo "Current Value for channel $ADCChannelNumber is $current."
		else
				echo "Voltage Value for channel $ADCChannelNumber is $voltage."
		fi
		  
        
        
        ;;
    
    *)
        echo "Error: ADCChannelNumber should only accept 1 to 4"
        exit 1
        ;;
esac


#done
    
