#!/bin/sh
. /lib/functions.sh

EnableCellular=$(uci get sysconfig.sysconfig.enablecellular)
# Exit the script if cellular is disabled globally
if [ "$enablecellular" = "0" ]
then
	exit 0
fi

SimNumFile="/tmp/simnumfile"

#Sysconfig File
enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
CellularOperationMode=$(uci get sysconfig.sysconfig.CellularOperationMode)
PrimarySimSwitchBackEnable=$(uci get sysconfig.sysconfig.primarysimswitchbackenable)
PrimarySimSwitchBackTime=$(uci get sysconfig.sysconfig.primarysimswitchbacktime)

#Simswitchconfig File
Simswitchbasedon=$(uci get simswitchconfig.simswitchconfig.simswitch)
cellulardatausagemanagerperiodicity=$(uci get simswitchconfig.simswitchconfig.cellulardatausagemanagerperiodicity)
cellulardataswitchonspeedenable=$(uci get simswitchconfig.simswitchconfig.cellulardataswitchonspeedenable)
dayofmonth=$(uci get simswitchconfig.simswitchconfig.dayofmonth)
#periodicspeedtestinterval=$(uci get simswitchconfig.simswitchconfig.periodicspeedtestinterval)

curTme=$(date "+%H:%M:%S")
echo "$curTme"
#PeriodicTme=$(date -d@"$(( `date +%s`+$periodicspeedtestinterval*3600))" +%H:%M:%S)
echo "$PeriodicTme"
Hrs=$(echo "$PeriodicTme" | awk -F':' '{ printf("%d\n", $1); }')
Mns=$(echo "$PeriodicTme" | awk -F':' '{ printf("%d\n", $2); }')
printf "$Hrs\n"
printf "$Mns\n"

# Check if cellular is enabled
if [ "$enablecellular" = "1" ]
then
	# Check if operation mode is "singlecellulardualsim"
	if [ "$CellularOperationMode" = "singlecellulardualsim" ]
	then
		# If SIM switch is based on data limit	
		if [ "$Simswitchbasedon" = "datalim" ]
		then
			# If periodicity is daily, configure Data_Cap.sh to run every 2 minutes
			if [ "$cellulardatausagemanagerperiodicity" = "daily" ]
			then      
				sed -i '/Data_Cap/d' /etc/crontabs/root
				echo "*/2 * * * * /root/InterfaceManager/script/simswitch/Data_Cap.sh" >> /etc/crontabs/root
			fi
			# If periodicity is monthly, configure Data_Cap.sh similarly
			if [ "$cellulardatausagemanagerperiodicity" = "monthly" ]
			then      
				sed -i '/Data_Cap/d' /etc/crontabs/root
				echo "*/2 * * * * /root/InterfaceManager/script/simswitch/Data_Cap.sh" >> /etc/crontabs/root
			#$cellulardatausagemanagercronscript
			fi
		# If sim switch is not based on data limit, remove related cron jobs 
		else
			sed -i '/Data_Cap/d' /etc/crontabs/root  
			# If simswitch is not based on data limit, then we need to run the PrimarySwitch.sh ,
			#so that the sim has to switch back to the primary sim once the Simswitchbasedon has none or signalstrength.
			SimNum=$(cat "$SimNumFile")
			if [ "$SimNum" = "2" ]
			then
				if [ "$PrimarySimSwitchBackEnable" = "1" ]
				then
					pkill -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh"
					sleep 1
					/root/InterfaceManager/script/cellular/PrimarySwitch.sh "$PrimarySimSwitchBackTime" CWAN1 1 &         
				else
					pkill -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh"
				fi	
			fi	
		fi  
	# If operation mode is not singlecellulardualsim, remove speed cron job and Data_Cap	
	else		
		sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root  
		sed -i '/Data_Cap/d' /etc/crontabs/root  		
	fi 
	  
	# If operation mode is singlecellulardualsim, check for speed-based switching 
	if [ "$CellularOperationMode" = "singlecellulardualsim" ]
	then
		# If speed-based switching is enabled, add speed cron job with calculated time
		if [ "$cellulardataswitchonspeedenable" = "1" ]
		then
			sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root
			#echo "0 */$periodicspeedtestinterval * * * /root/InterfaceManager/script/cellulardatausagemanagerspeedcronscript.sh" >> /etc/crontabs/root
			echo "$Mns $Hrs * * * /root/InterfaceManager/script/cellulardatausagemanagerspeedcronscript.sh" >> /etc/crontabs/root
			# If speed switching is not enabled, remove cron job			
		else
		   sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root
		fi
	# If not in correct mode, clean up all related cron jobs		
	else
		sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root
		sed -i '/Data_Cap/d' /etc/crontabs/root  
	fi
		 
# Restart cron service to apply changes
/etc/init.d/cron restart
#sleep 2  

# If cellular is disabled, remove all cron jobs
else
   sed -i '/cellulardatausagemanagerspeedcronscript/d' /etc/crontabs/root
   sed -i '/Data_Cap/d' /etc/crontabs/root
fi
exit 0


