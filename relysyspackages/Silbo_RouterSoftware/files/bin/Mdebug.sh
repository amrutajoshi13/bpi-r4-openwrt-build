#!/bin/sh

#read -p "Enter comport number only(1-5) : " port
rm -rf /tmp/Mdebug.txt
source /tmp/InterfaceManager/status/ports.txt
comport=$ComPort
{
Servingcell=$(/bin/at-cmd $comport at+qeng="\"servingcell\"" | awk -F"," 'NR==2')
MCC=$(echo $Servingcell | awk -F"," 'NR==1 {print$5}')
MNC=$(echo $Servingcell | awk -F"," 'NR==1 {print$6}')
UBW=$(echo $Servingcell | awk -F"," 'NR==1 {print$11}')
DBW=$(echo $Servingcell | awk -F"," 'NR==1 {print$12}')
RSRP=$(echo $Servingcell | awk -F"," 'NR==1 {print$14}')
RSRQ=$(echo $Servingcell | awk -F"," 'NR==1 {print$15}')
RSSI=$(echo $Servingcell | awk -F"," 'NR==1 {print$16}')
SINR=$(echo $Servingcell | awk -F"," 'NR==1 {print$17}')
echo -e "\e[1;34m#####################################Cellular Modem info ########################################\e[0m"
Modeminfo=$(/bin/at-cmd $comport ati)
Modemname=$(echo "$Modeminfo" | awk 'NR==3 {print $1}')
ModemFW=$(echo "$Modeminfo" | awk 'NR==4 {print $2}')
Modemimei=$(/bin/at-cmd $comport at+gsn | awk 'NR==2 {print $1}')
echo -e "Cellular Modem is : \e[1;32m$Modemname\e[0m"
echo -e "Cellular Modem Firmware : \e[1;32m$ModemFW\e[0m"
echo -e "Cellular Modem IMEI : \e[1;32m$Modemimei\e[0m"
SIMqccid=$(/bin/at-cmd $comport at+qccid | awk 'NR==2 {print $2}')
echo -e "SIM Qccid : \e[1;32m$SIMqccid\e[0m"
echo -e "\e[1;34m#################################### SIM Registration status ####################################\e[0m"
ModemREG=$(/bin/at-cmd $comport at+creg? | awk -F "," 'NR==2 {print $2}')
if [ $ModemREG -eq 1 ]; then

	echo -e "\e[1;32mSIM Registered Successfully\e[0m"
else 
	echo -e "\e[1;31mSIM not Registered\e[0m"
	echo -e "\e[1;41mCheck SIM is in the right SIM slot and antenna connected properly\e[0m"
	
fi
echo -e "\e[1;34m######################################Signal strength ##########################################\e[0m"
ModemSig=$(/bin/at-cmd $comport at+csq | awk 'NR==2 {print $2}')
Signal=$(echo "$ModemSig" | awk -F "," 'NR==1 {print $1}')
echo -e "\e[1;33mSignal strength should be (18-31)\e[0m"
if [ $Signal -ge 18 ]; then
	echo -e "Cellular Signal strength : \e[1;32m$Signal\e[0m"
else 
	echo -e "Cellular Signal strength is weak : \e[1;31m$Signal\e[0m"
	echo -e "\e[1;41mCheck antenna's connected properly or not, If not connect the antenna's and reboot the board\e[0m"

fi
##############################################################################################
if [ $RSRP -ge -95 ] && [ $RSRP -lt -44 ]; then
	echo -e "Reference Signal Received Power(RSRP): \e[1;32m$RSRP\e[0m"
	echo -e "\e[1;32mRSRP is Very Good\e[0m"
elif [ $RSRP -ge -105 ] && [ $RSRP -lt -95 ]; then
	echo -e "Reference Signal Received Power(RSRP):\e[1;32m$RSRP\e[0m"
	echo -e "\e[1;32mRSRP is Good\e[0m"
elif [ $RSRP -ge -115 ] && [ $RSRP -lt -105 ]; then
	echo -e "Reference Signal Received Power(RSRP):\e[1;33m$RSRP\e[0m"
	echo -e "\e[1;33mRSRP is Fair\e[0m"
elif [ $RSRP -ge -140 ] && [ $RSRP -lt -115 ]; then
	echo -e "Reference Signal Received Power(RSRP):\e[1;31m$RSRP\e[0m"
	echo -e "\e[1;31mRSRP is Bad\e[0m"
else
	echo -e "Reference Signal Received Power(RSRP):\e[1;41m$RSRP\e[0m"
	echo -e "\e[1;41mRSRP value is Unknown\e[0m"
fi
##############################################################################################
if [ $RSSI -ge -63 ] && [ $RSSI -lt -51 ]; then
	echo -e "Received Signal Strength Indicator(RSSI): \e[1;32m$RSSI\e[0m"
	echo -e "\e[1;32mRSSI is Very Good\e[0m"
elif [ $RSSI -ge -73 ] && [ $RSSI -lt -63 ]; then
	echo -e "Received Signal Strength Indicator(RSSI):\e[1;32m$RSSI\e[0m"
	echo -e "\e[1;32mRSSI is Good\e[0m"
elif [ $RSSI -ge -93 ] && [ $RSSI -lt -73 ]; then
	echo -e "Received Signal Strength Indicator(RSSI):\e[1;33m$RSSI\e[0m"
	echo -e "\e[1;33mRSSI is Fair\e[0m"
elif [ $RSSI -lt -93 ]; then
	echo -e "Received Signal Strength Indicator(RSSI):\e[1;33m$RSSI\e[0m"
	echo -e "\e[1;31mRSSI is Bad\e[0m"
else
	echo -e "Received Signal Strength Indicator(RSSI):\e[1;31m$RSSI\e[0m"
	echo -e "\e[1;41mRSSI value is Unknown\e[0m"
fi
##############################################################################################
if [ $RSRQ -ge -10 ] && [ $RSRQ -lt -3 ]; then
	echo -e "Reference Signal Received Quality): \e[1;32m$RSRQ\e[0m"
	echo -e "\e[1;32mRSRQ is Very Good\e[0m"
elif [ $RSRQ -ge -15 ] && [ $RSRQ -lt -10 ]; then
	echo -e "Reference Signal Received Quality(RSRQ):\e[1;32m$RSRQ\e[0m"
	echo -e "\e[1;32mRSRQ is Good\e[0m"
elif [ $RSRQ -ge -20 ] && [ $RSRQ -lt -15 ]; then
	echo -e "Reference Signal Received Quality(RSRQ):\e[1;33m$RSRQ\e[0m"
	echo -e "\e[1;33mRSRQ is Fair\e[0m"
elif [ $RSRQ -lt -20 ]; then
	echo -e "Reference Signal Received Quality(RSRQ):\e[1;33m$RSRQ\e[0m"
	echo -e "\e[1;31mRSRQ is Bad\e[0m"
else 
	echo -e "Reference Signal Received Quality(RSRQ):\e[1;31m$RSRQ\e[0m"
	echo -e "\e[1;41mRSRQ value is Unknown\e[0m"
fi
##############################################################################################
if [ $SINR -ge 20 ] && [ $SINR -lt 30 ]; then
	echo -e "Signal-to-Interference-plus-Noise Ratio(SINR): \e[1;32m$SINR\e[0m"
	echo -e "\e[1;32mSINR is Very Good\e[0m"
elif [ $SINR -ge 13 ] && [ $SINR -lt 20 ]; then
	echo -e "Signal-to-Interference-plus-Noise Ratio(SINR):\e[1;32m$SINR\e[0m"
	echo -e "\e[1;32mSINR is Good\e[0m"
elif [ $SINR -ge 0 ] && [ $SINR -lt 13 ]; then
	echo -e "Signal-to-Interference-plus-Noise Ratio(SINR):\e[1;33m$SINR\e[0m"
	echo -e "\e[1;33mSINR is Fair\e[0m"
elif [ $SINR -ge -20 ] && [ $SINR -lt 0 ]; then
	echo -e "Signal-to-Interference-plus-Noise Ratio(SINR):\e[1;33m$SINR\e[0m"
	echo -e "\e[1;31mSINR is Bad\e[0m"
else 
	echo -e "Signal-to-Interference-plus-Noise Ratio(SINR):\e[1;31m$SINR\e[0m"
	echo -e "\e[1;41mSINR value is Unknown\e[0m"
fi
##############################################################################################
echo -e "\e[1;34m####################################### Network status ##########################################\e[0m"
NWmode=$(/bin/at-cmd $comport at+qcfg="\"nwscanmode\"" | awk -F"," 'NR==2 {print $2}')
if [ $NWmode -eq 0 ]; then
	echo -e "Selected Network mode : \e[1;32mautomatic\e[0m"
elif [ $NWmode -eq 1 ]; then
	echo -e "Selected Network mode : \e[1;32mGSM\e[0m"
elif [ $NWmode -eq 2 ]; then
	echo -e "Selected Network mode : \e[1;32mWCDMA\e[0m"
elif [ $NWmode -eq 3 ]; then
	echo -e "Selected Network mode : \e[1;32mLTE\e[0m"
else
	echo -e "\e[1;41mUnknown band selcected\e[0m"
fi
operator=$(at-cmd $comport at+cops? | awk -F"," 'NR==2 {print$3}' | sed 's/"//g' )
QNWINFO=$(/bin/at-cmd $comport at+qnwinfo)
NWlatched=$(echo "$QNWINFO" | awk -F '"'  'NR==2 {print $2}')
Bandlatched=$(echo "$QNWINFO" | awk -F '"'  'NR==2 {print $6}')
echo -e "Network Latched : \e[1;32m$NWlatched \e[0m"
echo -e "Band Latched : \e[1;32m$Bandlatched\e[0m"
echo -e "Network operator : \e[1;32m$operator\e[0m"
echo -e "Operator MCC : \e[1;32m$MCC\e[0m"
echo -e "Operator MNC : \e[1;32m$MNC\e[0m"
##############################################################################################
if [ $UBW -eq 0 ] && [ $DBW -eq 0 ]; then
	echo -e "Upload Bandwidth is: \e[1;31m1.4MHz \e[0m"
	echo -e "Download Bandwidth is: \e[1;31m1.4MHz \e[0m"
elif [ $UBW -eq 1 ] && [ $DBW -eq 1 ]; then
	echo -e "Upload Bandwidth is: \e[1;31m3MHz \e[0m"
	echo -e "Download Bandwidth is: \e[1;31m3MHz \e[0m"
elif [ $UBW -eq 2 ] && [ $DBW -eq 2 ]; then
	echo -e "Upload Bandwidth is: \e[1;32m5MHz \e[0m"
	echo -e "Download Bandwidth is: \e[1;32m5MHz \e[0m"
elif [ $UBW -eq 3 ] && [ $DBW -eq 3 ]; then
	echo -e "Upload Bandwidth is: \e[1;32m10MHz \e[0m"
	echo -e "Download Bandwidth is: \e[1;32m10MHz \e[0m"
elif [ $UBW -eq 4 ] && [ $DBW -eq 4 ]; then
	echo -e "Upload Bandwidth is: \e[1;32m15MHz \e[0m"
	echo -e "Download Bandwidth is: \e[1;32m15MHz \e[0m"
elif [ $UBW -eq 5 ] && [ $DBW -eq 5 ]; then
	echo -e "Upload Bandwidth is: \e[1;32m20MHz \e[0m"
	echo -e "Download Bandwidth is: \e[1;32m20MHz \e[0m"
else
	echo -e "Upload Bandwidth is: \e[1;41mUnknown\e[0m"
	echo -e "Download Bandwidth is: \e[1;41mUnknown\e[0m"
fi
ACT=$(at-cmd $comport at+qiact=1)
IPADDR=$(at-cmd $comport at+qiact? | awk -F"," 'NR==2 {print$4}' | sed 's/"//g')
echo -e "Modem IP Address : \e[1;32m$IPADDR\e[0m"
APN=$(at-cmd $comport AT+cgdcont? | awk -F "," 'NR==2')
APNNAME=$(echo $APN | awk -F "," 'NR==1 {print$3}' | sed 's/"//g')
PDPTYPE=$(echo $APN | awk -F "," 'NR==1 {print$2}' | sed 's/"//g')
echo -e "APN in use : \e[1;32m$APNNAME\e[0m"
echo -e "\e[1;33mPDP list : IP->IPV4, PPP, IPV6, IPV4V6\e[0m"
echo -e "PDP in use : \e[1;32m$PDPTYPE\e[0m"

current_time=$(date +"%d-%m-%Y %T")
echo "Last Updated Date and Time is : $current_time"

}>/tmp/Mdebug1.txt

cat /tmp/Mdebug1.txt | sed 's/\x1B\[[0-9;]*[JKmsu]//g' > /tmp/Mdebug.txt




