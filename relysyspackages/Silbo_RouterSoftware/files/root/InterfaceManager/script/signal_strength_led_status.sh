#!/bin/sh

. /lib/functions.sh

#Here, we take two argument:- (1). RSRP: signal strength value , (2). modem_number: which modem is want to update 
RSRP="$1"
modem_number="$2"

#Here, we set the percentage of signalstrengthstatus acc. to the signal strength (RSRP) given by Update_Analytics_data.sh script.
if [ "$RSRP" -eq "-115" ] || [ "$RSRP" -eq "-114" ];then
	signalstrengthstatus="25%"
elif [ "$RSRP" -eq "-113" ] || [ "$RSRP" -eq "-112" ];then
	signalstrengthstatus="30%"
elif [ "$RSRP" -eq "-111" ] || [ "$RSRP" -eq "-110" ];then
	signalstrengthstatus="35%"
elif [ "$RSRP" -eq "-109" ] || [ "$RSRP" -eq "-108" ];then
	signalstrengthstatus="40%"
elif [ "$RSRP" -eq "-107" ] || [ "$RSRP" -eq "-106" ];then
	signalstrengthstatus="45%"
elif [ "$RSRP" -eq "-105" ] || [ "$RSRP" -eq "-104" ];then
	signalstrengthstatus="50%"
elif [ "$RSRP" -eq "-103" ] || [ "$RSRP" -eq "-102" ];then
	signalstrengthstatus="55%"
elif [ "$RSRP" -eq "-101" ] || [ "$RSRP" -eq "-100" ];then
	signalstrengthstatus="60%"
elif [ "$RSRP" -eq "-99" ] || [ "$RSRP" -eq "-98" ];then
	signalstrengthstatus="65%"
elif [ "$RSRP" -eq "-97" ] || [ "$RSRP" -eq "-96" ];then
	signalstrengthstatus="70%"
elif [ "$RSRP" -ge "-95" ] && [ "$RSRP" -le "-86" ];then
	signalstrengthstatus="75%"
elif [ "$RSRP" -ge "-85" ] && [ "$RSRP" -le "-76" ];then
	signalstrengthstatus="80%"
elif [ "$RSRP" -ge "-75" ] && [ "$RSRP" -le "-66" ];then
	signalstrengthstatus="85%"
elif [ "$RSRP" -ge "-65" ] && [ "$RSRP" -le "-56" ];then
	signalstrengthstatus="90%"
elif [ "$RSRP" -ge "-55" ] && [ "$RSRP" -le "-46" ];then
	signalstrengthstatus="95%"
elif [ "$RSRP" -ge "-45" ] && [ "$RSRP" -le "-1" ];then
	signalstrengthstatus="100%"
else
	signalstrengthstatus="NA"
fi

#Here, we set the value of signalstrengthstatus acc. to modem_number.
if [ "$modem_number" = "1" ];then
	uci set modemstatus.modemstatus.signalstrengthstatus="$signalstrengthstatus"
elif [ "$modem_number" = "2" ];then
	uci set modemstatus.modemstatus.signalstrengthstatus2="$signalstrengthstatus"
fi

uci commit modemstatus
