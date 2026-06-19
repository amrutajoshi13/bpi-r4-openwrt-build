#!/bin/sh

. /lib/functions.sh

boardname=$(cut -d',' -f2 /tmp/sysinfo/board_name)
boardtotalport=$(grep "^$boardname=" board_port.txt | cut -d'=' -f2)
ewan_port=4

json_output="{"
first_entry=1

for port in $(seq 0 $((boardtotalport - 2))); do
    output=$(swconfig dev switch0 port "$port" get link 2>/dev/null)

    if echo "$output" | grep -q "link:up"; then
        status="Connected"
        speed=$(echo "$output" | grep -o "speed:[0-9]*" | cut -d':' -f2)
        [ -z "$speed" ] && speed="0"
        speed="${speed}baseT"
    else
        status="Disconnected"
        speed="NA"
    fi

    lan_name="Eth$((port + 1))"

    [ $first_entry -eq 0 ] && json_output="${json_output},"
    first_entry=0

    json_output="${json_output}\"${lan_name}\":[{\"status\":\"${status}\",\"speed\":\"${speed}\"}]"
done

# EWAN port as last LAN
output=$(swconfig dev switch0 port "$ewan_port" get link 2>/dev/null)
if echo "$output" | grep -q "link:up"; then
    status="Connected"
    speed=$(echo "$output" | grep -o "speed:[0-9]*" | cut -d':' -f2)
    [ -z "$speed" ] && speed="0"
    speed="${speed}baseT"
else
    status="Disconnected"
    speed="NA"
fi

lan_name="Eth$boardtotalport"

[ $first_entry -eq 0 ] && json_output="${json_output},"
json_output="${json_output}\"${lan_name}\":[{\"status\":\"${status}\",\"speed\":\"${speed}\"}]"

json_output="${json_output}}"

# Print only the JSON 
printf "%s\n" "$json_output"

exit 0
