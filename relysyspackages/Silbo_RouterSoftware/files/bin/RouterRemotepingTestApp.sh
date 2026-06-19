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
. /root/ConfigFiles/RouterAppConfig/routerappremoteconfig.cfg

PacketCount=4
PingDeadline=4
MinPacketLoss=$failurecriteria
iretries=0
pingres=2

PingTest()
{
	ipaddress=$1
	PingOutput=$(ping -c "$PacketCount" -w "$PingDeadline" "$ipaddress" 2>&1)
    PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')

    PacketsTransmitted=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' | awk '/transmitted/' | awk '{ print $1 }')
    PacketsReceived=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/received/' | awk '{ print $1 }')
    PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')
    
    if [ "x$PacketLoss" = "x" ] || [ "$PacketLoss" -ge "$MinPacketLoss" ]
    then
        pingres=2
    else
        pingres=0
        break

    fi
    if [ "x$PacketLoss" = "x" ]
    then
        CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
        LogMsg="\"<\",\"Network unreachable,\"$CurrentDate\"\">\""
        echo $LogMsg >> "/tmp/Log/RouterRemotepingMsgLog"
    else	
		CurrentDate=$(date +"%Y-%m-%d %H:%M:%S")
		LogMsg="\"<\",\"IPaddress:$ipaddress\",\"PacketTx:$PacketsTransmitted\",\"PacketRx:$PacketsReceived\",\"PacketLoss:$PacketLoss\",\"$CurrentDate\",\">\""
		echo $LogMsg >> "/tmp/Log/RouterRemotepingMsgLog"
	fi
	echo $pingres > "/tmp/RouterRemotepingTestApp.txt"
	return $pingres
}
 
case "$noofipaddress" in
    1)
		PingTest "$ipaddress1"
	;;
	
	2)
		PingTest "$ipaddress1"
		ret=$?
		if [ "$ret" == 0 ]
		then
			PingTest "$ipaddress2"
		else
			exit 0
		fi
	;;
	
	3)
		PingTest "$ipaddress1"
		ret1=$?
		if [ "$ret1" == 0 ]
		then
			PingTest "$ipaddress2"
			ret2=$?
			if [ "$ret2" == 0 ]
			then
				PingTest "$ipaddress3"
			else
				exit 0
			fi
		else
			exit 0
		fi
	;;
	
	4)
		PingTest "$ipaddress1"
		ret1=$?
		if [ "$ret1" == 0 ]
		then
			PingTest "$ipaddress2"
			ret2=$?
			if [ "$ret2" == 0 ]
			then
				PingTest "$ipaddress3"
				ret3=$?
				if [ "$ret3" == 0 ]
				then
					PingTest "$ipaddress4"
				else
					exit 0
				fi
			else
				exit 0
			fi
		else
			exit 0
		fi
	;;
	
	5)
		PingTest "$ipaddress1"
		ret1=$?
		if [ "$ret1" == 0 ]
		then
			PingTest "$ipaddress2"
			ret2=$?
			if [ "$ret2" == 0 ]
			then
				PingTest "$ipaddress3"
				ret3=$?
				if [ "$ret3" == 0 ]
				then
					PingTest "$ipaddress4"
					ret4=$?
					if [ "$ret4" == 0 ]
					then
						PingTest "$ipaddress5"
					else
						exit 0
					fi
				else
					exit 0
				fi
			else
				exit 0
			fi
		else
			exit 0
		fi
	;;
	
	6)
		PingTest "$ipaddress1"
		ret1=$?
		if [ "$ret1" == 0 ]
		then
			PingTest "$ipaddress2"
			ret2=$?
			if [ "$ret2" == 0 ]
			then
				PingTest "$ipaddress3"
				ret3=$?
				if [ "$ret3" == 0 ]
				then
					PingTest "$ipaddress4"
					ret4=$?
					if [ "$ret4" == 0 ]
					then
						PingTest "$ipaddress5"
						ret5=$?
						if [ "$ret5" == 0 ]
						then
							PingTest "$ipaddress6"
						else
							exit 0
						fi
					else
						exit 0
					fi
				else
					exit 0
				fi
			else
				exit 0
			fi
		else
			exit 0
		fi
	;;
	
	7)
		PingTest "$ipaddress1"
		ret1=$?
		if [ "$ret1" == 0 ]
		then
			PingTest "$ipaddress2"
			ret2=$?
			if [ "$ret2" == 0 ]
			then
				PingTest "$ipaddress3"
				ret3=$?
				if [ "$ret3" == 0 ]
				then
					PingTest "$ipaddress4"
					ret4=$?
					if [ "$ret4" == 0 ]
					then
						PingTest "$ipaddress5"
						ret5=$?
						if [ "$ret5" == 0 ]
						then
							PingTest "$ipaddress6"
							ret6=$?
							if [ "$ret6" == 0 ]
							then
								PingTest "$ipaddress7"
							else
								exit 0
							fi
						else
							exit 0
						fi
					else
						exit 0
					fi
				else
					exit 0
				fi
			else
				exit 0
			fi
		else
			exit 0
		fi
	;;
	
	8)
		PingTest "$ipaddress1"
		ret1=$?
		if [ "$ret1" == 0 ]
		then
			PingTest "$ipaddress2"
			ret2=$?
			if [ "$ret2" == 0 ]
			then
				PingTest "$ipaddress3"
				ret3=$?
				if [ "$ret3" == 0 ]
				then
					PingTest "$ipaddress4"
					ret4=$?
					if [ "$ret4" == 0 ]
					then
						PingTest "$ipaddress5"
						ret5=$?
						if [ "$ret5" == 0 ]
						then
							PingTest "$ipaddress6"
							ret6=$?
							if [ "$ret6" == 0 ]
							then
								PingTest "$ipaddress7"
								ret7=$?
								if [ "$ret7" == 0 ]
								then
									PingTest "$ipaddress8"
								else
									exit 0
								fi
							else
								exit 0
							fi
						else
							exit 0
						fi
					else
						exit 0
					fi
				else
					exit 0
				fi
			else
				exit 0
			fi
		else
			exit 0
		fi
	;;
	
	*)
    ;;
esac
exit 0       
