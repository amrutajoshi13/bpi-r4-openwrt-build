#!bin/sh
ser2netEnable1=$(uci get portconfig.portconfig1.Ser2netEnable1)
ser2netEnable2=$(uci get portconfig.portconfig2.Ser2netEnable2)
if [ "$ser2netEnable1" -eq 1 ]
then
	/usr/sbin/ser2net -c /etc/ser2net.conf > /dev/null 2>1&
fi

if [ "$ser2netEnable2" -eq 1 ]
then
	/usr/sbin/ser2net -c /etc/ser2net2.conf > /dev/null 2>1&
fi
	

exit 0
