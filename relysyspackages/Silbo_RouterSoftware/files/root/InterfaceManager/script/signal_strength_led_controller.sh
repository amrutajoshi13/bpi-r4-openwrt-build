#!/bin/sh

#######################################
# Usage: signal_strength_led_control.sh <network_mode> <val> [modem_number]
#
# network_mode : Current network modulation technology.
# val          : Current value of RSSI or RSRP.
# modem_number : (Optional) Current modem number.
#
# Description:
# This script is used to control and manage signal strength LEDs for different
# network modes and values. It takes the network mode, value, and optionally
# the modem number as input and glows the corresponding LEDs based on the
# signal strength state.
#
# Examples:
#   signal_strength_led_control.sh LTE -80
#   signal_strength_led_control.sh EDGE -90 2
#
#######################################

. /lib/functions.sh

#usage guide
usage()
{
	echo -e "usage : \n$0 <network_mode> <val> <modem_number>\n"
	echo -e "network_mode :\tCurrent network modulation technology"
	echo -e "val          :\tCurrent value of RSSI or RSRP"
	echo -e "modem_number :\t(Optional) Current modem number"
	exit 1;
}



#initialising essential parameters
initialisation()
{
	#loading global configuration
	networkModeLed=$(uci get signalstrength.@global[0].networkModeLed) 
	signalStrengthLed=$(uci get signalstrength.@global[0].signalStrengthLed) 
	numberOfModems=$(uci get signalstrength.@global[0].numberOfModems) 
	numberOfLimits=$(uci get signalstrength.@global[0].numberOfLimits) 
}

#validating the command line arguements
verification()
{
	if [ $val -ge 0 ]
	then 
		echo -e "Error : RSSI or RSRP value out of range"
		exit 1;
	fi
	
	if [ $modem_number -eq $modem_number ] 2>/dev/null
	then
		if [ $modem_number -gt $numberOfModems ]
		then 
			echo -e "Error : Modem number $modem_number is not available"
			exit 1;
		fi
	else
		echo -e "Error : Modem number should be a number"
		exit 1;
	fi
}

#to control network_mode_led (multicolour led only)
glow_network_mode_led()
{	
	#to parse network mode led related parameters
	networkModeIndicatorType=$(uci get signalstrength.modem${modem_number}.networkModeIndicatorType)
	ledOnValue=$(uci get signalstrength.modem${modem_number}.networkModeLedOnValue)
	ledOffValue=$(uci get signalstrength.modem${modem_number}.networkModeLedOffValue)
	
	if [ "$networkModeIndicatorType" = "rgled" ]
	then
		greenled=$(uci get signalstrength.modem${modem_number}.networkModeGreenLed)
		redled=$(uci get signalstrength.modem${modem_number}.networkModeRedLed)
	
		if [ "$mode" = "5g" ]
		then
			echo $ledOnValue > /sys/class/gpio/gpio${greenled}/value
			echo $ledOffValue > /sys/class/gpio/gpio${redled}/value
		elif [ "$mode" = "4g" ]
		then
			echo $ledOnValue > /sys/class/gpio/gpio${greenled}/value
			echo $ledOnValue > /sys/class/gpio/gpio${redled}/value
		elif [ "$mode" = "3g" ] || [ "$mode" = "2g" ]
		then
			echo $ledOffValue > /sys/class/gpio/gpio${greenled}/value
			echo $ledOnValue > /sys/class/gpio/gpio${redled}/value
		else
			echo $ledOffValue > /sys/class/gpio/gpio${greenled}/value
			echo $ledOffValue > /sys/class/gpio/gpio${redled}/value
		fi
	elif [ "$networkModeIndicatorType" = "singleled" ]
	then
		networkModeLed=$(uci get signalstrength.modem${modem_number}.networkModeLed)
		highestNetworkMode=$(uci get signalstrength.modem${modem_number}.highestNetworkMode)
		
		if [ "$mode" = "$highestNetworkMode" ]
		then
			echo $ledOnValue > /sys/class/gpio/gpio${networkModeLed}/value
		else
			echo $ledOffValue > /sys/class/gpio/gpio${networkModeLed}/value
		fi
	fi
}

#to find the network technology latched		
find_mode()
{
	mode=$(uci get signalstrength.networkMode.${mode}) 
	
	if [ -z $mode ]
	then
		if [ "$mode" = "SA" ] || [ "$mode" = "NSA" ]
		then 
			mode="5g"
		elif [ "$mode" = "LTE" ]
		then
			mode="4g"
		elif [ "$mode" = "EDGE" ]
		then
			mode="3g"	
		elif [ "$mode" = "GPRS" ] || [ "$mode" = "CDMA" ]
		then
			mode="2g"
		else
			mode="nil"
		fi
	fi
	
	if [ $networkModeLed -eq 1 ] 
	then
		glow_network_mode_led
	fi	
}

#to determine the state based on value
find_state()
{
	if [ "$mode" = "2g" ] || [ "$mode" = "3g" ] || [ "$mode" = "4g" ] || [ "$mode" = "5g" ]
	then 
		for i in $(seq 1 $numberOfLimits)
		do
			limit=$(uci get signalstrength.${mode}.limit${i})
			if [ $val -ge $limit ]
			then
				state=$(($state+1))
			else
				break
			fi
		done
	else
		state=0
	fi
}

#function to glow status leds according to the state
glow_status_leds()
{
	#parsing ledon and off values from '/etc/config/signalstrength'
	ledOnValue=$(uci get signalstrength.modem${modem_number}.signalStrengthLedOnValue)
	ledOffValue=$(uci get signalstrength.modem${modem_number}.signalStrengthLedOffValue)

	#parsing indicator type
	indictorType=$(uci get signalstrength.modem${modem_number}.signalStrengthIndicatorType) 
	#signal strength status led glowing for monochrome led strip
	if [ "$indictorType" = "ledstrip" ]
	then
		no_of_leds=$(uci get signalstrength.modem${modem_number}.numberOfSignalStrengthLeds)
		for i in $(seq 1 $no_of_leds)
		do
			led=$(uci get signalstrength.modem${modem_number}.signalStrengthLed${i})
			echo $led
			if [ $i -le $state ] 
			then
				echo $ledOnValue > /sys/class/gpio/gpio$led/value
			else
				echo $ledOffValue > /sys/class/gpio/gpio$led/value
			fi
		done
	#signal strength status led glowing for multicolour single led 
	elif [ "$indictorType" = "rgled" ]
	then
		#parsing led gpio numbers
		led1=$(uci get signalstrength.modem${modem_number}.signalStrengthGreenLed)   #green
		led2=$(uci get signalstrength.modem${modem_number}.signalStrengthRedLed)   #red

		if [ $state -eq 0 ]
		then
			echo $ledOffValue > /sys/class/gpio/gpio${led1}/value
			echo $ledOffValue > /sys/class/gpio/gpio${led2}/value
		elif [ $state -eq 1 ]
		then
			echo $ledOffValue > /sys/class/gpio/gpio${led1}/value
			echo $ledOnValue > /sys/class/gpio/gpio${led2}/value
		elif [ $state -eq 2 ]
		then
			echo $ledOnValue > /sys/class/gpio/gpio${led1}/value
			echo $ledOnValue > /sys/class/gpio/gpio${led2}/value
		else
			echo $ledOnValue > /sys/class/gpio/gpio${led1}/value
			echo $ledOffValue > /sys/class/gpio/gpio${led2}/value
		fi
	fi		
}

if [ $# -lt 2 ]
then
	usage
fi

if [ $# -lt 2 ]
then
	usage
fi

mode="$1"
val="$2"
modem_number="$3"
state=1

#default value for modem_number 
if [ -z $3 ]
then 
	modem_number=1
fi

initialisation
verification
find_mode
if [ $signalStrengthLed -eq 1 ]
then
	find_state
	glow_status_leds
fi

echo $signalStrengthLed
