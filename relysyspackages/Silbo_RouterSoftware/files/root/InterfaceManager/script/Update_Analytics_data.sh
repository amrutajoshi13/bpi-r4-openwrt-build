#!/bin/sh
. /lib/functions.sh
. /usr/share/libubox/jshn.sh

IMEI=$(uci get boardconfig.board.imei)
Model=$(uci get sysconfig.sysconfig.model1)

cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"
modem_number=1

SystemConfigFile="/etc/config/sysconfig"
Simswitchbasedon=$(uci get simswitchconfig.simswitchconfig.simswitch)

ReadSystemConfigFile()
{
   	config_load "$SystemConfigFile"
   	config_get CellularOperationModelocal sysconfig CellularOperationMode
   	config_get EnableCellular sysconfig enablecellular
}

Signal_strength(){
	
	ComPort="$1"
	
	Operator_Code=$(gcom -d "$ComPort" -s /etc/gcom/getcarrier.gcom | awk NR==2)

	Operator=$(echo "$Operator_Code" | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')

	Operator=$(echo "$Operator" | tr -d '"')
        Code=$(echo "$Operator_Code" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')


	#Quality_Signal_Noise=$(gcom -d "$ComPort" -s /etc/gcom/getquality.gcom | awk NR==2)
	#Connected=$(echo "$Quality_Signal_Noise" | cut -d "," -f 3 | tr -d '\011\012\013\014\015\040')
	
	Quality_Signal_Noise_Full=$(gcom -d "$ComPort" -s /etc/gcom/getquality.gcom)
	Connected_LTE=$(echo "$Quality_Signal_Noise_Full" | grep -o LTE | tr -d '\011\012\013\014\015\040')
	Connected_NSA=$(echo "$Quality_Signal_Noise_Full" | grep -o NR5G-NSA | tr -d '\011\012\013\014\015\040')
	Connected_SA=$(echo "$Quality_Signal_Noise_Full" | grep -o NR5G-SA | tr -d '\011\012\013\014\015\040')
	Connected_EDGE=$(echo "$Quality_Signal_Noise_Full" | grep -o EDGE | tr -d '\011\012\013\014\015\040')
	Connected_GPRS=$(echo "$Quality_Signal_Noise_Full" | grep -o GPRS | tr -d '\011\012\013\014\015\040')
	Connected_CDMA=$(echo "$Quality_Signal_Noise_Full" | grep -o CDMA | tr -d '\011\012\013\014\015\040')
	
	if [ "$Connected_LTE" = "LTE" ] && [ "$Connected_NSA" = "NR5G-NSA" ]
	then
		Connected="NSA"
		Quality_Signal_Noise1=$(echo "$Quality_Signal_Noise_Full" | awk NR==3)
		Quality_Signal_Noise2=$(echo "$Quality_Signal_Noise_Full" | awk NR==4)
	
	elif [ "$Connected_LTE" = "LTE" ]
	then
		Connected="LTE"
		Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
		
	elif [ "$Connected_SA" = "NR5G-SA" ]
	then
		Connected="SA"
		Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
	elif [ "$Connected_EDGE" = "EDGE" ]
	then
		Connected="EDGE"
		Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
	elif [ "$Connected_GPRS" = "GPRS" ]
	then
		Connected="GPRS"
		Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
	elif [ "$Connected_CDMA" = "CDMA" ]
	then
		Connected="CDMA"
		Quality_Signal_Noise=$(echo "$Quality_Signal_Noise_Full" | awk NR==2)
	fi
	
	if [ "$Connected" = "SA" ] 
	then
		MODE=$(echo "$Quality_Signal_Noise" | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')
		MODE=$(echo "$MODE" | tr -d '"')
		MCC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')
		MNC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 6 | tr -d '\011\012\013\014\015\040')
		LAC="-"
		CELLID=$(echo "$Quality_Signal_Noise" | cut -d "," -f 7 | tr -d '\011\012\013\014\015\040')
		BSIC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 8 | tr -d '\011\012\013\014\015\040')
		ARFCN=$(echo "$Quality_Signal_Noise" | cut -d "," -f 10 | tr -d '\011\012\013\014\015\040')
		BAND=$(echo "$Quality_Signal_Noise" | cut -d "," -f 11 | tr -d '\011\012\013\014\015\040')
		ULBAND="-"
		
		DLBAND_VAL=$(echo "$Quality_Signal_Noise" | cut -d "," -f 12 | tr -d '\011\012\013\014\015\040')
		
		if [ "${DLBAND_VAL}" = "1" ]                                                                    
		then                                                                                            
			DLBAND="3 MHz"                                                                               
		elif [ "${DLBAND_VAL}" = "2" ]                                                                  
		then                                                                                            
			DLBAND="5 MHz"                                                                                                                             
		elif [ "${DLBAND_VAL}" = "3" ]                                                                                                                
		then                                                                                                                                          
			DLBAND="10 MHz"                                                                                                                            
		elif [ "${DLBAND_VAL}" = "4" ]                                                                                                                
		then                                                                                                                                          
			DLBAND="15 MHz"                                                                                                                            
		else                                                                                                                                          
			DLBAND="20 MHz"                                                                                                                            
		fi 
		
		TAC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 9 | tr -d '\011\012\013\014\015\040')
		RSRP=$(echo "$Quality_Signal_Noise" | cut -d "," -f 13 | tr -d '\011\012\013\014\015\040')
		RSRQ=$(echo "$Quality_Signal_Noise" | cut -d "," -f 14 | tr -d '\011\012\013\014\015\040')
		RSSI="-"
		SINR=$(echo "$Quality_Signal_Noise" | cut -d "," -f 15 | tr -d '\011\012\013\014\015\040')
		echo "$Operator,$Connected,$MODE,$MCC,$MNC,$LAC,$CELLID,$BSIC,$ARFCN,$BAND,$ULBAND,$DLBAND,$TAC,$RSRP,$RSRQ,$RSSI,$SINR" > /tmp/ModemAnalytics.txt

		qccid=$(at-cmd $ComPort AT+QCCID | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		len_qccid=$(echo ${#qccid})	
		if [ "$len_qccid" -eq "20" ];then
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$RSRP" "$modem_number"
		else 
			rsrp=-116
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$rsrp" "$modem_number"
		fi
		
		#signal status controller and simswitch signal 
		sh /root/InterfaceManager/script/signal_strength_led_controller.sh "$Connected" "$RSRP"
		if [ "$CellularOperationModelocal" = "singlecellulardualsim" ];then                                 
			if [[ "$Simswitchbasedon" = "signalstren" ]] 
			then
				sh /root/InterfaceManager/script/simswitch/Simswitchsignal.sh "$RSRP" "$SINR"
			fi
		fi
	elif [ "$Connected" = "LTE" ] 
	then
		MODE=$(echo "$Quality_Signal_Noise" | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')
		MODE=$(echo "$MODE" | tr -d '"')
		MCC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')
		MNC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 6 | tr -d '\011\012\013\014\015\040')
		LAC="-"
		CELLID=$(echo "$Quality_Signal_Noise" | cut -d "," -f 7 | tr -d '\011\012\013\014\015\040')
		BSIC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 8 | tr -d '\011\012\013\014\015\040')
		ARFCN=$(echo "$Quality_Signal_Noise" | cut -d "," -f 9 | tr -d '\011\012\013\014\015\040')
		BAND=$(echo "$Quality_Signal_Noise" | cut -d "," -f 10 | tr -d '\011\012\013\014\015\040')
		ULBAND_VAL=$(echo "$Quality_Signal_Noise" | cut -d "," -f 11 | tr -d '\011\012\013\014\015\040')
		
		if [ "${ULBAND_VAL}" = "1" ]
		then
			ULBAND="3 MHz"
		elif [ "${ULBAND_VAL}" = "2" ]
		then
			ULBAND="5 MHz"
		elif [ "${ULBAND_VAL}" = "3" ]                                                                                                                
		then
			ULBAND="10 MHz"
		elif [ "${ULBAND_VAL}" = "4" ]                                                                                                                
		then 
			ULBAND="15 MHz"
		else
			ULBAND="20 MHz"
		fi 
		
		DLBAND_VAL=$(echo "$Quality_Signal_Noise" | cut -d "," -f 12 | tr -d '\011\012\013\014\015\040')
		
		if [ "${DLBAND_VAL}" = "1" ]                                                                    
		then                                                                                            
			DLBAND="3 MHz"                                                                               
		elif [ "${DLBAND_VAL}" = "2" ]                                                                  
		then                                                                                            
			DLBAND="5 MHz"                                                                                                                             
		elif [ "${DLBAND_VAL}" = "3" ]                                                                                                                
		then                                                                                                                                          
			DLBAND="10 MHz"                                                                                                                            
		elif [ "${DLBAND_VAL}" = "4" ]                                                                                                                
		then                                                                                                                                          
			DLBAND="15 MHz"                                                                                                                            
		else                                                                                                                                          
			DLBAND="20 MHz"                                                                                                                            
		fi 
		
		TAC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 13 | tr -d '\011\012\013\014\015\040')
		RSRP=$(echo "$Quality_Signal_Noise" | cut -d "," -f 14 | tr -d '\011\012\013\014\015\040')
		RSRQ=$(echo "$Quality_Signal_Noise" | cut -d "," -f 15 | tr -d '\011\012\013\014\015\040')
		RSSI=$(echo "$Quality_Signal_Noise" | cut -d "," -f 16 | tr -d '\011\012\013\014\015\040')
		SINR=$(echo "$Quality_Signal_Noise" | cut -d "," -f 17 | tr -d '\011\012\013\014\015\040')
		echo "$Operator,$Connected,$MODE,$MCC,$MNC,$LAC,$CELLID,$BSIC,$ARFCN,$BAND,$ULBAND,$DLBAND,$TAC,$RSRP,$RSRQ,$RSSI,$SINR" > /tmp/ModemAnalytics.txt
		
		qccid=$(at-cmd $ComPort AT+QCCID | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		len_qccid=$(echo ${#qccid})	
		if [ "$len_qccid" -eq "20" ];then
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$RSRP" "$modem_number"
		else 
			rsrp=-116
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$rsrp" "$modem_number"
		fi
		
		#signal status controller and simswitch signal 
		sh /root/InterfaceManager/script/signal_strength_led_controller.sh "$Connected" "$RSRP"
		 if [[ "$Simswitchbasedon" = "signalstren" ]] 
		then
			sh /root/InterfaceManager/script/simswitch/Simswitchsignal.sh "$RSRP" "$SINR"
		fi
	elif [ "$Connected" = "NSA" ]
	then
		MODE=$(echo "$Quality_Signal_Noise1" | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')
		MODE=$(echo "$MODE" | tr -d '"')
		MCC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')
		MNC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 3 | tr -d '\011\012\013\014\015\040')
		LAC="-"
		CELLID=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 10 | tr -d '\011\012\013\014\015\040')
		BSIC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')
		ARFCN=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 8 | tr -d '\011\012\013\014\015\040')
		BAND=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 9 | tr -d '\011\012\013\014\015\040')
		ULBAND_VAL=$(echo "$Quality_Signal_Noise1" | cut -d "," -f 9 | tr -d '\011\012\013\014\015\040')
		
		if [ "${ULBAND_VAL}" = "1" ]
		then
			ULBAND="3 MHz"
		elif [ "${ULBAND_VAL}" = "2" ]
		then
			ULBAND="5 MHz"
		elif [ "${ULBAND_VAL}" = "3" ]                                                                                                                
		then
			ULBAND="10 MHz"
		elif [ "${ULBAND_VAL}" = "4" ]                                                                                                                
		then 
			ULBAND="15 MHz"
		else
			ULBAND="20 MHz"
		fi 
		
		DLBAND_VAL=$(echo "$Quality_Signal_Noise1" | cut -d "," -f 10 | tr -d '\011\012\013\014\015\040')
		
		if [ "${DLBAND_VAL}" = "1" ]                                                                    
		then                                                                                            
			DLBAND="3 MHz"                                                                               
		elif [ "${DLBAND_VAL}" = "2" ]                                                                  
		then                                                                                            
			DLBAND="5 MHz"                                                                                                                             
		elif [ "${DLBAND_VAL}" = "3" ]                                                                                                                
		then                                                                                                                                          
			DLBAND="10 MHz"                                                                                                                            
		elif [ "${DLBAND_VAL}" = "4" ]                                                                                                                
		then                                                                                                                                          
			DLBAND="15 MHz"                                                                                                                            
		else                                                                                                                                          
			DLBAND="20 MHz"                                                                                                                            
		fi 
		
		TAC=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 11 | tr -d '\011\012\013\014\015\040')
		RSRP=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')
		RSRQ=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 7 | tr -d '\011\012\013\014\015\040')
		RSSI=$(echo "$Quality_Signal_Noise1" | cut -d "," -f 14 | tr -d '\011\012\013\014\015\040')
		SINR=$(echo "$Quality_Signal_Noise2" | cut -d "," -f 6 | tr -d '\011\012\013\014\015\040')
		echo "$Operator,$Connected,$MODE,$MCC,$MNC,$LAC,$CELLID,$BSIC,$ARFCN,$BAND,$ULBAND,$DLBAND,$TAC,$RSRP,$RSRQ,$RSSI,$SINR" > /tmp/ModemAnalytics.txt
		
		qccid=$(at-cmd $ComPort AT+QCCID | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		len_qccid=$(echo ${#qccid})	
		if [ "$len_qccid" -eq "20" ];then
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$RSRP" "$modem_number"
		else 
			rsrp=-116
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$rsrp" "$modem_number"
		fi
		
		#signal status controller and simswitch signal 
		sh /root/InterfaceManager/script/signal_strength_led_controller.sh "$Connected" "$RSRP"
		if [[ "$Simswitchbasedon" = "signalstren" ]] 
		then
			sh /root/InterfaceManager/script/simswitch/Simswitchsignal.sh "$RSRP" "$SINR"
		fi
	else	
		MODE="-"       
		MCC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 4 | tr -d '\011\012\013\014\015\040')                                                      
		MNC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 5 | tr -d '\011\012\013\014\015\040')                                                      
		LAC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 6 | tr -d '\011\012\013\014\015\040')                                                                                                                                       
		CELLID=$(echo "$Quality_Signal_Noise" | cut -d "," -f 7 | tr -d '\011\012\013\014\015\040')                                                   
		BSIC=$(echo "$Quality_Signal_Noise" | cut -d "," -f 8 | tr -d '\011\012\013\014\015\040')                                                     
		ARFCN=$(echo "$Quality_Signal_Noise" | cut -d "," -f 9 | tr -d '\011\012\013\014\015\040')                                                    
		BAND_VAL=$(echo "$Quality_Signal_Noise" | cut -d "," -f 10 | tr -d '\011\012\013\014\015\040')
		
		if [ "${BAND_VAL}" = "0" ]
		then
			BAND="DCS1800"
		elif [ "${BAND_VAL}" = "1" ]
		then
			BAND="PCS1900" 
		else
			BAND="GSM900"
		fi                                                    
		
		ULBAND="-"                                                                              
		DLBAND="-"                                                                                                                            
		TAC="-"                                                    
		RSRP="-"                                                    
		RSRQ="-"                                                    
		SINR="-"                         
		RSSI=$(at-cmd "$ComPort" at+csq | grep +CSQ | cut -d " " -f 2 | cut -d "," -f 1 | tr -d '\011\012\013\014\015\040')
		RSSI=$((31-RSSI))
		RSSI=$((RSSI*2))
		RSSI=$((-51-RSSI))
		echo "$Operator,$Connected,$MODE,$MCC,$MNC,$LAC,$CELLID,$BSIC,$ARFCN,$BAND,$ULBAND,$DLBAND,$TAC,$RSRP,$RSRQ,$RSSI,$SINR" > /tmp/ModemAnalytics.txt
		
		qccid=$(at-cmd $ComPort AT+QCCID | awk NR==2 | cut -d ":" -f 2 | tr -d '\011\012\013\014\015\040')
		len_qccid=$(echo ${#qccid})	
		if [ "$len_qccid" -eq "20" ];then
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$RSRP" "$modem_number"
		else 
			rsrp=-116
			#show signal strength status in "%"
			sh /root/InterfaceManager/script/signal_strength_led_status.sh "$rsrp" "$modem_number"
		fi
		
		#signal status controller and simswitch signal 
		sh /root/InterfaceManager/script/signal_strength_led_controller.sh "$Connected" "$RSSI"
	fi
	
	#The output is updated in /etc/config/modemstatus, depending on the active SIM.
	
	sim_Reg_State=$(at-cmd $ComPort AT+CREG? | awk NR==2 | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')
	sim_CGReg_State=$(at-cmd $ComPort AT+CGREG? | awk NR==2 | cut -d "," -f 2 | tr -d '\011\012\013\014\015\040')
	SignalStrength=$(at-cmd $ComPort AT+CSQ | awk -F'[ ,"]' '/\+CSQ:/ {print $2}' | tr -d '\011\012\013\014\015\040')
	OperatorCode=$MCC$MNC
	
	uci set modemstatus.modemstatus=interface
	# uci set modemstatus.modemstatus.CellularOperationMode=$CellularOperationModelocal
	# uci set modemstatus.modemstatus.deviceNoofModem=$NoOfModem


	uci set modemstatus.modemstatus.LAC=$LAC
	# uci set modemstatus.modemstatus.Connected=$Connected
	# uci set modemstatus.modemstatus.MODE=$MODE
	# uci set modemstatus.modemstatus.MCC=$MCC
	# uci set modemstatus.modemstatus.MNC=$MNC
	# uci set modemstatus.modemstatus.CellID=$CELLID
	# uci set modemstatus.modemstatus.BSIC=$BSIC
	# uci set modemstatus.modemstatus.ARFCN=$ARFCN
	# uci set modemstatus.modemstatus.BAND=$BAND
	# ULBANDMHz=$(echo $ULBAND | cut -d ' ' -f 1)
	# uci set modemstatus.modemstatus.ULBAND="$ULBANDMHz"MHz
	# DLBANDMHz=$(echo $DLBAND | cut -d ' ' -f 1)
	# uci set modemstatus.modemstatus.DLBAND="$DLBANDMHz"MHz
	# uci set modemstatus.modemstatus.TAC=$TAC
	
	# uci set modemstatus.modemstatus.RSRP=$RSRP
	# uci set modemstatus.modemstatus.RSRQ=$RSRQ
	# uci set modemstatus.modemstatus.RSSI=$RSSI
	# uci set modemstatus.modemstatus.SINR=$SINR	

	# uci set modemstatus.modemstatus.sim_Reg_State=$sim_Reg_State
	# uci set modemstatus.modemstatus.sim_CGReg_State=$sim_CGReg_State
	# uci set modemstatus.modemstatus.SignalStrength=$SignalStrength
	# uci set modemstatus.modemstatus.OperatorCode=$OperatorCode

	if [ -n "$Operator" ] && [[ "$Operator" != "-" ]] && [[ "$Operator" != *"Entry not found"* ]] && [[ "$Operator" != *"ERROR"* ]]; then
			uci set modemstatus.modemstatus.Operator=$Operator
	else
			Operator=$(uci get modemstatus.modemstatus.Operator)
			uci set modemstatus.modemstatus.Operator=$Operator
	fi

	if [ -n "$Connected" ] && [[ "$Connected" != "-" ]] && [[ "$Connected" != *"Entry not found"* ]] && [[ "$Connected" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.Connected="$Connected"
	else
		Connected=$(uci get modemstatus.modemstatus.Connected 2>/dev/null)
		uci set modemstatus.modemstatus.Connected="$Connected"
	fi

	if [ -n "$MODE" ] && [[ "$MODE" != "-" ]] && [[ "$MODE" != *"Entry not found"* ]] && [[ "$MODE" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.MODE="$MODE"
	else
		MODE=$(uci get modemstatus.modemstatus.MODE 2>/dev/null)
		uci set modemstatus.modemstatus.MODE="$MODE"
	fi

	if [ -n "$MCC" ] && [[ "$MCC" != "-" ]] && [[ "$MCC" != *"Entry not found"* ]] && [[ "$MCC" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.MCC="$MCC"
	else
		MCC=$(uci get modemstatus.modemstatus.MCC 2>/dev/null)
		uci set modemstatus.modemstatus.MCC="$MCC"
	fi

	if [ -n "$MNC" ] && [[ "$MNC" != "-" ]] && [[ "$MNC" != *"Entry not found"* ]] && [[ "$MNC" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.MNC="$MNC"
	else
		MNC=$(uci get modemstatus.modemstatus.MNC 2>/dev/null)
		uci set modemstatus.modemstatus.MNC="$MNC"
	fi

	if [ -n "$CELLID" ] && [[ "$CELLID" != "-" ]] && [[ "$CELLID" != *"Entry not found"* ]] && [[ "$CELLID" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.CellID="$CELLID"
	else
		CELLID=$(uci get modemstatus.modemstatus.CellID 2>/dev/null)
		uci set modemstatus.modemstatus.CellID="$CELLID"
	fi

	if [ -n "$BSIC" ] && [[ "$BSIC" != "-" ]] && [[ "$BSIC" != *"Entry not found"* ]] && [[ "$BSIC" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.BSIC="$BSIC"
	else
		BSIC=$(uci get modemstatus.modemstatus.BSIC 2>/dev/null)
		uci set modemstatus.modemstatus.BSIC="$BSIC"
	fi

	if [ -n "$ARFCN" ] && [[ "$ARFCN" != "-" ]] && [[ "$ARFCN" != *"Entry not found"* ]] && [[ "$ARFCN" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.ARFCN="$ARFCN"
	else
		ARFCN=$(uci get modemstatus.modemstatus.ARFCN 2>/dev/null)
		uci set modemstatus.modemstatus.ARFCN="$ARFCN"
	fi

	if [ -n "$BAND" ] && [[ "$BAND" != "-" ]] && [[ "$BAND" != *"Entry not found"* ]] && [[ "$BAND" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.BAND="$BAND"
	else
		BAND=$(uci get modemstatus.modemstatus.BAND 2>/dev/null)
		uci set modemstatus.modemstatus.BAND="$BAND"
	fi

	ULBANDMHz=$(echo "$ULBAND" | cut -d ' ' -f 1)
	if [ -n "$ULBANDMHz" ] && [[ "$ULBANDMHz" != "-" ]] && [[ "$ULBANDMHz" != *"Entry not found"* ]] && [[ "$ULBANDMHz" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.ULBAND="${ULBANDMHz}MHz"
	else
		ULBANDMHz=$(uci get modemstatus.modemstatus.ULBAND 2>/dev/null)
		uci set modemstatus.modemstatus.ULBAND="$ULBANDMHz"
	fi

	DLBANDMHz=$(echo "$DLBAND" | cut -d ' ' -f 1)
	if [ -n "$DLBANDMHz" ] && [[ "$DLBANDMHz" != "-" ]] && [[ "$DLBANDMHz" != *"Entry not found"* ]] && [[ "$DLBANDMHz" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.DLBAND="${DLBANDMHz}MHz"
	else
		DLBANDMHz=$(uci get modemstatus.modemstatus.DLBAND 2>/dev/null)
		uci set modemstatus.modemstatus.DLBAND="$DLBANDMHz"
	fi

	if [ -n "$TAC" ] && [[ "$TAC" != "-" ]] && [[ "$TAC" != *"Entry not found"* ]] && [[ "$TAC" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.TAC="$TAC"
	else
		TAC=$(uci get modemstatus.modemstatus.TAC 2>/dev/null)
		uci set modemstatus.modemstatus.TAC="$TAC"
	fi

	if [ -n "$RSRP" ] && [[ "$RSRP" != "-" ]] && [[ "$RSRP" != *"Entry not found"* ]] && [[ "$RSRP" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.RSRP="$RSRP"
	else
		RSRP=$(uci get modemstatus.modemstatus.RSRP 2>/dev/null)
		uci set modemstatus.modemstatus.RSRP="$RSRP"
	fi

	if [ -n "$RSRQ" ] && [[ "$RSRQ" != "-" ]] && [[ "$RSRQ" != *"Entry not found"* ]] && [[ "$RSRQ" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.RSRQ="$RSRQ"
	else
		RSRQ=$(uci get modemstatus.modemstatus.RSRQ 2>/dev/null)
		uci set modemstatus.modemstatus.RSRQ="$RSRQ"
	fi

	if [ -n "$RSSI" ] && [[ "$RSSI" != "-" ]] && [[ "$RSSI" != *"Entry not found"* ]] && [[ "$RSSI" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.RSSI="$RSSI"
	else
		RSSI=$(uci get modemstatus.modemstatus.RSSI 2>/dev/null)
		uci set modemstatus.modemstatus.RSSI="$RSSI"
	fi

	if [ -n "$SINR" ] && [[ "$SINR" != "-" ]] && [[ "$SINR" != *"Entry not found"* ]] && [[ "$SINR" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.SINR="$SINR"
	else
		SINR=$(uci get modemstatus.modemstatus.SINR 2>/dev/null)
		uci set modemstatus.modemstatus.SINR="$SINR"
	fi

	if [ -n "$sim_Reg_State" ] && [[ "$sim_Reg_State" != "-" ]] && [[ "$sim_Reg_State" != *"Entry not found"* ]] && [[ "$sim_Reg_State" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.sim_Reg_State="$sim_Reg_State"
	else
		sim_Reg_State=$(uci get modemstatus.modemstatus.sim_Reg_State 2>/dev/null)
		uci set modemstatus.modemstatus.sim_Reg_State="$sim_Reg_State"
	fi

	if [ -n "$sim_CGReg_State" ] && [[ "$sim_CGReg_State" != "-" ]] && [[ "$sim_CGReg_State" != *"Entry not found"* ]] && [[ "$sim_CGReg_State" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.sim_CGReg_State="$sim_CGReg_State"
	else
		sim_CGReg_State=$(uci get modemstatus.modemstatus.sim_CGReg_State 2>/dev/null)
		uci set modemstatus.modemstatus.sim_CGReg_State="$sim_CGReg_State"
	fi

	if [ -n "$SignalStrength" ] && [[ "$SignalStrength" != "-" ]] && [[ "$SignalStrength" != *"Entry not found"* ]] && [[ "$SignalStrength" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.SignalStrength="$SignalStrength"
	else
		SignalStrength=$(uci get modemstatus.modemstatus.SignalStrength 2>/dev/null)
		uci set modemstatus.modemstatus.SignalStrength="$SignalStrength"
	fi

	if [ -n "$OperatorCode" ] && [[ "$OperatorCode" != "-" ]] && [[ "$OperatorCode" != *"Entry not found"* ]] && [[ "$OperatorCode" != *"ERROR"* ]]; then
		uci set modemstatus.modemstatus.OperatorCode="$OperatorCode"
	else
		OperatorCode=$(uci get modemstatus.modemstatus.OperatorCode 2>/dev/null)
		uci set modemstatus.modemstatus.OperatorCode="$OperatorCode"
	fi


	uci set modemstatus.modemstatus.SentToday1=$SentToday1
	uci set modemstatus.modemstatus.ReceivedToday1=$ReceivedToday1
	uci set modemstatus.modemstatus.MBConsumedToday1=$MBConsumedToday1
	uci set modemstatus.modemstatus.SentToday2=$SentToday2
	uci set modemstatus.modemstatus.ReceivedToday2=$ReceivedToday2
	uci set modemstatus.modemstatus.MBConsumedToday2=$MBConsumedToday2
	uci set modemstatus.modemstatus.msent1=$msent1
	uci set modemstatus.modemstatus.mreceived1=$mreceived1
	uci set modemstatus.modemstatus.mMBconsumed1=$mMBconsumed1
	uci set modemstatus.modemstatus.msent2=$msent2
	uci set modemstatus.modemstatus.mreceived2=$mreceived2
	uci set modemstatus.modemstatus.mMBconsumed2=$mMBconsumed2
	uci commit modemstatus
}

#This function is for snmp agent to get the daily data used...
daily_data_usage()
{
sim_data="$1"
if [ "$sim_data" = "sim1" ] || [ "$sim_data" = "sim2" ];then
	SentToday1=$(cat /etc/sim1datausage | cut -d "," -f1)
	ReceivedToday1=$(cat /etc/sim1datausage | cut -d "," -f2)
	MBConsumedToday1=$(cat /etc/sim1datausage | cut -d "," -f3)
	SentToday2=$(cat /etc/sim2datausage | cut -d "," -f1)
	ReceivedToday2=$(cat /etc/sim2datausage | cut -d "," -f2)
	MBConsumedToday2=$(cat /etc/sim2datausage | cut -d "," -f3)
elif [ "$sim_data" = "sim" ];then
	SentToday1=$(cat /etc/sim1datausage | cut -d "," -f1)
	ReceivedToday1=$(cat /etc/sim1datausage | cut -d "," -f2)
	MBConsumedToday1=$(cat /etc/sim1datausage | cut -d "," -f3)
	SentToday2=0
	ReceivedToday2=0
	MBConsumedToday2=0
fi
}

#This function is for snmp agent to get the monthly data used...
monthly_data_usage()
{
Selected_Sim="$1"

# Define the function to read sent and received data
read_data() {
	local file="$1"
	local sent=0
	local received=0
	local consumed=0
	
	if [ -f "$file" ];then
		sent=$(cat $file |awk '{print $1}'| cut -d "=" -f2)
		received=$(cat $file |awk '{print $3}'| cut -d "=" -f2)
		consumed=$(cat $file |awk '{print $5}'| cut -d "=" -f2)
	fi
	echo "$sent $received $consumed"
}

# Check the selected SIM and retrieve data accordingly
if [ "$Selected_Sim" = "SIM1" ] || [ "$Selected_Sim" = "SIM2" ];then
	read1=$(read_data "/etc/Current_Month_Sim1_data.txt")
	msent1=$(echo "$read1" | awk '{print $1}')
	mreceived1=$(echo "$read1" | awk '{print $2}')
	mMBconsumed1=$(echo "$read1" | awk '{print $3}')
	
	read2=$(read_data "/etc/Current_Month_Sim2_data.txt")
	msent2=$(echo "$read2" | awk '{print $1}')
	mreceived2=$(echo "$read2" | awk '{print $2}')
	mMBconsumed2=$(echo "$read2" | awk '{print $3}')
elif [ "$Selected_Sim" = "SIM" ];then
	read1=$(read_data "/etc/Current_Month_Sim1_data.txt")
	msent1=$(echo "$read1" | awk '{print $1}')
	mreceived1=$(echo "$read1" | awk '{print $2}')
	mMBconsumed1=$(echo "$read1" | awk '{print $3}')

	msent2=0
    mreceived2=0
    mMBconsumed2=0
fi
}

#This function is for snmp agent to get the IP
#Modem1 Sim IP is set in /tmp/modem1_IP respectively... 
IP()
{
	#This is for Singlecellularsinglesim for modem1... 
	if [ "$1" = "IP_scss" ];then
		if [ "$pdp1" = "IPV4" ];then
			IP=$(ifconfig "$ifname1" | awk '/inet addr/{print substr($2,6)}') 
			echo $IP > /tmp/modem1_IP
		elif [ "$pdp1" = "IPV6" ];then
			IP=$(ifconfig "$ifname1" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
			echo $IP > /tmp/modem1_IP
		elif [ "$pdp1" = "IPV4V6" ];then
			IPV4=$(ifconfig "$ifname1" | awk '/inet addr/{print substr($2,6)}')
			IPV6=$(ifconfig "$ifname1" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
			IP=$(echo $IPV4 $IPV6)
			echo $IP > /tmp/modem1_IP
		fi
	
	#This is for singlecellulardualsim...
	elif [ "$1" = "IP_scds" ];then
		if [ "$pdp" = "IPV4" ];then
			IP=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
			echo $IP > /tmp/modem1_IP
		elif [ "$pdp" = "IPV6" ];then
			IP=$(ifconfig "$ifname" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
			echo $IP > /tmp/modem1_IP
		elif [ "$pdp" = "IPV4V6" ];then
			IPV4=$(ifconfig "$ifname" | awk '/inet addr/{print substr($2,6)}')
			IPV6=$(ifconfig "$ifname" | awk '/inet6 addr:.*Scope:Global/{gsub(/\/.*$/, "", $3); print $3}')
			IP=$(echo $IPV4 $IPV6)
			echo $IP > /tmp/modem1_IP
		fi
	fi
}

ReadSystemConfigFile


if [ "$EnableCellular" = "1" ]
then
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then
		ComPort1=$(uci get modem.CWAN1.ComPortSymLink)
		ComPort2=$(uci get modem.CWAN2.ComPortSymLink)
		
		Signal_strength $ComPort1
		Signal_strength $ComPort2
		    		
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
	then
		NoOfModem="1"
		modem1_enable1=$(uci get modem.CWAN1_0.modemenable)
		modem1_enable2=$(uci get modem.CWAN1_1.modemenable)
		if [ "$modem1_enable1" = 1 ];then 
			ifname=$(uci get modem.CWAN1_0.interfacename)
			pdp=$(uci get sysconfig.sysconfig.pdp)
		elif [ "$modem1_enable2" = 1 ];then
			ifname=$(uci get modem.CWAN1_1.interfacename)
			pdp=$(uci get sysconfig.sysconfig.sim2pdp)
		fi
		
		if  ifconfig | grep -qE "$ifname" 
		then
			simnum=$(cat /tmp/simnumfile)                                                                                         
			if [ "$simnum" = "1" ]                                                                                                
			then
				ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
				daily_data_usage sim1
				monthly_data_usage SIM1
				Signal_strength $ComPort
				IP IP_scds	
			else
				ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1sim2interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
				daily_data_usage sim2
				monthly_data_usage SIM2
				Signal_strength $ComPort
				IP IP_scds
			fi
		else
			QCCIDP=$(uci get modemstatus.modemstatus.QCCID 2>/dev/null)
			if [ "$QCCIDP" = "ERROR" ]; then
				uci set modemstatus.modemstatus.PinState="ERROR"
				uci set modemstatus.modemstatus.IMSI="ERROR"
				uci commit modemstatus
			fi
		fi
	else
		NoOfModem="1"
		ifname1=$(uci get modem.CWAN1.interfacename)
		pdp1=$(uci get sysconfig.sysconfig.pdp)
		if  ifconfig | grep -qE "$ifname1" 
		then
			ComPort=$(cat "/tmp/InterfaceManager/status/$cellularwan1interface.ports" | grep -iw "Comport" | cut -d "=" -f 2)
			daily_data_usage sim
			monthly_data_usage SIM
			Signal_strength $ComPort
			IP IP_scss
		else
			QCCIDP=$(uci get modemstatus.modemstatus.QCCID 2>/dev/null)
			if [ "$QCCIDP" = "ERROR" ]; then
				uci set modemstatus.modemstatus.PinState="ERROR"
				uci set modemstatus.modemstatus.IMSI="ERROR"
				uci commit modemstatus
			fi
		fi
	fi

	 uci set modemstatus.modemstatus.CellularOperationMode=$CellularOperationModelocal
	 uci set modemstatus.modemstatus.deviceNoofModem=$NoOfModem
	
	#For snmp agent modem.sh script is run to update modem information in config file...
	# /bin/modem.sh &
	snmp_enable=$(uci get snmpconfig.snmpconfig.enablesnmp)
	if [ "$snmp_enable" = "1" ];then
		/etc/snmp/port_info.sh &
	fi
	#Exit if cellular is not enabled.
else
	#For snmp agent modem.sh script is run to update modem information in config file...
	# /bin/modem.sh &
	snmp_enable=$(uci get snmpconfig.snmpconfig.enablesnmp)
	if [ "$snmp_enable" = "1" ];then
		/etc/snmp/port_info.sh &
	fi
		exit 0
fi

echo "{\""modem"\":{\""3gpp"\":{\""enabled-locks"\":[],\""eps"\":{\""initial-bearer"\":{\""dbus-path"\":\""--"\",\""settings"\":{\""apn"\":\""--"\",\""ip-type"\":\""--"\",\""password"\":\""--"\",\""user"\":\""--"\"}},\""ue-mode-operation"\":\""csps-2"\"},\""imei"\":\""$IMEI"\",\""operator-code"\":$Code,\""operator-name"\":\""$Operator"\",\""pco"\":\""--"\",\""registration-state"\":\""home"\"},\""cdma"\":{\""activation-state"\":\""--"\",\""cdma1x-registration-state"\":\""--"\",\""esn"\":\""--"\",\""evdo-registration-state"\":\""--"\",\""meid"\":\""--"\",\""nid"\":\""--"\",\""sid"\":\""--"\"},\""dbus-path"\":\""\/org\/freedesktop\/ModemManager1\/Modem\/0"\",\""generic"\":{\""access-technologies"\":[],\""bearers"\":[\""\/org\/freedesktop\/ModemManager1\/Bearer\/0"\"],\""carrier-configuration"\":\""--"\",\""carrier-configuration-revision"\":\""--"\",\""current-bands"\":[],\""current-capabilities"\":[\""gsm-umts, lte"\"],\""current-modes"\":\""allowed: any\; preferred: none"\",\""device"\":\""\/sys\/devices\/platform\/101c0000.ehci\/usb1\/1-1\/1-1.2"\",\""device-identifier"\":\""bfad63a0d36bfd94e3aeedac55fc76ebab30c02b"\",\""drivers"\":[\""option"\"],\""equipment-identifier"\":\""$IMEI"\",\""hardware-revision"\":\""--"\",\""manufacturer"\":\""Quectel"\",\""model"\":\""$Model"\",\""own-numbers"\":[],\""plugin"\":\""Quectel"\",\""ports"\":[\""ttyUSB1"\",\""ttyUSB2"\"],\""power-state"\":\""on"\",\""primary-port"\":\""ttyUSB1"\",\""revision"\":\""M0H.020001"\",\""signal-quality"\":{\""recent"\":\""yes"\",\""value"\":\""57"\"},\""sim"\":\""\/org\/freedesktop\/ModemManager1\/SIM\/0"\",\""state"\":\""connected"\",\""state-failed-reason"\":\""--"\",\""supported-bands"\":[],\""supported-capabilities"\":[\""gsm-umts, lte"\"],\""supported-ip-families"\":[\""ipv4"\",\""ipv6"\",\""ipv4v6"\"],\""supported-modes"\":[\""allowed: 2g\; preferred: none"\",\""allowed: 3g\; preferred: none"\",\""allowed: 2g, 3g\; preferred: none"\",\""allowed: 4g\; preferred: none"\",\""allowed: 2g, 4g\; preferred: none"\",\""allowed: 3g, 4g\; preferred: none"\",\""allowed: 2g, 3g, 4g\; preferred: none"\"],\""unlock-required"\":\""--"\",\""unlock-retries"\":[]}}}" > /tmp/ModemManager_Modem_Json.txt

if [ "$Connected_LTE" = "LTE" ]
then
 RSRP=$(echo "$Quality_Signal_Noise" | cut -d "," -f 14 | tr -d '\011\012\013\014\015\040')
 RSRQ=$(echo "$Quality_Signal_Noise" | cut -d "," -f 15 | tr -d '\011\012\013\014\015\040')
 RSSI=$(echo "$Quality_Signal_Noise" | cut -d "," -f 16 | tr -d '\011\012\013\014\015\040')
 SINR=$(echo "$Quality_Signal_Noise" | cut -d "," -f 17 | tr -d '\011\012\013\014\015\040')
 echo "{\""modem"\":{\""signal"\":{\""cdma1x"\":{\""ecio"\":\""--"\",\""rssi"\":\""--"\"},\""evdo"\":{\""ecio"\":\""--"\",\""io"\":\""--"\",\""rssi"\":\""--"\",\""sinr"\":\""--"\"},\""gsm"\":{\""rssi"\":\""--"\"},\""lte"\":{\""rsrp"\":\""$RSRP"\",\""rsrq"\":\""$RSRQ"\",\""rssi"\":\""$RSSI"\",\""snr"\":\""$SINR"\"},\""refresh"\":{\""rate"\":\""10"\"},\""umts"\":{\""ecio"\":\""--"\",\""rscp"\":\""--"\",\""rssi"\":\""--"\"}}}}" > /tmp/ModemManager_Signal_get.txt
else                        
 RSSI=$(gcom -d "$ComPort" -s /etc/gcom/getstrength.gcom | awk NR==2 | cut -d ":" -f 2 | cut -d "," -f 1 | tr -d '\011\012\013\014\015\040')
 RSSI=`expr 31 - "$RSSI"`
 RSSI=`expr "$RSSI" \* 2`
 RSSI=`expr -51 - "$RSSI"`
 echo "{\""modem"\":{\""signal"\":{\""cdma1x"\":{\""ecio"\":\""--"\",\""rssi"\":\""--"\"},\""evdo"\":{\""ecio"\":\""--"\",\""io"\":\""--"\",\""rssi"\":\""--"\",\""sinr"\":\""--"\"},\""gsm"\":{\""rssi"\":\""$RSSI"\"},\""lte"\":{\""rsrp"\":\""--"\",\""rsrq"\":\""--"\",\""rssi"\":\""--"\",\""snr"\":\""--"\"},\""refresh"\":{\""rate"\":\""10"\"},\""umts"\":{\""ecio"\":\""--"\",\""rscp"\":\""--"\",\""rssi"\":\""--"\"}}}}" > /tmp/ModemManager_Signal_get.txt
fi

exit 0
