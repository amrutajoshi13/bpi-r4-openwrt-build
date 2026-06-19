#!/bin/sh

. /root/ReadAIAppComponent/etc/Config/ReadAIAppWebConfig.cfg

echo "NoOfAInput=$NoOfAInput"

i=1
while [ "$i" -le "$NoOfAInput" ]
do
    /bin/AIOutility_binary.sh "$i" 2
    i=$((i + 1))
done
