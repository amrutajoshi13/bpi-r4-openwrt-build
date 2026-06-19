#!/bin/sh

sleeptime=$1
sleeptime=`expr "$sleeptime" \* 60`
sim=$3
interface=$2

killall sleep $sleeptime
/bin/sleep $sleeptime

/root/InterfaceManager/script/cellular/SimSwitch.sh $interface $sim
