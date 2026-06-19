#!/bin/sh
#IP=$1
#PingTime=$2
#ping -c $PingTime $IP
#Retval="$?"
#echo "Retval=$Retval"
#echo "$Retval" > "/bin/pingTest.txt"
#PacketCount=4
#PingDeadline=4
#PingIP=8.8.8.8
#MinPacketLoss=60
#maxnoofretries=10
#sleepinterval=1
. /bin/pingconfig.cfg

iretries=0
pingres=2

        PingOutput=$(ping -c "$PacketCount" -w "$PingDeadline" "$PingIP" 2>&1)
        PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

        PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
        PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
        PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')

        if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -eq "100" ]
        then
            PingOutput=$(ping -c "$PacketCount" -w "$PingDeadline" "$PingIP" 2>&1)
            PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

            PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
            PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
            PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')
        fi
        
        if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -ge "$MinPacketLoss" ]
        then
                pingres=2
			#echo "2" > "/bin/pingTest.txt"
            #return 2
        else
            pingres=0
            break

        fi
            	echo $pingres > "/bin/pingTest.txt"    
        #return 0
  exit 0      
