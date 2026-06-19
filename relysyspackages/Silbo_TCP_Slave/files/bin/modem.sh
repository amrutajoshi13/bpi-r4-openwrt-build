#!/bin/ash -f

# Function to get a value from AT command response
get_at_value_1() {
    at-cmd /dev/ttyUSB2 "$1" | awk -F"," 'NR==2 {print$1}' | sed 's/"//g'
}

get_at_value() {
    at-cmd /dev/ttyUSB2 "$1" | awk -F',' 'NR==2 {gsub(/"/,"",$2); print $2}'
}

# Function to get modem information
get_modem_info() {
    modemNum=$(at-cmd /dev/ttyUSB2 ATI | awk '/Revision:/ {print $2}' )
    mImei=$(uci get boardconfig.board.imei)
	mwifimacid=$(uci get boardconfig.board.wifimacid)
	mwanmacid=$(uci get boardconfig.board.wanmacid)
	mlanmacid=$(uci get boardconfig.board.lanmacid)
    mModel=$(uci get modem.CWAN1.model)
    mManufacturer=$(get_at_value_1 'AT+GMI')
    mSerial=$(get_at_value_1 'AT+CGSN')
    mIMSI=$(get_at_value_1 'AT+CIMI')
    (get_at_value_1 AT+COPS=0,1)
    mOperator=$(awk -F',' '{print $1}' /tmp/ModemAnalytics.txt)
    (get_at_value_1 AT+COPS=0,2)
   mOperatorNumber=$(awk -F',' '{print $4}' /tmp/ModemAnalytics.txt)
}

# Function to get network information
get_network_info() {
    mSimState=$(cat /tmp/simnumfile)
    msent=$(at-cmd /dev/ttyUSB2 AT+QGDCNT? | awk -F'[ ,"]' '/\+QGDCNT:/ {print $2}')
    mreceived=$( at-cmd /dev/ttyUSB2 AT+QGDCNT? | awk -F'[ ,"]' '/\+QGDCNT:/ {print $3}')
    mIP=$(get_at_value 'AT+CGPADDR' 2)
    #mOperator=$(get_at_value 'AT+COPS?' 3)
    mConnectionType=$(awk -F',' '{print $2}' /tmp/ModemAnalytics.txt)
	
	if [ "$mConnectionType" != "" ]
    then
    mConnectionState="CONNECTED"
	else
    mConnectionState="NOT_CONNECTED"
fi

}

# Function to get SIM and connection information
get_sim_connection_info() {
    mPinState=$(at-cmd /dev/ttyUSB2 AT+CPIN? | awk -F'[ ,"]' '/\+CPIN:/ {print $2}')
    mICCID=$(uci get system.system.qccid)
    mSignal=$(at-cmd /dev/ttyUSB2 AT+CSQ | awk -F'[ ,"]' '/\+CSQ:/ {print $2}')
    mCellID=$(awk -F',' '{print $7}' /tmp/ModemAnalytics.txt)
}

# Function to get additional information
get_additional_info() {
    	mRevision=$(at-cmd /dev/ttyUSB2 ati | awk '/Revision:/ {print $2}' ) 
	index=$(uci get modem.cellularmodule.singlesimsinglemodule)
	index2=$(uci get modem.cellularmodule.dualsimsinglemodule)
	index3=$(uci get modem.cellularmodule.singlesimdualmodule)
	#index4=$(uci get modem.cellularmodule.dualsimdualmodule)

	if [ $index -eq 1 ] || [ $index2 -eq 1 ]; then
    		mIndex=1
	elif [ $index3 -eq 1 ]; then
    		mIndex=2
fi

	if [ $index -eq 1 ] || [ $index3 -eq 1 ]; then
    		nofsim=1
	elif [ $index2 -eq 1 ]; then
    		nofsim=2
fi
		
	    # mRSRP=$(awk -F',' '{print $16}' /tmp/ModemAnalytics.txt)
        mRSRP=$(uci get modemstatus.modemstatus.RSRP)
    	mSINR=$(awk -F',' '{print $15}' /tmp/ModemAnalytics.txt)
    	mRSRQ=$(awk -F',' '{print $17}' /tmp/ModemAnalytics.txt)
        mRSSI=$(uci get modemstatus.modemstatus.RSSI)
}

# Function to store values in a file
store_values() {
    {
        echo "mIndex=$mIndex"
	    echo "simno=$nofsim"
        echo "mDescr=$mModel"
        echo "mImei=$mImei"
        echo "mManufacturer=$mManufacturer"
        echo "mIMSI=$mIMSI"
        echo "mSimState=$mSimState"
        echo "mNetState=$mSimState"
        echo "mSignal=$mSignal"
        echo "mOperatorname=$mOperator"
        echo "mOperatorNumber=$mOperatorNumber"
        echo "mCellID=$mCellID"
        echo "mSentToday=$msent"
        echo "mReceivedToday=$mreceived"
        echo "msent=$msent"
        echo "mreceived=$mreceived"
        echo "mConnectionState=$mConnectionState"
        echo "mConnectionType=$mConnectionType"
        echo "mSINR=$mSINR"
        echo "mRSRP=$mRSRP"
        echo "mRSRQ=$mRSRQ"
        echo "mRSSI=$mRSSI"
        echo "mIP=$mIP"
        echo "mwifimacid=$mwifimacid"
        echo "mwanmacid=$mwanmacid"
        echo "mlanmacid=$mlanmacid"
        echo "mICCID=$mICCID"
    } | tr -d '\r' > /root/TCPSLAVE/etc/Config/modem_info.txt
}
    get_modem_info
    get_network_info
    get_sim_connection_info
    get_additional_info
    store_values
