#!/bin/sh

. /lib/functions.sh

rm /tmp/readsms.txt
touch /tmp/readsms.txt
chmod 0777 /tmp/readsms.txt

latestIncomingFile=$(ls -tr /var/spool/sms/incoming/ | tail -1)
echo $latestIncomingFile
output=$(cat /var/spool/sms/incoming/$latestIncomingFile > /tmp/readsms.txt)
exit 0			
				
