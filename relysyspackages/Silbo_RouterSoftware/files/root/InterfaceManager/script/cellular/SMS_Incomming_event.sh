#!/bin/sh

while true; do
inotifywait /var/spool/sms/incoming/ -e create |
    while read dir action file; do
        /root/InterfaceManager/script/cellular/SMSEventHandler.sh "RECEIVED" "$dir$file"
        # do something with the file
    done
done
