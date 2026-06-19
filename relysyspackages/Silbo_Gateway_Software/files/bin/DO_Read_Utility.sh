#!/bin/sh

. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfigParameters.cfg
. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg

echo "NoOfDInput=$NoOfDInput"

i=1
while [ "$i" -le "$NoOfDInput" ]
do
    eval mode=\$DIOMode$i

    if [ "$mode" = "1" ]; then
        # Get only the value after '='
        value=$(/bin/DIUtility.sh "$i" | awk -F'= ' '{print $2}')
        echo "DO$i = $value"
    fi

    i=$((i + 1))
done
