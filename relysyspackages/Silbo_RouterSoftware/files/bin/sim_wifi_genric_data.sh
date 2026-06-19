#!/bin/sh

########################################
# DEFAULT VALUES
########################################
########################################
# DEFAULT VALUES
########################################
Inserted="NA"; Active="NA"; SimName="NA"
Networkmode="NA"; convert_percent="NA"; quality="NA"

Inserted2="NA"; Active2="NA"; SimName2="NA"
Networkmode2="NA"; convert_percent2="NA"; quality2="NA"

########################################
# HELPER FUNCTIONS
########################################

get_network_mode() {
    case "$1" in
        NSA|SA) echo "5G" ;;
        LTE) echo "4G" ;;
        EDGE|GPRS) echo "2G" ;;
        CDMA) echo "3G" ;;
        *) echo "NA" ;;
    esac
}

get_quality() {
    s="$1"
    if   [ "$s" -ge 80 ]; then echo "4"
    elif [ "$s" -ge 60 ]; then echo "3"
    elif [ "$s" -ge 40 ]; then echo "2"
    elif [ "$s" -ge 20 ]; then echo "1"
    elif [ "$s" -ge 1 ];  then echo "0"
    else echo "No Signal"
    fi
}

########################################
# CELLULAR SECTION
########################################

Cellular_check=$(uci -q get sysconfig.sysconfig.enablecellular)

if [ "$Cellular_check" = "1" ]; then

    simnum=$(cat /tmp/simnumfile 2>/dev/null)

    PinState=$(uci -q get modemstatus.modemstatus.PinState)
    Operator=$(uci -q get modemstatus.modemstatus.Operator)
    Connected=$(uci -q get modemstatus.modemstatus.Connected)
    SignalStrength=$(uci -q get modemstatus.modemstatus.signalstrengthstatus)

    if [ "$simnum" = "1" ] && [ "$PinState" = "READY" ]; then
        Inserted="true"
        Active="true"
        SimName="$Operator"
        Networkmode=$(get_network_mode "$Connected")
        convert_percent="$SignalStrength"

        strength_num=${SignalStrength%\%}
        case "$strength_num" in
            ''|*[!0-9]*) quality="NA" ;;
            *) quality=$(get_quality "$strength_num") ;;
        esac
    fi

    if [ "$simnum" = "2" ] && [ "$PinState" = "READY" ]; then
        Inserted2="true"
        Active2="true"
        SimName2="$Operator"
        Networkmode2=$(get_network_mode "$Connected")
        convert_percent2="$SignalStrength"

        strength_num=${SignalStrength%\%}
        case "$strength_num" in
            ''|*[!0-9]*) quality2="NA" ;;
            *) quality2=$(get_quality "$strength_num") ;;
        esac
    fi
fi

########################################
# BUILD SIM JSON
########################################

data="{
   \"Sim_Inserted\": \"$Inserted\",
   \"Sim_Active\": \"$Active\",
   \"Sim_Name\": \"$SimName\",
   \"Sim_Netmode\": \"$Networkmode\",
   \"Sim_Signalper\": \"$convert_percent\",
   \"Sim_quality\": \"$quality\",
   \"Sim_Inserted2\": \"$Inserted2\",
   \"Sim_Active2\": \"$Active2\",
   \"Sim_Name2\": \"$SimName2\",
   \"Sim_Netmode2\": \"$Networkmode2\",
   \"Sim_Signalper2\": \"$convert_percent2\",
   \"Sim_quality2\": \"$quality2\"
}"

########################################
# WIFI SECTION (FAST & RELIABLE)
########################################

# Capture ifconfig once (performance optimized)
IFCONFIG_DATA="$(ifconfig 2>/dev/null)"

# Defaults
wifitype="NA"
WIFI_STATUS="OFF"
wificlients=0

wifitype5="NA"
WIFI_STATUS5="OFF"
wificlients5=0

# ---------- 2.4GHz (ra0) ----------
if echo "$IFCONFIG_DATA" | grep -q "^ra0"; then
    wifitype="2.4GHz"
    WIFI_STATUS="ON"
    wificlients=$(ip neigh show dev ra0 2>/dev/null | wc -l)
fi

# ---------- 5GHz (wlan0 OR rai0) ----------
if echo "$IFCONFIG_DATA" | grep -q "^wlan0"; then
    wifitype5="5GHz"
    WIFI_STATUS5="ON"
    wificlients5=$(ip neigh show dev wlan0 2>/dev/null | wc -l)

elif echo "$IFCONFIG_DATA" | grep -q "^rai0"; then
    wifitype5="5GHz"
    WIFI_STATUS5="ON"
    wificlients5=$(ip neigh show dev rai0 2>/dev/null | wc -l)
fi

wifissidname=$(uci -q get sysconfig.wificonfig.wifi1ssid)
wifisecurity=$(uci -q get sysconfig.wificonfig.wifi1encryption)
wifichannel=$(uci -q get sysconfig.wificonfig.channelwidth)
[ "$wifichannel" = "0" ] && CHANNEL_WIDTH="0_20MHz" || CHANNEL_WIDTH="1_20/40MHZ"

wifissidname5=$(uci -q get sysconfig.wificonfig.wifi5ssid)
wifisecurity5=$(uci -q get sysconfig.wificonfig.wifi5encryption)
wifichannel5=$(uci -q get sysconfig.wificonfig.wifi5channelwidth)

wifi_data="{
   \"wifiv1_band\": \"$wifitype\",
   \"wifiv1_status\": \"$WIFI_STATUS\",
   \"wifiv1_ssid\": \"$wifissidname\",
   \"wifiv1_security\": \"$wifisecurity\",
   \"wifiv1_channel\": \"$CHANNEL_WIDTH\",
   \"wifiv1_con_client\": \"$wificlients\",
   \"wifiv5_band\": \"$wifitype5\",
   \"wifiv5_status\": \"$WIFI_STATUS5\",
   \"wifiv5_ssid\": \"$wifissidname5\",
   \"wifiv5_security\": \"$wifisecurity5\",
   \"wifiv5_channel\": \"$wifichannel5\",
   \"wifiv5_con_client\": \"$wificlients5\"
}"

########################################
# FINAL JSON
########################################

combined_json="{
   \"SIM\": $data,
   \"WIFI\": $wifi_data
}"

echo "$combined_json"

