#!/bin/sh

i=0
RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"
for i in 1 2 3
do
 Ifconfig_Result=$(ifconfig)
 if [ -z "${Ifconfig_Result}" ]
 then
  if [ "$i" = "3" ]
  then
      	echo "$date:[Test_Ifconfig.sh script]:9" >> "$RebootLogfile"
		echo "$date:[Test_Ifconfig.sh script]:9" > "$RebootreasonLogfile"
    /root/usrRPC/script/Board_Recycle_12V_Script.sh
  fi 
  /bin/sleep 120 
 else
  break
 fi
done
