#!/bin/sh
. /lib/functions.sh

if [ "$#" != "2" ]
then
    echo "Usage: $0 <Interface Name> <PayLoad>"
    exit 1
fi

Interface="$1"
PayLoad="$2"


ReAPMqttHost="localhost"
ReAPMqttSrcId="CN01-AI2DI4DO4_SG200"
ReAPMqttEventType="NWK"
ReAPMqttEventName="3G"
ReAPMqttPort="1883"
ReAPMqttQos="1"

ReAPMqttInterfaceAnalyzerPubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/Analyzer"
ReAPMqttAppDataReqStatusPubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/PER/WANAnalytics"
ReAPMqttNWKSSPubTopic="IOCard1/AI2DI4DO4_SG200/W/${Interface}/SigStrength"

InterfaceManagerTmpDir="/tmp/InterfaceManager/"
InterfaceManagerTmpStatusDir="${InterfaceManagerTmpDir}status/"

InterfaceManagerAnalyticsDir="/tmp/InterfaceManager/analytics/"
AnalyticsFile="${InterfaceManagerAnalyticsDir}${Interface}Analytics"

InterfaceManagerTmpConfigDir="${InterfaceManagerTmpDir}config/"
InterfaceConfigFile="${InterfaceManagerTmpConfigDir}${Interface}.cfg"
InterfaceAnalyzerStatusFile="${InterfaceManagerTmpStatusDir}${Interface}.Analyzerstatus"

InterfaceManagerTmpAnalyticsDir="${InterfaceManagerTmpDir}analytics/"
InterfaceAnalyticsFile="${InterfaceManagerTmpAnalyticsDir}${Interface}.InterfaceAnalytics"
ModemATAnalyticsFile="${InterfaceManagerTmpAnalyticsDir}${Interface}.ModemATAnalytics"

LogrotateConfigFile="/etc/logrotate.d/${Interface}LogrotateConfig"

. "$InterfaceConfigFile"

########################################################################
#       name:
#               IPAddressTest
#
#       Description:
#               Gets IpAddress of particular interface
#
#       Global:
#
#       Arguments:
#
#       Returns:
#               0 - on success
#               2 - If IPAddress not found
#
########################################################################
IPAddressTest ()
{
        IPAddress=$(ifconfig "$InterfaceName" 2>&1 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')

        if [ "x$IPAddress" = "x" ]
        then
            return 2
        fi

        return 0
}

########################################################################
#       name:
#               PingTest
#
#       Description:
#               ping configured IPAddress and parse PacketsTransmitted, PacketsReceived and PacketLoss.
#
#       Global:
#
#       Arguments:
#               none
#
#       Returns:
#               0 - on success
#               2 - on failure(if PacketLoss is not found or greater than MinPacketLoss )
#
########################################################################
PingTest()
{
        PingOutput=$(ping -c 1 -w 6 -I "$InterfaceName" "$PingIP" 2>&1)
        PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

        PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
        PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
        PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')

        if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -eq "100" ]
        then
            PingOutput=$(ping -c "$PacketCount" -w "$PingDeadline" -I "$InterfaceName" "$PingIP" 2>&1)
            PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

            PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
            PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
            PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')
        fi
        
        if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -ge "$MinPacketLoss" ]
        then
            return 2
        fi

        return 0
}

########################################################################
#       name:
#               InterfaceTest
#
#       Description:
#               Invokes IPAddressTest() and PingTest()
#
#       Global:
#
#       Arguments:
#
#       Returns:
#               0 - on success
#               1 - if IPAddressTestRetVal is 1
#               2 - if IPAddressTestRetVal/PingTestRetVal is 2
#
########################################################################
InterfaceTest ()
{
        ActionPerformed="-"
        ActionPerformedTime="-"
        PacketsTransmitted="-"
        PacketsReceived="-"
        PacketLoss="-"
        CSQ="-"
        CSQ_PER="-"
        CSQ_RSSI="-"
        MODEM="-"
        COPS="-"
        MODE="-"
        LAC="-"
        LAC_NUM="-"
        CID="-"
        CID_NUM="-"
        COPS_MCC="-"
        COPS_MNC="-"
        RNC="-"
        RNC_NUM="-"
        DOWN="-"
        UP="-"
        ECIO="-"
        RSCP="-"
        ECIO1="-"
        RSCP1="-"
        CELL="-"

        IPAddressTest
        IPAddressTestRetVal=$?
        if [ "$IPAddressTestRetVal" != "0" ]
        then
                IPAddress="-"
                return $IPAddressTestRetVal
        else
                if [ "$QueryModemATAnalytics" = "1" ]
                then
                        QueryModemAnalytics
                fi

                if [ "$PingTestEnable" != "1" ]
                then
                        RetVal=$IPAddressTestRetVal
                else
                        PingTest
                        PingTestRetVal=$?
                        if [ "x$PacketsTransmitted" = "x" ]
                        then
                                PacketsTransmitted="-"
                        fi

                        if [ "x$PacketsReceived" = "x" ]
                        then
                                PacketsReceived="-"
                        fi

                        if [ "x$PacketLoss" = "x" ]
                        then
                                PacketLoss="-"
                        fi
                        RetVal=$PingTestRetVal
                fi
                TempStatusLog
                return $RetVal
        fi
}

########################################################################
#       name:
#               QueryModemAnalytics
#
#       Description:
#               gets all the information of wan connection using AT commands in
#               /etc/atcmd.gcom file using gcom command
#
#       Global:
#               DebugLogMessages
#
#       Arguments:
#               none
#
#       Returns:
#
########################################################################
QueryModemAnalytics() {

    ResetVars="$1"
#    if echo "$PayLoadReq" | grep -qE "^[0-9]+$|^cron$"
#    then
        if [ "x$ResetVars" != "x" ] &&  [ "x$ResetVars" = "reset" ]
        then
                IPAddress="-"
                ActionPerformed="-"
                ActionPerformedTime="-"
                PacketsTransmitted="-"
                PacketsReceived="-"
                PacketLoss="-"
                CSQ="-"
                CSQ_PER="-"
                CSQ_RSSI="-"
                MODEM="-"
                COPS="-"
                MODE="-"
                LAC="-"
                LAC_NUM="-"
                CID="-"
                CID_NUM="-"
                COPS_MCC="-"
                COPS_MNC="-"
                RNC="-"
                RNC_NUM="-"
                DOWN="-"
                UP="-"
                ECIO="-"
                RSCP="-"
                ECIO1="-"
                RSCP1="-"
                CELL="-"
        fi

        PortConfigFile="/tmp/InterfaceManager/status/${Interface}.ports"
        if [ -f "$PortConfigFile" ]
        then
            ComPort=$(sed -n "/^\<ComPort\>/p" "$PortConfigFile" 2>&1 | cut -d "=" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//' 2>&1)
            if [ "x$ComPort" = "x" ]
            then
                    config_load "/etc/config/network"
                    config_get ComPort "$Interface" comport
                    if [ "x$ComPort" = "x" ]
                    then
                        #echo "ComPort not found in network file" >> "$InterfaceManagerLogFile"
                        return 0
                    fi
            fi
        else
                #echo "port file '$PortConfigFile' file not found" >> "$InterfaceManagerLogFile"
                ComPort=""
                config_load "/etc/config/network"
                config_get ComPort "$Interface" comport
                if [ "x$ComPort" = "x" ]
                then
                    #echo "ComPort not found in network file" >> "$InterfaceManagerLogFile"
                    return 0
                fi
        fi
        


        # Select GcomScript
        case "$ModemManufacturer" in
                        "fibocom")
                                case "$ModemModel" in
                                        "H330S")
                                                GcomScript="/etc/fibocomatcmd.gcom"
                                        ;;
                                esac
                        ;;
                        "huawei")
                                case "$ModemModel" in
                                        "MU609")
                                               GcomScript="/etc/huaweiatcmd.gcom"
                                        ;;
                                esac
                        ;;
                        *)
                                GcomScript="/etc/huaweiatcmd.gcom"
                        ;;
        esac



        OX=$(gcom -d "$ComPort" -s "$GcomScript" 2>/dev/null)
        M6=$(echo "$OX" | sed -e "s/      / /g")
        M5=$(echo "$M6" | sed -e "s/     / /g")
        M4=$(echo "$M5" | sed -e "s/    / /g")
        M3=$(echo "$M4" | sed -e "s/   / /g")
        M2=$(echo "$M3" | sed -e "s/  / /g")
        M2=$(echo "$M2" | sed -e "s/TAC:/   /;s/Tx Power:/   /;s/SINR/   /;s!SYSINFOEX:!SYSINFOEX: !;s!CNTI:!CNTI: !")
        M1=$(echo "$M2" | sed -e "s!Car0 Tot Ec/Io!+ECIO!;s!Car1 Tot Ec/Io!+ECIO1!;s!Car0 RSCP!+RSCP!;s!+CGMM: !!")
        M2=$(echo "$M1" | sed -e "s!Car1 RSCP!+RSCP1!;s!CSNR:!CSNR: !;s!RSSI (dBm):!RSSI4: !;s!AirCard !AirCard!;s!USB !USB!")
        M3=$(echo "$M2" | sed -e "s!RSRP (dBm):!RSRP4: !;s!RSRQ (dB):!RSRQ4: !;s!LTERSRP:!LTERSRP: !;s!Model:!+MODEL:!")
        M=$(echo "$M3" | sed -e "s!RX level Carrier 0 (dBm):!RSSI3: !;s!RX level Carrier 1 (dBm):!RSSI13: !;s!  ! !g")
        O=$M

        echo "$O" > "/tmp/InterfaceManager/log/""$Interface""_GcomOutput"

        CSQ=$(echo "$O" | awk -F[,\ ] '/^\+CSQ/ {print $2}')

        [ "x$CSQ" = "x" ] && CSQ=-1
        if [ $CSQ -ge 0 -a $CSQ -le 31 ]; then
                CSQ_PER=$(($CSQ * 100/31))
                CSQ_RSSI=$((2 * CSQ - 113))
                CSQX=$CSQ_RSSI
                [ $CSQ -eq 0 ] && CSQ_RSSI="<= "$CSQ_RSSI
                [ $CSQ -eq 31 ] && CSQ_RSSI=">= "$CSQ_RSSI
                CSQ_PER=$CSQ_PER"%"
                CSQ_RSSI=$CSQ_RSSI" dBm"
        else
                CSQ="-"
                CSQ_PER="-"
                CSQ_RSSI="-"
        fi

#sierra

        ECIO=$(echo "$O" | awk -F[\ ] '/^\+ECIO:/ {print $2}')
        [ "x$ECIO" = "x" ] && ECIO="-"
        ECIO1=$(echo "$O" | awk -F[\ ] '/^\+ECIO1:/ {print $2}')
        [ "x$ECIO1" = "x" ] && ECIO1="-"
        [ "$ECIO1" = "n/a" ] && ECIO1="-"

        RSCP=$(echo "$O" | awk -F[\ ] '/^\+RSCP:/ {print $2}')
        [ "x$RSCP" = "x" ] && RSCP="-"
        RSCP1=$(echo "$O" | awk -F[\ ] '/^\+RSCP1:/ {print $2}')
        [ "x$RSCP1" = "x" ] && RSCP1="-"
        [ "$RSCP1" = "n/a" ] && RSCP1="-"

        RSSI3=$(echo "$O" | awk -F[\ ] '/^\RSSI3:/ {print $2}')
        if [ "x$RSSI3" != "x" ]; then
                CSQ_RSSI=$RSSI3" dBm"
        else
                if [ "$ECIO" != "-" -a "$RSCP" != "-" ]; then
                        EX=$(printf %.0f $ECIO)
                        CSQ_RSSI=`expr $RSCP - $EX`
                        CSQ_RSSI=$CSQ_RSSI" dBm"
                fi
        fi

        RSSI4=$(echo "$O" | awk -F[\ ] '/^\RSSI4:/ {print $2}')
        if [ "x$RSSI4" != "x" ]; then
                CSQ_RSSI=$RSSI4" dBm"
                RSRP4=$(echo "$O" | awk -F[\ ] '/^\RSRP4:/ {print $2}')
                if [ "x$RSRP4" != "x" ]; then
                        RSCP=$RSRP4" (RSRP)"
                        RSRQ4=$(echo "$O" | awk -F[\ ] '/^\RSRQ4:/ {print $2}')
                        if [ "x$RSRQ4" != "x" ]; then
                                ECIO=$RSRQ4" (RSRQ)"
                        fi
                fi
        fi

#zte

        ZRSSI=$(echo "$O" | awk -F[,\ ] '/^\+ZRSSI/ {print $2}')
        if [ "x$ZRSSI" != "x" ]; then
                TMP_RSSI=$CSQ_RSSI
                CSQ_RSSI="-"$ZRSSI" dBm"
                ECI=$(echo "$O" | awk -F[,\ ] '/^\+ZRSSI/ {print $3}')
                if [ "x$ECI" != "x" ]; then
                        ECIO=`expr $ECI / 2`
                        ECIO="-"$ECIO
                        RSCP=$(echo "$O" | awk -F[,\ ] '/^\+ZRSSI/ {print $4}')
                        if [ "x$RSCP" != "x" ]; then
                                RSCP=`expr $RSCP / 2`
                                RSCP="-"$RSCP
                        else
                                CSQ_RSSI=$TMP_RSSI
                                RSCP=$ZRSSI
                                ECIO=$ECI
                        fi
                else
                        RSCP=$ZRSSI
                        CSQ_RSSI=$TMP_RSSI
                        ECIO=`expr $RSCP - $CSQX`
                fi
        fi

#huawei

        CSNR=$(echo "$O" | awk -F[,\ ] '/^\^CSNR/ {print $2}')
        if [ "x$CSNR" != "x" ]; then
                RSCP=$CSNR
                CSNR=$(echo "$O" | awk -F[,\ ] '/^\^CSNR/ {print $3}')
                if [ "x$CSNR" != "x" ]; then
                        ECIO=$CSNR
                else
                        ECIO=`expr $RSCP - $CSQX`
                fi
        else
                EC=$(echo "$O" | awk -F[,\ ] '/^\+CSQ/ {print $4}')
                if [ "x$EC" != "x" ]; then
                        ECIO=$EC
                        EX=$(printf %.0f $ECIO)
                        RSCP=`expr $CSQX + $EX`
                fi
        fi

        LTERSRP=$(echo "$O" | awk -F[,\ ] '/^\^LTERSRP/ {print $2}')
        if [ "x$LTERSRP" != "x" ]; then
                RSCP=$LTERSRP" (RSRP)"
                LTERSRP=$(echo "$O" | awk -F[,\ ] '/^\^LTERSRP/ {print $3}')
                if [ "x$LTERSRP" != "x" ]; then
                        ECIO=$LTERSRP" (RSRQ)"
                else
                        ECIO=`expr $RSCP - $CSQX`
                fi
        fi
#Modem
        CELL="1"
        MODEM=$(echo "$O" | awk -F[:] '/DEVICE/ { print $2}')
        if [ "x$MODEM" = "x" ]; then
                CELL="0"
                MODEM="Unknown"
        else
                MODEL=$(echo "$O" | awk -F[,\ ] '/^\+MODEL/ {print $2}')
                if [ "x$MODEL" != "x" ]; then
                        MODEL=$(echo "$MODEL" | sed -e 's/"//g')
                        MODEM=$MODEM" "$MODEL
                fi
        fi

#fibocom
        MODEMMANUFACTURER=$(echo "$O" | awk -F[\"] '/^\+FMI/ { print $2}')
        if [ "x$MODEMMANUFACTURER" != "x" ]
        then
                MODEMMODEL=$(echo "$O" | awk -F[,] '/^\+FMM:/ {print $NF}' | tr -d \")
                if [ "x$MODEMMODEL" != "x" ]
                then
                        MODEM="${MODEMMANUFACTURER} ${MODEMMODEL}"
                else
                        MODEM="${MODEMMANUFACTURER}"
                fi
        fi

#cellular type
        CT=`echo $MODEL | tr '[A-Z]' '[a-z]'`
        if echo $CT | grep -q "320u"; then
                CELL="2"
        else
                if echo $CT | grep -q "e3276"; then
                        CELL="3"
                else
                        if echo $CT | grep -q "e398"; then
                                CELL="3"
                        else
                                if echo $CT | grep -q "e389"; then
                                        CELL="3"
                                else
                                        if echo $CT | grep -q "e392"; then
                                                CELL="3"
                                        else
                                                if echo $CT | grep -q "mf821"; then
                                                        CELL="3"
                                                else
                                                        if echo $CT | grep -q "mf820"; then
                                                                CELL="3"
                                                        else
                                                                if echo $CT | grep -q "330u"; then
                                                                        CELL="2"
                                                                else
                                                                        if echo $CT | grep -q "k5005"; then
                                                                                CELL="3"
                                                                        else
                                                                                if echo $CT | grep -q "e397"; then
                                                                                        CELL="3"
                                                                                else
                                                                                        if echo $CT | grep -q "e8278"; then
                                                                                                CELL="3"
                                                                                        else
                                                                                                if echo $CT | grep -q "k5006"; then
                                                                                                        CELL="3"
                                                                                                fi
                                                                                        fi
                                                                                fi
                                                                        fi
                                                                fi
                                                        fi
                                                fi
                                        fi
                                fi
                        fi
                fi
        fi

        COPS=$(echo "$O" | awk -F[\"] '/^\+COPS: 0,2/ {print $2}')
        if [ "x$COPS" = "x" ]; then
                COPS="-"
                COPS_MCC="-"
                COPS_MNC="-"
        else
                COPSO=$COPS
                COPS_MCC=${COPS:0:3}
                COPS_MNC=${COPS:3:3}
                COPS=$(awk -F[\;] '/'$COPS'/ {print $2}' /etc/mccmnc)
                [ "x$COPS" = "x" ] && COPS=$COPSO
        fi

        if [ "$COPS" = "-" ]; then
                COPS=$(echo "$O" | awk -F[\"] '/^\+COPS: 0,0/ {print $2}')
                if [ "x$COPS" = "x" ]; then
                        COPS="-"
                        COPS_MCC="-"
                        COPS_MNC="-"
                fi
        fi
        COPS_MNC=$COPS_MNC

        MODE="-"

# Huawei
        TECH=$(echo "$O" | awk -F[,] '/^\^SYSINFOEX/ {print $9}' | sed 's/"//g')
        if [ "x$TECH" != "x" ]; then
                MODE="$TECH"
        fi

# Huawei
        if [ "x$MODE" = "x-" ];
        then
                TECH=$(echo "$O" | awk -F[,\] '/^\^SYSINFO:/ {print $7}')
                if [ "x$TECH" != "x" ]; then
                        case $TECH in
                                0) MODE="No services";;
                                1) MODE="GSM";;
                                2) MODE="GPRS";;
                                3) MODE="EDGE";;
                                4) MODE="WCDMA";;
                                5) MODE="HSDPA";;
                                6) MODE="HSUPA";;
                                7) MODE="HSUPA and HSDPA";;
                                8) MODE="TD_SCDMA";;
                                9) MODE="HSPA";;
                                10) MODE="EVDO Rev.0";;
                                11) MODE="EVDO Rev.A";;
                                12) MODE="EVDO Rev.B";;
                                13) MODE="1xRTT";;
                                14) MODE="UMB";;
                                15) MODE="1xEVDV";;
                                16) MODE="3xRTT";;
                                17) MODE="HSPA (64QAM)";;
                                18) MODE="HSPA (MIMO)";;
                                 *) MODE=$TECH;;
                        esac
                fi
        fi

# Fibocom
        XREG=$(echo "$O" | awk -F[,\ ] '/^\+XREG/ {print $3}')
        if [ "x$XREG" != "x" ]
        then
                case $XREG in
                    0) MODE="Not Registered";;
                    1) MODE="GPRS";;
                    2) MODE="EDGE";;
                    3) MODE="WCDMA";;
                    4) MODE="HSDPA";;
                    5) MODE="HSUPA";;
                    6) MODE="HSUPA & HSDPA";;
                    7) MODE="GSM";;
                    8) MODE="HSPA+";;
                    *) MODE="$XREG";;
                esac
        fi

# ZTE
        if [ "x$MODE" = "x-" ]; then
                TECH=$(echo "$O" | awk -F[,\ ] '/^\+ZPAS/ {print $2}' | sed 's/"//g')
                if [ "x$TECH" != "x" -a "x$TECH" != "xNo" ]; then
                        MODE="$TECH"
                fi
        fi

# Sierra
        if [ "x$MODE" = "x-" ]; then
                TECH=$(echo "$O" | awk -F[,\ ] '/^\*CNTI/ {print $3}' | sed 's|/|,|g')
                if [ "x$TECH" != "x" ]; then
                        MODE="$TECH"
                fi
        fi

# CREG
        CREG="+CREG"
        LAC=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
        if [ "x$LAC" = "x" ]; then
            CREG="+CGREG"
            LAC=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
        fi

        if [ "x$LAC" != "x" ]; then
                LAC_NUM=$(printf %d 0x$LAC)
        else
                LAC="-"
                LAC_NUM="-"
        fi
        LAC_NUM="("$LAC_NUM")"

        CID=$(echo "$O" | awk -F[,] '/\'$CREG'/ {printf "%s", toupper($4)}' | sed 's/[^A-F0-9]//g')
        if [ "x$CID" != "x" ]; then
                if [ ${#CID} -le 4 ]; then
                        LCID="-"
                        LCID_NUM="-"
                        RNC="-"
                        RNC_NUM="-"
                else
                        LCID=$CID
                        LCID_NUM=$(printf %d 0x$LCID)
                        RNC=$(echo "$LCID" | awk '{print substr($1,1,length($1)-4)}')
                        RNC_NUM=$(printf %d 0x$RNC)
                        CID=$(echo "$LCID" | awk '{print substr($1,length(substr($1,1,length($1)-4))+1)}')
                        RNC_NUM="($RNC_NUM)"
                fi

                CID_NUM=$(printf %d 0x$CID)
        else
                LCID="-"
                LCID_NUM="-"
                RNC="-"
                RNC_NUM="-"
                CID="-"
                CID_NUM="-"
        fi
        CID_NUM="("$CID_NUM")"

        DOWN=$(echo "$O" | awk -F[,] '/\+CGEQNEG/ {printf "%s" $4}')
        if [ "x$DOWN" != "x" ]; then
                UP=$(echo "$O" | awk -F[,] '/\+CGEQNEG/ {printf "%s" $3}')
                DOWN=$DOWN" kbps"
                UP=$UP" kbps"
        else
                DOWN="-"
                UP="-"
        fi
#    fi
}

########################################################################
#       name:
#               StatusLog
#
#       Description:
#               writing status log messages into particular file.
#
#       Global:
#
#       Arguments:
#
#       Returns:
########################################################################
StatusLog()
{
        if [ "$LogAnalytics" = "1" ]
        then
            local CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")

echo "{\"LT\":\"$CurrentDate\",\"IF\":\"$InterfaceName\",\"SS\":\"$CSQ_PER\",\"NM\":\"$MODE\",\
\"PL\":\"$PacketLoss\",\"PT\":\"$PacketsTransmitted\",\"PR\":\"$PacketsReceived\"\
}"  >> "$AnalyticsFile"

            logrotate "$LogrotateConfigFile"
        fi

        TempStatusLog "$CurrentDate"
}

########################################################################
#       name:
#               TempStatusLog
#
#       Description:
#               writting status log messages into a temp file.
#
#       Global:
#
#       Arguments:
#
#       Returns:
########################################################################
TempStatusLog()
{
    if [ "x$1" != "x" ]
    then
        local CurrentDate="$1"
    else
        local CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    fi

    {
        echo "{"
        echo "\"logtime\":\"$CurrentDate\","
        echo "\"InterfaceName\":\"$InterfaceName\","
        echo "\"IPAddress\":\"$IPAddress\","
        echo "\"PacketLoss\":\"$PacketLoss\","
        echo "\"PacketsTransmitted\":\"$PacketsTransmitted\","
        echo "\"PacketsReceived\":\"$PacketsReceived\""
        echo "}"
    } > "$InterfaceAnalyticsFile"

    # To stop updating, if modem-analytics is previously updated by web-page
    if [ "$QueryModemATAnalytics" = "1" ]
    then
        {
            echo "{"
            echo "\"logtime\":\"$CurrentDate\","
            echo "\"CSQ\":\"$CSQ\","
            echo "\"CSQ_PER\":\"$CSQ_PER\","
            echo "\"CSQ_RSSI\":\"$CSQ_RSSI\","
            echo "\"MODEM\":\"$MODEM\","
            echo "\"COPS\":\"$COPS\","
            echo "\"MODE\":\"$MODE\","
            echo "\"LAC\":\"$LAC\","
            echo "\"LAC_NUM\":\"$LAC_NUM\","
            echo "\"CID\":\"$CID\","
            echo "\"CID_NUM\":\"$CID_NUM\","
            echo "\"COPS_MCC\":\"$COPS_MCC\","
            echo "\"COPS_MNC\":\"$COPS_MNC\","
            echo "\"RNC\":\"$RNC\","
            echo "\"RNC_NUM\":\"$RNC_NUM\","
            echo "\"DOWN\":\"$DOWN\","
            echo "\"UP\":\"$UP\","
            echo "\"ECIO\":\"$ECIO\","
            echo "\"RSCP\":\"$RSCP\","
            echo "\"ECIO1\":\"$ECIO1\","
            echo "\"RSCP1\":\"$RSCP1\","
            echo "\"CELL\":\"$CELL\""
            echo "}"
        } > "$ModemATAnalyticsFile"
    fi
}

PublishNwkStatusToISM()
{
    ReAPMqttIFStatus="$1"
    ReAPMqttAppId="3"
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    ReAPMqttMsg="<,$ReAPMqttAppId,$ReAPMqttIFStatus,$IPAddress,$PingTestRetVal,$CurrentDate,>"
    
    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttInterfaceAnalyzerPubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos 2>&1)
    retval=$?
}

PublishAppDataReqStatus()
{
    ReAPMqttWanStatus="$1"
    ReAPMqttRecType="0"
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    TxStatus="0"
    TxTimeStamp="\"0\""
    
    CSQ_PER2=$(echo "$CSQ_PER" | tr '\%' '\0')
    
    if [ "$CSQ_PER2" = "-" ]
    then
        CSQ_PER2="NA"
    fi
    
    MODE2="$MODE"
    
    if [ "$MODE2" = "-" ]
    then
        MODE2="NA"
    fi
    
    PacketLoss2="$PacketLoss"
    
    if [ "$PacketLoss2" = "-" ]
    then
        PacketLoss2="NA"
    fi
    
    ReAPMqttMsg="\"<\",\"$ReAPMqttSrcId\",$ReAPMqttAppDataReqId,\"$ReAPMqttWanStatus\",\"$CSQ_PER2\",\"$MODE2\",\"$PacketLoss2\",\"$CurrentDate\",$TxStatus,$TxTimeStamp,\">\""
    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttAppDataReqStatusPubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos 2>&1)
    retval=$?
    
}


PublishSStoLCD()
{
    CSQ_PER2=$(echo "$CSQ_PER" | tr '\%' '\0')
    
    if [ "$CSQ_PER2" = "-" ] || [ "X$CSQ_PER2" = "X" ]
    then
        CSQ_PER2="NA"
    fi
    
    ReAPMqttEventName="SS"
    ReAPMqttEventValue="$CSQ_PER2"
    CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
    ReAPMqttMsg="<,$ReAPMqttSrcId,$ReAPMqttEventType,$ReAPMqttEventName,$ReAPMqttEventValue,$CurrentDate,>"
    output=$(mosquitto_pub -h "$ReAPMqttHost" -p "$ReAPMqttPort" -t "$ReAPMqttNWKSSPubTopic" -m "$ReAPMqttMsg" -q $ReAPMqttQos)
    retval=$?
}
                    
#start of script
if [ ! -d "$InterfaceManagerTmpStatusDir" ]
then
    mkdir -p "$InterfaceManagerTmpStatusDir"
fi

if [ ! -d "$InterfaceManagerTmpAnalyticsDir" ]
then
    mkdir -p "$InterfaceManagerTmpAnalyticsDir"
fi

if [ ! -d "$InterfaceManagerAnalyticsDir" ]
then
    mkdir -p "$InterfaceManagerAnalyticsDir"
fi
   
InterfaceManagerAppId=$(echo "$PayLoad" | awk -F[,] '{ print $2 }')
if [ "$InterfaceManagerAppId" = "3" ]
then
    PayLoadReq=$(echo "$PayLoad" | awk -F[,] '{ print $3 }')
    ReAPMqttAppDataReqId="$PayLoadReq"
    
    if echo "$PayLoadReq" | grep -qE "^[0-9]+$|^ifup$|^cron$"
    then
        if [ "$DataTestEnable" = "1" ]
        then
            InterfaceTest
            InterfaceTestRetVal=$?
            
            if [ "$InterfaceTestRetVal" = "0" ]
            then
                echo "InterfaceStatus=1" > "$InterfaceAnalyzerStatusFile"
                echo "IPAddress=$IPAddress" >> "$InterfaceAnalyzerStatusFile"
                StatusLog
                PublishNwkStatusToISM "UP" #publishing nwk status to InterfaceStatusmanager
                PublishAppDataReqIFStatus="UP"
            elif [ "$InterfaceTestRetVal" = "2" ]
            then
                echo "InterfaceStatus=0" > "$InterfaceAnalyzerStatusFile"
                echo "IPAddress=$IPAddress" >> "$InterfaceAnalyzerStatusFile"
                StatusLog
                PublishNwkStatusToISM "DN" #publishing nwk status to InterfaceStatusmanager
                PublishAppDataReqIFStatus="DN"
            fi
                
            if echo "$PayLoadReq" | grep -qE "^[0-9]+$"
            then
                PublishAppDataReqStatus "$PublishAppDataReqIFStatus"
            fi
            
            if [ "$QueryModemATAnalytics" = "1" ]
            then
                PublishSStoLCD #publish sig strength to display client
            fi 
        else
            if [ "$QueryModemATAnalytics" = "1" ]
            then
                QueryModemAnalytics "reset"
                PublishSStoLCD #publish sig strength to display client
            fi
            StatusLog
            TempStatusLog
        fi
    elif echo "$PayLoadReq" | grep -qE "^ss$"
    then
        if [ "$QueryModemATAnalytics" = "1" ]
        then
            QueryModemAnalytics "reset"
            PublishSStoLCD #publish sig strength to display client
        fi        
    fi
fi

exit 0
