#!/bin/sh

. /lib/functions.sh

SMSIncomingDirectory=/var/spool/sms/incoming
MAXIncomingSMSFiles=20
NoOfIncomingFilesToDelete=1

SMSSentDirectory=/tmp/sms/sent
MAXSentSMSFiles=20
NoOfSentFilesToDelete=1


NoOfSMSIncomingFiles=$(ls -l $SMSIncomingDirectory | wc -l)

echo "NoOfSMSIncomingFiles=$NoOfSMSIncomingFiles"

if [ $NoOfSMSIncomingFiles -gt $MAXIncomingSMSFiles ]
then 
	NoOfIncomingFilesToDelete=$(($NoOfSMSIncomingFiles - $MAXIncomingSMSFiles))
	echo 
	x=1
	while [ $x -lt $NoOfIncomingFilesToDelete ]
	do
		
				echo "Delete oldest incoming file"
				OldestIncomingFile=$(ls -t /var/spool/sms/incoming/ | tail -1)
				rm $SMSIncomingDirectory/$OldestIncomingFile
				x=$(( $x + 1 ))
			
	done
fi

NoOfSMSSentFiles=$(ls -l $SMSSentDirectory | wc -l)
echo "NoOfSMSSentFiles=$NoOfSMSSentFiles"

if [ $NoOfSMSSentFiles -gt $MAXSentSMSFiles ] 
then
	NoOfSentFilesToDelete=$(($NoOfSMSSentFiles - $MAXSentSMSFiles))	
	x=1
	while [ $x -lt $NoOfSentFilesToDelete ]
	do
		
			echo "Delete oldest Sent file"
			OldestSentFile=$(ls -t $SMSSentDirectory | tail -1)
			rm $SMSSentDirectory/$OldestSentFile
			x=$(( $x + 1 ))
	done
fi
exit 0
