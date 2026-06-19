#!/bin/sh
ALIVE_FILE=/tmp/HTTP_receiver_thread_alive

# Touch alive file first
touch "$ALIVE_FILE"

# Read the first non-empty line (request line)
REQUEST_LINE=""
while read line; do
    line=$(echo "$line" | tr -d "\r\n")
    [ -n "$line" ] && REQUEST_LINE="$line" && break
done

# Parse method and path
METHOD=$(echo "$REQUEST_LINE" | awk '{print $1}')
PATH=$(echo "$REQUEST_LINE" | awk '{print $2}')

# Extract configType and configName
trimmed=$(echo "$PATH" | sed 's/^\/\+//')   # remove leading /
configType=$(echo "$trimmed" | cut -d"/" -f1)
configName=$(echo "$trimmed" | cut -d"/" -f2-)

# Prepare response
if [ "$configType" = "Table_Configuration" ]; then
    RESPONSE='{"status":"success","message":"Hello World"}'
else
    RESPONSE='{"status":"ok"}'
fi

# Send HTTP response
LEN=$(echo -n "$RESPONSE" | wc -c)
printf 'HTTP/1.1 200 OK\r\n'
printf 'Content-Type: application/json\r\n'
printf 'Content-Length: %d\r\n' "$LEN"
printf '\r\n'
printf '%s' "$RESPONSE"

exit 0
