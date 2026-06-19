#!/bin/sh

#
# PKG_RELEASE: 1.01
#

#
# Input arguments and Default Parameters
#
IntarfaceName="$1"
ModemManufacturer="$2"
ModemModel="$3"
InterfaceManagerTmpDir="/tmp/InterfaceManager/"
InterfaceManagerLogFileDir="$InterfaceManagerTmpDir""log/"
QueryModemAnalyticsOutputFile="$InterfaceManagerLogFileDir""$IntarfaceName""_QueryModemAnalyticsOutput"
QueryModemAnalyticsLogFile="$InterfaceManagerLogFileDir""QueryModemAnalyticsLog"
InterfaceManagerTmpAnalyticsDir="$InterfaceManagerTmpDir""analytics/"
ProcessGetsigAnalyticsFile="$InterfaceManagerTmpAnalyticsDir""$IntarfaceName"".ModemATAnalytics"
PortConfigFile="/tmp/InterfaceManager/status/""$IntarfaceName"".ports"

[ -d "$InterfaceManagerTmpDir" ] || mkdir "$InterfaceManagerTmpDir"
[ -d "$InterfaceManagerLogFileDir" ] || mkdir "$InterfaceManagerLogFileDir"
[ -d "$InterfaceManagerTmpAnalyticsDir" ] || mkdir "$InterfaceManagerTmpAnalyticsDir"

#
# Verify Input arguments
#
if [ "x$IntarfaceName" = "x" ]
then
    echo "usage: QueryModemStatus.sh InterfaceName"
    exit 1
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

#
# Find Communication Port
#
if [ -f "$PortConfigFile" ]
then
    ComPort=$(sed -n "/^\<ComPort\>/p" "$PortConfigFile" 2>&1 | cut -d "=" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//' 2>&1)
    if [ "x$ComPort" = "x" ]
    then
        echo "ComPort not found" > $QueryModemAnalyticsLogFile
        exit 1
    fi
else
    echo "ComPort file not found" > $QueryModemAnalyticsLogFile
    exit 1
fi


#
# Set Parameters to Default Values
#
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


#
# Query Modem status using gcom 
#
echo "$ComPort"
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

echo "$O" > "$QueryModemAnalyticsOutputFile"

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
if [ "x$MODE" = "x-" ]; then 
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

CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")

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
} > "$ProcessGetsigAnalyticsFile"
