#!/bin/sh /etc/rc.common

. /lib/functions.sh

source /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg


START=98
STOP=98
USE_PROCD=1

# board_name=$(cat /tmp/sysinfo/board_name)

# Read 1 byte from flash offset 0xF020
flash_val=$(dd if=/dev/mtd2 bs=1 skip=$((0xF020)) count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
 
# If nothing read, treat as FF
[ -z "$flash_val" ] && flash_val="FF"
 
case "$flash_val" in
    0B)
        board_name="IDB54-C-GW"
        ;;
    0F)
        board_name="IDF54-C-GW"
        ;;
    FF)
        board_name=$(cat /tmp/sysinfo/board_name)
        ;;
    *)
        # Safety fallback
        board_name=$(cat /tmp/sysinfo/board_name)
        ;;
esac
 
if echo "$board_name" | grep -qE "(IE44)"; then
	numberOfDidoGpio=2
else
	numberOfDidoGpio=4
fi

get_cfg_val() {
    key="$1"
    file="$2"

    grep -E "^[[:space:]]*$key[[:space:]]*=" "$file" \
        | tail -n 1 \
        | cut -d'=' -f2- \
        | tr -d ' "'
}

DIOConfig()
{
	
	DI_CFG="/root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg"
    DI_PARAM_CFG="/root/ReadDIAppComponent/etc/Config/ReadDIAppConfigParameters.cfg"
    DO_PARAM_CFG="/root/ReadDIAppComponent/etc/Config/ReadDOAppConfigParameters.cfg"
   #  board_name=$(cat /tmp/sysinfo/board_name)
	# echo "board_name=$board_name"
	 
		file_content=$(cat /root/ReadDIAppComponent/etc/Config/DIOStatus.txt)
		for i in $(seq 1 $numberOfDidoGpio)
		do
			DIOMode=$(get_cfg_val "DIOMode${i}" "$DI_CFG")
			
			di=$(get_cfg_val "DInput${i}PinNo" "$DI_PARAM_CFG")

			# Read OUTPUT config --------
			do=$(get_cfg_val "DOutput${i}PinNo" "$DO_PARAM_CFG")

			# Read state 
			divalue=$(echo "$file_content" | awk -F ',' -v f="$i" '{print $f}')
			echo "DIO$i MODE=$DIOMode DI=$di DO=$do VALUE=$divalue"
			
			if [ "$DIOMode" = "0" ]; then
				if [ "$di" -ne 0 ]; then
					echo "$di" > /sys/class/gpio/export 2>/dev/null
					echo "in" > /sys/class/gpio/gpio${di}/direction
				fi

				#  MODE --------
			elif [ "$DIOMode" = "1" ]; then
				if [ "$do" -ne 0 ]; then
					echo "$do" > /sys/class/gpio/export 2>/dev/null
					echo "out" > /sys/class/gpio/gpio${do}/direction
					echo "$divalue" > /sys/class/gpio/gpio${do}/value
				fi
            
			  # -------- Board-specific logic --------
				case "$board_name" in
					*IAB44*)
						echo "1" > /sys/class/gpio/gpio$((489 + i))/value
						;;
					*ID*)
						echo "1" > /sys/class/gpio/gpio$((392 + i))/value
						;;
					*RFN*)
						value=$(cut -d',' -f2 /root/ReadDIAppComponent/etc/Config/DIOStatus.txt)
						echo "$value" > /sys/class/gpio/gpio46/value
						;;
					*IAC44*)
						[ "$i" -eq 1 ] && echo "1" > /sys/class/gpio/gpio$((487 + i))/value
						;;
				esac
        fi
     done

}		

AIOConfig()
{
	#AI_PARAM_CFG="/root/ReadAIAppComponent/etc/Config/ReadAIAppConfig.cfg"
	#AI_CFG="/root/ReadAIAppComponent/etc/Config/ReadAIAppWebConfig.cfg"
	#numberOfAiGpio=$(get_cfg_val "NoOfAInput" "$AI_CFG")
	#echo "numberOfAiGpio=$numberOfAiGpio"
	
	#for i in $(seq 1 $numberOfAiGpio)
    #do
		#ai=$(get_cfg_val "AInput${i}PinNo" "$AI_PARAM_CFG")
		#echo "$ai" > /sys/class/gpio/export 2>/dev/null
		#echo "out" > /sys/class/gpio/gpio${ai}/direction
        #echo "1" > /sys/class/gpio/gpio${ai}/value
    #done
    
    
    
. /root/ReadAIAppComponent/etc/Config/ReadAIAppGeneric.cfg   
echo "AInputPinNo=$AInputPinNo"

		echo "$AInputPinNo" > /sys/class/gpio/export 2>/dev/null
		echo "out" > /sys/class/gpio/gpio${AInputPinNo}/direction
        echo "1" > /sys/class/gpio/gpio${AInputPinNo}/value
 
}

	


start_service()
{
    DIOConfig
    AIOConfig
}

Action=$1
case "$Action" in
    start)
        echo "Starting Apps"
        start_service
        ;;
    cron_start)
        RunMonit
        ;;
    stop)
        stop_service
        ;;
    *)
        echo "Usage: $0 {start|cron_start|stop}"
        ;;
esac

exit 0
