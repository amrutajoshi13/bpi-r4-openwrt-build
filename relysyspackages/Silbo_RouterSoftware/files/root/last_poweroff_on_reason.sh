#!/bin/sh

LOG_DIR=/root/ConfigFiles/PowerOnOFF_reason
LOG_FILE=Reboot_Details.txt
MAX_FILES=2
MAX_SIZE=9000
HEADER="Present_Time,Last_Powerofftime,Poweroff_Reason,Board_Powerontime,Internet"

# check if the log directory exists, create it if it doesn't
if [ ! -d "$LOG_DIR" ]; then
	echo "Creating log directory: $LOG_DIR"
	mkdir -p "$LOG_DIR"
fi
# check if the log file exists, create it if it doesn't
if [ ! -f "$LOG_DIR/$LOG_FILE" ]; then
	echo "Creating log file: $LOG_DIR/$LOG_FILE"
	touch "$LOG_DIR/$LOG_FILE"
    echo "$HEADER" > "$LOG_DIR/$LOG_FILE"
fi
# check the size of the current log file, rotate it if necessary
if [ "$(wc -c < "$LOG_DIR/$LOG_FILE")" -gt "$MAX_SIZE" ]; then
	echo "Rotating log file: $LOG_DIR/$LOG_FILE"
	mv "$LOG_DIR/$LOG_FILE" "$LOG_DIR/$LOG_FILE.1"
	touch "$LOG_DIR/$LOG_FILE"
    echo "$HEADER" > "$LOG_DIR/$LOG_FILE"
	truncate -s 0 "$LOG_DIR/$LOG_FILE"
fi
# check the number of log files, delete the oldest one if necessary
if [ "$(ls -1 $LOG_DIR/$LOG_FILE* | wc -l)" -gt "$MAX_FILES" ]; then
	echo "Deleting oldest log file in directory: $LOG_DIR"
	rm -f "$(ls -1 $LOG_DIR/$LOG_FILE* | head -n 1)"
fi

internetavailable=0
servers=$(uci get webserverconfig.webserverconfig.ntpserver)
echo "Checking NTP servers for connectivity"
for server in $servers; do
    output=$(fping -c 2 -q "$server" 2>&1)
    if echo "$output" | grep -q "0%"; then
        echo "Ping successful for $server with 0% packet loss. Stopping further checks."
        internetavailable=1
        break
    else
        echo "Ping failed for $server."
    fi
done

if [ $internetavailable -eq 0 ]; then
    echo "No NTP servers available. Checking mwan3 interfaces..."
    interfaces=$(mwan3 interfaces | awk '/interface/ {print $2}')
 
    for Device_Type in $interfaces; do
        track_ip=$(uci get "mwan3.$Device_Type.track_ip" 2>/dev/null)

        if [ -n "$track_ip" ]; then
            first_ip=$(echo "$track_ip" | awk '{print $1}')
            second_ip=$(echo "$track_ip" | awk '{print $2}')
            
            output=$(fping -c 2 -q "$first_ip" 2>&1)
            packet_loss=$(echo "$output" | awk -F'[=%]' '{print $3}' | awk -F'/' '{print $3}')
            if [ "$packet_loss" -eq 0 ]; then
                echo "Ping successful for $Device_Type with 0% packet loss. Stopping further checks."
                internetavailable=1
                break  
            else
                echo "Ping failed for first IP ($first_ip)."
                output=$(fping -c 2 -q "$second_ip" 2>&1)
                packet_loss=$(echo "$output" | awk -F'[=%]' '{print $3}' | awk -F'/' '{print $3}')
                if [ "$packet_loss" -eq 0 ]; then
                    echo "Ping successful for ($second_ip) $Device_Type with 0% packet loss. Stopping further checks."
                    internetavailable=1
                    break  
                else
                    echo "Ping failed for both IPs $Device_Type Moving to next interface."
                fi
            fi
        else
            echo "No track_ip found for $Device_Type."
        fi
    done
else
    echo "NTP server check successful, skipping mwan3 interface checks."
fi

file="/root/ConfigFiles/RebootLog/Rebootreason.txt"
# Check if the file exists
if [[ -f "$file" && -s "$file" ]]; then
    reason=$(sed -n 's/.*\(\[.*\]\):\([0-9]*\).*/\1_\2/p'  "$file")
    time_last=$(awk -F' ' '{print $4}' "$file")
    day_last=$(awk -F' ' '{print $3}' "$file")
    if [ "$day_last" -lt 10 ]; then
        day_last="0$day_last"
    fi
    year_month=$(date +"%Y-%m")
    LAST_Power_OFF_time_epoch="${year_month}-${day_last} ${time_last}"
   
    Last_PowerON_time_epoch=$(uptime -s)
    Last_PowerON_time_sec=$(date -d "$Last_PowerON_time_epoch" +%s)
    LAST_Power_OFF_time_sec=$(date -d "$LAST_Power_OFF_time_epoch" +%s)
    if [ "$Last_PowerON_time_sec" -gt "$LAST_Power_OFF_time_sec" ]; then
            LAST_Power_OFF_time="$LAST_Power_OFF_time_epoch"
            Last_PowerON_time="$Last_PowerON_time_epoch"
    else
            LAST_Power_OFF_time="$LAST_Power_OFF_time_epoch"
            Last_PowerON_time=$(uptime -s)
    fi
    rm "$file"
    touch /root/ConfigFiles/RebootLog/Rebootreason.txt
elif [[ -f "$file" && ! -s "$file" ]]; then
    reason="[Unexpected_PowerDown]_0"
    LAST_Power_OFF_time_epoch=$(tail -n 1 /root/Router_Logs/SHMAPP_Log/Poweroff_log_usage.txt)

    Last_PowerON_time_epoch=$(uptime -s)
    LAST_Power_OFF_time_sec=$(date -d "$LAST_Power_OFF_time_epoch" +%s)
    Last_PowerON_time_sec=$(date -d "$Last_PowerON_time_epoch" +%s)

    if [ "$Last_PowerON_time_sec" -gt "$LAST_Power_OFF_time_sec" ]; then
            LAST_Power_OFF_time="$LAST_Power_OFF_time_epoch"
            Last_PowerON_time="$Last_PowerON_time_epoch"
    else
            Last_PowerON_time="$Last_PowerON_time_epoch"
            #LAST_Power_OFF_time=$(tail -n 2 /root/Router_Logs/SHMAPP_Log/Poweroff_log_usage.txt | head -n 1)
            LAST_Power_OFF_time_ra=$((Last_PowerON_time_sec - 5))
            LAST_Power_OFF_time=$(date -d @"$LAST_Power_OFF_time_ra" '+%Y-%m-%d %H:%M:%S')
    fi
else
    reason="[Unexpected_PowerDown]_0"
    LAST_Power_OFF_time_epoch=$(tail -n 1 /root/Router_Logs/SHMAPP_Log/Poweroff_log_usage.txt)

    Last_PowerON_time_epoch=$(uptime -s)
    LAST_Power_OFF_time_sec=$(date -d "$LAST_Power_OFF_time_epoch" +%s)
    Last_PowerON_time_sec=$(date -d "$Last_PowerON_time_epoch" +%s)

    if [ "$Last_PowerON_time_sec" -gt "$LAST_Power_OFF_time_sec" ]; then
            LAST_Power_OFF_time="$LAST_Power_OFF_time_epoch"
            Last_PowerON_time="$Last_PowerON_time_epoch"
    else
            Last_PowerON_time="$Last_PowerON_time_epoch"
            #LAST_Power_OFF_time=$(tail -n 2 /root/Router_Logs/SHMAPP_Log/Poweroff_log_usage.txt | head -n 1)
            LAST_Power_OFF_time_ra=$((Last_PowerON_time_sec - 5))
            LAST_Power_OFF_time=$(date -d @"$LAST_Power_OFF_time_ra" '+%Y-%m-%d %H:%M:%S')
    fi
fi

original_time=$(date +"%Y-%m-%d %H:%M:%S")
echo "$original_time,$LAST_Power_OFF_time,$reason,$Last_PowerON_time,$internetavailable" >> "$LOG_DIR/$LOG_FILE"
logger -t reboot -p customs.info  "Device Rebooted due to $reason"
