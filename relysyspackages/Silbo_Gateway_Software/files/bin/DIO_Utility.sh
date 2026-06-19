#!/bin/sh

. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfigParameters.cfg
. /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg

echo "NoOfDInput=$NoOfDInput"

i=1
while [ "$i" -le "$NoOfDInput" ]
do
    eval mode=\$DIOMode$i

    if [ "$mode" = "0" ]; then
        /bin/DIUtility.sh "$i"
    fi

    i=$((i + 1))
done

