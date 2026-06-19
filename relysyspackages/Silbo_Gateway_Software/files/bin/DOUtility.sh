

#!/bin/sh

sleep 5

#board_name=$(cat /tmp/sysinfo/board_name)

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

dido_num=$(uci get digitalinputconfig.didogpioconfig.numberOfDido)

if echo "$board_name" | grep -qE "(RFN)"; then
	pin1=$(uci get digitalinputconfig.didogpioconfig.do2)
	echo $pin1 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio$pin1/direction
	
value=1
gpio_port_DO=2
gpio_port_DI=1

DO_out=$(/root/DOUtilityIndividualTestComponent/DOUtilityIndividual "$gpio_port_DO" "$value" 2>&1)
last_line_DO=$(echo "$DO_out" | tail -n 1)

DI_out=$(/root/DIUtilityIndividualTestComponent/DIUtilityIndividual "$gpio_port_DI" 2>&1)
last_line_DI=$(echo "$DI_out" | grep -o -E "[0-9]+" | tail -n 1 | cut -d ' ' -f 4)


#last_line_DI=$(cat /sys/class/gpio/gpio$pin1/value)


if [[ "$last_line_DI" == "$value" ]]; then
	echo "DO $gpio_port: Expected $value and got $last_line_DI"
else
	echo "DO $gpio_port: Expected $value but got $last_line_DI"
fi

sleep 5
	
value=0
gpio_port_DO=2
gpio_port_DI=1

DO_out=$(/root/DOUtilityIndividualTestComponent/DOUtilityIndividual "$gpio_port_DO" "$value" 2>&1)
last_line_DO=$(echo "$DO_out" | tail -n 1)

DI_out=$(/root/DIUtilityIndividualTestComponent/DIUtilityIndividual "$gpio_port_DI" 2>&1)
last_line_DI=$(echo "$DI_out" | grep -o -E "[0-9]+" | tail -n 1 | cut -d ' ' -f 4)


#last_line_DI=$(cat /sys/class/gpio/gpio$pin1/value)


if [[ "$last_line_DI" == "$value" ]]; then
	echo "DO $gpio_port: Expected $value and got $last_line_DI"
else
	echo "DO $gpio_port: Expected $value but got $last_line_DI"
fi
sleep 1

echo $pin1 > /sys/class/gpio/unexport

else

if [ "$dido_num" -eq 2 ]; then
	pin1=$(uci get digitalinputconfig.didogpioconfig.do1)
	pin2=$(uci get digitalinputconfig.didogpioconfig.do2)
	echo $pin1 > /sys/class/gpio/export
	echo $pin2 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio$pin1/direction
	echo out > /sys/class/gpio/gpio$pin2/direction
elif [ "$dido_num" -eq 4 ]; then
	pin1=$(uci get digitalinputconfig.didogpioconfig.do1)
	pin2=$(uci get digitalinputconfig.didogpioconfig.do2)
	pin3=$(uci get digitalinputconfig.didogpioconfig.do3)
	pin4=$(uci get digitalinputconfig.didogpioconfig.do4)
	echo $pin1 > /sys/class/gpio/export
	echo $pin2 > /sys/class/gpio/export
	echo $pin3 > /sys/class/gpio/export
	echo $pin4 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio$pin1/direction
	echo out > /sys/class/gpio/gpio$pin2/direction
	echo out > /sys/class/gpio/gpio$pin3/direction
	echo out > /sys/class/gpio/gpio$pin4/direction
else
	echo "dido_num is neither 2 nor 3."
fi
value=1
for gpio_port in $(seq 1 "$dido_num"); do

    DO_out=$(/root/DOUtilityIndividualTestComponent/DOUtilityIndividual "$gpio_port" "$value" 2>&1)
    last_line_DO=$(echo "$DO_out" | tail -n 1)
    # Extract the value from last_line_DO as before

    DI_out=$(/root/DIUtilityIndividualTestComponent/DIUtilityIndividual "$gpio_port" 2>&1)
    last_line_DI=$(echo "$DI_out" | grep -o -E "[0-9]+" | tail -n 1 | cut -d ' ' -f 4)

    if [[ "$last_line_DI" == "$value" ]]; then
        echo "DO $gpio_port: Expected $value and got $last_line_DI"
    else
        echo "DO $gpio_port: Expected $value but got $last_line_DI"
    fi
    sleep 1
done

sleep 5

value=0

for gpio_port in $(seq 1 "$dido_num"); do
    DO_out=$(/root/DOUtilityIndividualTestComponent/DOUtilityIndividual "$gpio_port" "$value" 2>&1)
    last_line_DO=$(echo "$DO_out" | tail -n 1)
    # Extract the value from last_line_DO as before

    DI_out=$(/root/DIUtilityIndividualTestComponent/DIUtilityIndividual "$gpio_port" 2>&1)
    last_line_DI=$(echo "$DI_out" | grep -o -E "[0-9]+" | tail -n 1 | cut -d ' ' -f 4)

    if [[ "$last_line_DI" == "$value" ]]; then
        echo "DO $gpio_port: Expected $value and got $last_line_DI"
    else
        echo "DO $gpio_port: Expected $value but got $last_line_DI"
    fi
    sleep 1
done
if [ "$dido_num" -eq 2 ]; then
	echo $pin1 > /sys/class/gpio/unexport
	echo $pin2 > /sys/class/gpio/unexport
else
	echo $pin1 > /sys/class/gpio/unexport
	echo $pin2 > /sys/class/gpio/unexport
	echo $pin3 > /sys/class/gpio/unexport
	echo $pin4 > /sys/class/gpio/unexport
fi
sleep 5

fi

