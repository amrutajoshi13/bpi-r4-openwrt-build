#!/bin/sh

. /lib/functions.sh

LogAvgLog="/root/LoadAvgLog.txt"
LogrotateConfigFile=/etc/logrotate.d/watchdogLogrotateConfig

# Read configuration values
MEMORY_THRESHOLD=$(uci get watchdogconfigsw.watchdogconfigsw.memory)
WATCHDOG_TIME=$(uci get watchdogconfigsw.watchdogconfigsw.time)
MAX_LOAD=$(uci get watchdogconfigsw.watchdogconfigsw.load)

RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"                    
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"



# Function to get available memory (KB)
get_available_memory() {
    free -k | awk '/^Mem:/ {print $7}'
}

# Function to get 1-min load
get_current_load() {
    uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print $1}'
}

log_status() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")]" >> "$LogAvgLog"
    {
        echo "##################################################"
        echo "$1"
    } >> "$LogAvgLog"
    echo "************************************************************" >> "$LogAvgLog"
    logrotate "$LogrotateConfigFile"
}

while true; do
    /sbin/watchdog -t "$WATCHDOG_TIME" /dev/watchdog

    Load1=$(get_current_load)
    AvailMem=$(get_available_memory)

    # CASE 1: High Load → reboot
    if awk -v load="$Load1" -v max="$MAX_LOAD" 'BEGIN {exit !(load >= max)}'; then
        log_status "High Load Detected: $Load1 (threshold $MAX_LOAD) → Device Reboot"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootLogfile"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootreasonLogfile"

        /sbin/watchdog -t 0 /dev/watchdog
        /root/usrRPC/script/Board_Recycle_12V_Script.sh

    # CASE 2: High Load + Low Memory → reboot apps
    elif awk -v load="$Load1" -v max="$MAX_LOAD" 'BEGIN {exit !(load >= max)}' && \
         [ "$AvailMem" -lt "$MEMORY_THRESHOLD" ]; then
        log_status "High Load + Low Memory → Restarting Apps (AvailMem=$AvailMem KB, Load=$Load1)"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootLogfile"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootreasonLogfile"

        /sbin/watchdog -t 0 /dev/watchdog
        /root/usrRPC/script/Board_Recycle_12V_Script.sh

    # CASE 3: High Load + high Memory → restart apps
    elif awk -v load="$Load1" -v max="$MAX_LOAD" 'BEGIN {exit !(load >= max)}' && \
         [ "$AvailMem" -gt "$MEMORY_THRESHOLD" ]; then
        log_status "High Load + Hidh Memory → Restarting Apps (AvailMem=$AvailMem KB, Load=$Load1)"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootLogfile"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootreasonLogfile"

        
        
        /sbin/watchdog -t 0 /dev/watchdog
        sh -x /bin/RestoreDataCollector.sh

    # CASE 4: Low Memory only → restart apps
    elif [ "$AvailMem" -lt "$MEMORY_THRESHOLD" ]; then
        log_status "Low Memory Detected: $AvailMem KB (threshold $MEMORY_THRESHOLD) → Restarting Apps"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootLogfile"
		echo "$date:[High Load Low Available Memory]:G01" > "$RebootreasonLogfile"

        
        /sbin/watchdog -t 0 /dev/watchdog
        sh -x /bin/RestoreDataCollector.sh

    else
        # Normal → feed watchdog
        sleep "$WATCHDOG_TIME"
    fi
 logrotate "$LogrotateConfigFile"
done

/usr/sbin/logrotate "$LogrotateConfigFile"

