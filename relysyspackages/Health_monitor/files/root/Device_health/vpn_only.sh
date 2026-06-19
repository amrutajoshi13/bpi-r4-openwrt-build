#!/bin/sh

# ======================================================
# VPN DISABLE FUNCTION
# ======================================================
disable_vpn() {
    local REVOKE_URL="$1"
    local REASON="$2"
 
    echo "$(date '+%Y-%m-%d %H:%M:%S') Disabling VPN: $REASON" >> "$LOG_FILE"
 
    revoke_resp=$(curl -k -H 'Content-Type: application/json' \
        -d "{\"device_uuid\":\"$device_uuid\",\"num\":\"2\"}" \
        -X POST "$REVOKE_URL/api/ovpncertificate/")
 
    echo "[DEBUG] Revoke response: $revoke_resp" >> "$DEBUG_LOG"
 
    send_mqtt_message "VPN disabled: $REASON"
 
    rm -f "/etc/openvpn/${device_uuid}.ovpn"
    sh /root/InterfaceManager/script/vpn/openvpn/openvpn_handler.sh stop
 
    uci set vpnconfig1.general.enableopenvpngeneral="0"
    uci commit vpnconfig1
    uci delete openvpn.vpnnew
    uci commit openvpn

    # firewall zone remove tun openvpn
    uci delete firewall.openvpn
    uci commit firewall

    rm -f "$STATE_FILE"
 
    exit 0
}

# openvpn file check if it is only this will execute
if [ -f /root/openvpn_timer.txt ]; then
    TOTAL_DURATION=3000
    INTERVAL=10               
    MAX_COUNT=$((TOTAL_DURATION / INTERVAL))
    echo "Resuming OpenVPN timer from COUNT"
    COUNT=$(cat "/root/openvpn_timer.txt")
    while [ $COUNT -lt $MAX_COUNT ]; do
            sleep $INTERVAL
            COUNT=$((COUNT + 1))
            echo "$COUNT" > "/root/openvpn_timer.txt"
    done
    echo "OPENVPN REACHED THE END TIME"
    rm -f "/root/openvpn_timer.txt"
    API_URL=$(uci get cloudconfigNH.cloudconfigNH.HTTPcustomURL 2>/dev/null)
    API_URL="${API_URL:-}"
    disable_vpn "$API_URL" "VPN session completed"
fi
# ======================================================
# ARGUMENTS
# ======================================================
recive_id="$1"
topic="$2"
MQTT_HOST="$3"
MQTT_PORT="$4"
MQTT_USER="$5"
MQTT_PASS="$6"
 
# ======================================================
# FILES & LOGS
# ======================================================
LOG_FILE="/root/vpn_mqtt_log.txt"
DEBUG_LOG="/root/vpn_debug.log"
STATE_FILE="/root/vpn_state.txt"
 
touch "$LOG_FILE"
touch "$DEBUG_LOG"
chmod 666 "$LOG_FILE" "$DEBUG_LOG"
 
echo "=== VPN SCRIPT STARTED at $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
echo "[DEBUG] Script started. USER=$(id -u)" >> "$DEBUG_LOG"
echo "[DEBUG] PATH=$PATH" >> "$DEBUG_LOG"
 
 
# ======================================================
# CONFIGURATION — ONLY ONE URL NOW
# ======================================================
API_URL=$(uci get cloudconfigNH.cloudconfigNH.HTTPcustomURL 2>/dev/null)
API_URL="${API_URL:-}"
 
echo "Server URL: $API_URL" >> "$LOG_FILE"
echo "[DEBUG] Final API_URL = $API_URL" >> "$DEBUG_LOG"
 
 
# ======================================================
# MQTT PUBLISH FUNCTION
# ======================================================
send_mqtt_message() {
    local msg="$1"
    local final_msg="$recive_id,$msg"
 
    local RETRY=0
    local MAX_RETRY=3
 
    echo "$(date '+%Y-%m-%d %H:%M:%S') MQTT Publish: $final_msg" >> "$LOG_FILE"
    echo "[DEBUG] mosquitto_pub sending: $final_msg" >> "$DEBUG_LOG"
 
    while [ $RETRY -lt $MAX_RETRY ]; do
        /usr/bin/mosquitto_pub \
            -h "$MQTT_HOST" \
            -p "$MQTT_PORT" \
            -u "$MQTT_USER" \
            -P "$MQTT_PASS" \
            -t "$topic" \
            -m "$final_msg"
 
        MQTT_STATUS=$?
        echo "[DEBUG] mosquitto exit code: $MQTT_STATUS" >> "$DEBUG_LOG"
 
        [ $MQTT_STATUS -eq 0 ] && return 0
 
        RETRY=$((RETRY+1))
        sleep 2
    done
 
    echo "$(date '+%Y-%m-%d %H:%M:%S') MQTT Publish Failed" >> "$LOG_FILE"
}
 
 
# ======================================================
# LOAD DEVICE DETAILS
# ======================================================
present_Dev_id=$(uci get boardconfig.board.serialnum)
device_uuid=$(cut -d',' -f2 /root/GPRSErrorLogs/HardcodedSubMessage.txt)
sendnum=1
 
echo "[DEBUG] device_uuid=$device_uuid" >> "$DEBUG_LOG"
 
 
# ======================================================
# REBOOT DETECTION
# ======================================================
if [ -f "$STATE_FILE" ]; then
    echo "[DEBUG] Reboot detected" >> "$DEBUG_LOG"
    disable_vpn "$API_URL" "Device rebooted"
fi
 
echo "$API_URL" > "$STATE_FILE"
 
 
# ======================================================
# INITIAL REVOKE
# ======================================================
revoke_resp=$(curl -k -H 'Content-Type: application/json' \
     -d "{\"device_uuid\":\"$device_uuid\",\"num\":\"2\"}" \
     -X POST "$API_URL/api/ovpncertificate/")
 
echo "[DEBUG] Initial revoke response: $revoke_resp" >> "$DEBUG_LOG"
 
 
# ======================================================
# CERTIFICATE DOWNLOAD
# ======================================================
cd /root
 
curl -sk -D /root/vpn_cert_header.txt \
     -H 'Content-Type: application/json' \
     -d "{\"device_uuid\":\"$device_uuid\",\"num\":\"$sendnum\"}" \
     -X POST "$API_URL/api/ovpncertificate/" \
     -O -J >> "$DEBUG_LOG" 2>&1
 
if [ ! -f "/root/${device_uuid}.ovpn" ]; then
    send_mqtt_message "Error: VPN certificate not downloaded"
    rm -f "$STATE_FILE"
    exit 1
fi
 
mv "/root/${device_uuid}.ovpn" /etc/openvpn/
 
 
# ======================================================
# CONFIGURE UCI VPN
# ======================================================
uci set vpnconfig1.general.enableopenvpngeneral="1"
uci commit vpnconfig1
 
uci set openvpn.vpnnew=openvpn1
uci set openvpn.vpnnew.name='vpnnew'
uci set openvpn.vpnnew.enable='1'
uci set openvpn.vpnnew.bridge='0'
uci set openvpn.vpnnew.status='DOWN'
uci set openvpn.vpnnew.config="/etc/openvpn/${device_uuid}.ovpn"
uci commit openvpn
 
 
# ======================================================
# START OPENVPN HANDLER
# ======================================================
sh /root/InterfaceManager/script/vpn/openvpn/openvpn_handler.sh >> "$DEBUG_LOG" 2>&1
 
 
# ======================================================
# CHECK TUN INTERFACE
# ======================================================
MAX_RETRIES=3
RETRY=0
tuneliPN=""
 
while [ $RETRY -lt $MAX_RETRIES ]; do
    ifconfig tun_vpnnew >> "$DEBUG_LOG" 2>&1
 
    tuneliPN=$(ifconfig tun_vpnnew 2>/dev/null |
        grep -oE 'inet addr:[0-9.]+' | cut -d: -f2)
 
    [ -n "$tuneliPN" ] && break
 
    sleep 10
    RETRY=$((RETRY+1))
done
 
[ -n "$tuneliPN" ] && send_mqtt_message "$tuneliPN"
[ -z "$tuneliPN" ] && send_mqtt_message "OpenVPN not registered"
 
 
# ======================================================
# 300-SECOND TIMER LOOP (RESTORED)
# ======================================================
# TOTAL_DURATION=300
# INTERVAL=10
# MAX_COUNT=$((TOTAL_DURATION / INTERVAL))
# COUNT=0
 
# while [ $COUNT -lt $MAX_COUNT ]; do
#     sleep $INTERVAL
#     COUNT=$((COUNT+1))
 
#     CURRENT_URL=$(uci get cloudconfigNH.cloudconfigNH.HTTPcustomURL 2>/dev/null)
#     SAVED_URL=$(cat "$STATE_FILE")
 
#     echo "[DEBUG] LOOP: $COUNT Current=$CURRENT_URL Saved=$SAVED_URL" >> "$DEBUG_LOG"
 
#     if [ "$CURRENT_URL" != "$SAVED_URL" ]; then
#         revoke_resp=$(curl -k -H 'Content-Type: application/json' \
#             -d "{\"device_uuid\":\"$device_uuid\",\"num\":\"2\"}" \
#             -X POST "$SAVED_URL/api/ovpncertificate/")
#         disable_vpn "$SAVED_URL" "API URL changed"
#     fi
# done

#############################################
if [ -n "$tuneliPN" ]; then
                        CURRENT_URL=$(uci get cloudconfigNH.cloudconfigNH.HTTPcustomURL 2>/dev/null)
                        SAVED_URL=$(cat "$STATE_FILE")
                    
                        echo "[DEBUG] LOOP: $COUNT Current=$CURRENT_URL Saved=$SAVED_URL" >> "$DEBUG_LOG"
                    
                        if [ "$CURRENT_URL" != "$SAVED_URL" ]; then
                            revoke_resp=$(curl -k -H 'Content-Type: application/json' \
                                -d "{\"device_uuid\":\"$device_uuid\",\"num\":\"2\"}" \
                                -X POST "$SAVED_URL/api/ovpncertificate/")
                            disable_vpn "$SAVED_URL" "API URL changed"
                        fi

                        TOTAL_DURATION=3000
                        INTERVAL=10               
                        MAX_COUNT=$((TOTAL_DURATION / INTERVAL))
                        TIMER_FILE="/root/openvpn_timer.txt"
                        if [ ! -f /root/openvpn_timer.txt ]; then
                            touch /root/openvpn_timer.txt
                            chmod 777 /root/openvpn_timer.txt
                            echo "Starting OpenVPN timer fresh..."
                            COUNT=0
                            while [ $COUNT -lt $MAX_COUNT ]; do
                                sleep $INTERVAL
                                COUNT=$((COUNT + 1))
                                echo "$COUNT" > "$TIMER_FILE"
                            done
                            echo "OPENVPN REACHED THE END TIME"
                            rm -f "$TIMER_FILE"
                            sleep 1
                            # ======================================================
                            # TIMEOUT → DISABLE VPN
                            # ======================================================
                            disable_vpn "$API_URL" "VPN session completed"
                        fi

fi

