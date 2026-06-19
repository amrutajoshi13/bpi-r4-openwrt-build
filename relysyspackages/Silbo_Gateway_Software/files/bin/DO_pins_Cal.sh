#!/bin/sh

. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfigParameters.cfg 2>/dev/null
. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg 2>/dev/null

# Validate NoOfDInput
if [ -z "$NoOfDInput" ] || ! echo "$NoOfDInput" | grep -q '^[0-9]\+$'; then
    echo '{"error":"Invalid NoOfDInput"}'
    exit 1
fi

i=1
do_count=0
json=""

while [ "$i" -le "$NoOfDInput" ]
do
    eval mode=\$DIOMode$i

    # If mode = 1 treat as DO (change if needed)
    if [ "$mode" = "1" ]; then
        do_count=$((do_count + 1))

        if [ -z "$json" ]; then
            json="\"DO_${i}\":$i"
        else
            json="$json,\"DO_${i}\":$i"
        fi
    fi

    i=$((i + 1))
done

# Final JSON
if [ "$do_count" -eq 0 ]; then
    echo '{"NoOfDO":0}'
else
    echo "{\"NoOfDO\":$do_count,$json}"
fi
