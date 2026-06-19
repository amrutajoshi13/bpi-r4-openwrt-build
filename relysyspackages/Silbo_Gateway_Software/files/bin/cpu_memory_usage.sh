#!/bin/bash

# Log file path
LOG_FILE="/root/memoryusage.txt"
LogrotateConfigFile=/etc/logrotate.d/memoryusageLogrotateConfig

# Function to get the top 10 memory-consuming processes in a single line
get_top_memory_processes() {
    out=""
    for pid in $(ps -eo pid,%mem --sort=-%mem | awk 'NR>1 {print $1}' | head -n 10); do
        mem=$(ps -p $pid -o %mem=)
        if [ -r "/proc/$pid/cmdline" ]; then
            cmd=$(tr '\0' ' ' < /proc/$pid/cmdline)
            [ -z "$cmd" ] && cmd="[$(ps -p $pid -o comm=)]"
        else
            cmd="[$(ps -p $pid -o comm=)]"
        fi
        out="$out$cmd: $mem%, "
    done
    echo "${out%, }"
}


# Function to get the top 10 CPU-consuming processes in a single line
get_top_cpu_processes() {
    out=""
    for pid in $(ps -eo pid,%cpu --sort=-%cpu | awk 'NR>1 {print $1}' | head -n 10); do
        cpu=$(ps -p $pid -o %cpu=)
        if [ -r "/proc/$pid/cmdline" ]; then
            cmd=$(tr '\0' ' ' < /proc/$pid/cmdline)
            [ -z "$cmd" ] && cmd="[$(ps -p $pid -o comm=)]"
        else
            cmd="[$(ps -p $pid -o comm=)]"
        fi
        out="$out$cmd: $cpu%, "
    done
    echo "${out%, }"
}





# Function to get the system load averages
get_load_averages() {
    uptime | awk -F'load average: ' '{print $2}'
}

get_available_memory()
{
  free -k | awk '/^Mem:/ {print $7}'
}

# Function to log the top memory and CPU-consuming processes with a timestamp and load averages
log_resource_usage() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local mem_usage="Mem Usage: : $(get_top_memory_processes)"
    local available_memory="Available Memory : $(get_available_memory)"
    local cpu_usage="CPU Usage: : $(get_top_cpu_processes)"
    local load_averages="Load Averages: : $(get_load_averages)"
    
    echo "####################################################################################" >> $LOG_FILE
    echo $timestamp,$load_averages,$available_memory >> $LOG_FILE
    echo "####################################################################################" >> $LOG_FILE
    #echo $load_averages >> $LOG_FILE
    #echo $available_memory >> $LOG_FILE
    echo $mem_usage >> $LOG_FILE
    echo $cpu_usage >> $LOG_FILE
    logrotate "$LogrotateConfigFile"
}

# Main loop to continuously log memory and CPU usage at intervals
#while true; do
    log_resource_usage
    # Sleep for a defined interval, e.g., 5 minutes (300 seconds)
 #   sleep 300
#done

