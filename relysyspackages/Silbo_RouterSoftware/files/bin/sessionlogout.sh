#!/bin/sh

sessionid="$1"
protocol="$2"
host="$3"
resultFile="/tmp/logoutresult.txt"


logout() {
    local href="$1"
    output=$(curl -sk -H "Content-Type: application/json" -d '{
        "jsonrpc": "2.0",
        "id": 1,
        "method": "call",
        "params": [ "'"$sessionid"'", "session", "destroy", {} ]
    }' $protocol://$href/ubus)

    result=$(echo "$output" | grep -o '"result":[^]]*' | head -n1 | grep -o '[0-9]\+')

    if [ "$result" = "0" ]; then
        # Success
        echo "$protocol://$href/" > "$resultFile"
        exit 0
    else
        # Failure
        echo "1" > "$resultFile"
        exit 1
    fi
}


logout "$host"

# Fallback if logout didn't exit above
echo "1" > "$resultFile"
exit 1
