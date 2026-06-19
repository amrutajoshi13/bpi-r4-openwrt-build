#!/bin/sh

. /lib/functions.sh

pid=$(pgrep -f "/root/Test_APP/DeviceTestApp")
kill -TERM "$pid" > /dev/null 2>&1
sleep 1
kill -KILL "$pid" > /dev/null 2>&1

test=$(uci get testappenable.testappen.enable)

if [ "$test" = "1" ]
then
pid=$(pgrep -f "/root/InterfaceManager/script/SystemBoot.sh")
kill -TERM "$pid" > /dev/null 2>&1
sleep 1
kill -KILL "$pid" > /dev/null 2>&1
fi

#echo "Test App Output"
/etc/init.d/mwan3 stop
 
sleep 1

mwan3 stop

sleep 1

#uci set testappenable.testappen.enable="0"

#uci commit testappenable

if [ ! -f /etc/config/networkold ]
then
mv /etc/config/network /etc/config/networkold
fi

cp /root/Test_APP/network /etc/config/network

sleep 1

/etc/init.d/network restart

sleep 2

/root/Test_APP/DeviceTestApp > /root/Test_APP/testreport.txt 2>&1 &

exit 0
