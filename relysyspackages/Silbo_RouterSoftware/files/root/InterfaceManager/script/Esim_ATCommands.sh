#!/bin/sh
. /lib/functions.sh
EnmComPort="$1"
Logfile="/root/ConfigFiles/EsimLog/EsimLog.txt"
LogrotateConfigFile="/etc/logrotate.d/EsimLogLogrotateConfig"
touch EsimLog.txt
STK_Commands()
{
	echo "comport is $EnmComPort" >> "$Logfile"

# Execute the AT command and capture the output
echo "****************************START****************************" >> "$Logfile"
Check_STKMode=$(gcom -d "$EnmComPort" -s /etc/gcom/getstkmode.gcom| awk NR==2)
response=$(echo "$Check_STKMode" | sed 's/.*QSTK: //' )
value1=$(echo "$response" | cut -d',' -f1)
value2=$(echo "$response" | cut -d',' -f2)
if ([ "$value1" -eq 0 ] && [ "$value2" -eq 1 ]) ||  ([ "$value1" -eq 0 ] && [ "$value2" -eq 0 ]) ||  ([ "$value1" -eq 1 ] && [ "$value2" -eq 0 ]); then
		Set_STKMode=$(gcom -d "$EnmComPort" -s /etc/gcom/enablestk.gcom)
		date=$(date)
		echo "$date:Set_STKMode(For AT cmd AT+QSTK=1,1,300 ,response obtained is ) -> $Set_STKMode" >> "$Logfile"
		Check_STKMode=$(gcom -d "$EnmComPort" -s /etc/gcom/getstkmode.gcom)
		date=$(date)
		echo "$date:Check_STKMode(For AT cmd AT+QSTK? response obtained is )  -> $Check_STKMode" >> "$Logfile"
		response=$(echo "$Check_STKMode" | sed 's/.*QSTK: //' )
		value1=$(echo "$response" | cut -d',' -f1)
		value2=$(echo "$response" | cut -d',' -f2)
		Reboot_Modem=$(/bin/at-cmd "$EnmComPort" AT+QPOWD)
		sleep 90

fi 

if [ "$value1" -eq 1 ] && [ "$value2" -eq 1 ]; then
		Clear_PLMN=$(gcom -d "$EnmComPort" -s /etc/gcom/clearplmn.gcom | awk NR==2)
		echo "plmn is $Clear_PLMN"
		# Check if the output starts with OKRSM
		if echo "$Clear_PLMN" | grep -q "+CRSM:"; then
			# Extract the part after "OKRSM:"
			date=$(date)
			echo "$date:Clear_PLMN (For AT cmd AT+CRSM=214,28539,0,0,12,"FFFFFFFFFFFFFFFFFFFFFFFF" response obtained is ) -> $Clear_PLMN" >> "$Logfile"
			echo " "
			response=$(echo "$Clear_PLMN" | sed 's/.*CRSM: //' )

			# Split the response into two values based on the comma
			value1=$(echo "$response" | cut -d',' -f1)
			value2=$(echo "$response" | cut -d',' -f2)

			# Validate the values
			if [ "$value1" -eq 144 ] && [ "$value2" -eq 0 ]; then
				sleep 2
				Fetch_STK_Menu=$(gcom -d "$EnmComPort" -s /etc/gcom/Fetch_STK_Menu.gcom )
					date=$(date)
					echo "$date:Fetch_STK_Menu (For AT cmd AT+QSTKGI=37 response obtained is ) -> $Fetch_STK_Menu" >> "$Logfile"
					echo " " >> "$Logfile"

			else
				date=$(date)
				echo "$date:AT command output is incorrect. Expected 144,0 but got $value1,$value2." >> "$Logfile"
				echo " "
			fi
		else
			date=$(date)
			echo "$date:Error: Invalid response or command failed." >> "$Logfile"
			echo " "
			#exit 0
		fi
fi
if echo "$Fetch_STK_Menu" | grep -q "QSTKGI:"; then
	for i in 1 2 3                                                                                                                  
	do 
		sleep 2
		STK_Menu_response=$(gcom -d "$EnmComPort" -s /etc/gcom/STK_Menu_response.gcom)
		if echo "$STK_Menu_response" | grep -q "QSTKURC:"; then
			break 
		else
		    continue
		fi
		done
		date=$(date)
		echo "$date:STK_Menu_response (For AT cmd AT+QSTKRSP=37,0 response obtained is ) -> $STK_Menu_response" >> "$Logfile"
		echo " "
		
	
else
		STK_Menu_response=$(gcom -d "$EnmComPort" -s /etc/gcom/STK_Menu_response.gcom)
		date=$(date)
		echo "$date:STK_Menu_response (For AT cmd AT+QSTKRSP=37,0 response obtained is ) -> $STK_Menu_response" >> "$Logfile"
		echo " "
fi
if echo "$STK_Menu_response" | grep -q "QSTKURC:"; then
	for i in 1 2 3                                                                                                                  
	do 
		sleep 2
		STK_Menu_selection=$(gcom -d "$EnmComPort" -s /etc/gcom/STK_Menu_selection.gcom)
		if echo "$STK_Menu_selection" | grep -q "QSTKURC:"; then
			break 
		else
		    continue
		fi
		done
		date=$(date)
		echo "$date:STK_Menu_selection(For AT cmd AT+QSTKRSP=253,0,128 response obtained is )  -> $STK_Menu_selection" >> "$Logfile"
		echo " "
	
else
		STK_Menu_selection=$(gcom -d "$EnmComPort" -s /etc/gcom/STK_Menu_selection.gcom)
		date=$(date)
		echo "$date:STK_Menu_selection(For AT cmd AT+QSTKRSP=253,0,128 response obtained is )  -> $STK_Menu_selection" >> "$Logfile"
		echo " "
fi
if echo "$STK_Menu_selection" | grep -q "QSTKURC:"; then
	for i in 1 2 3;do
		sleep 2
		Response_to_selected_item=$(gcom -d "$EnmComPort" -s /etc/gcom/Response_to_selected_item.gcom)
		if echo "$Response_to_selected_item" | grep -q "QSTKURC:"; then
			break 
		else
			continue
		fi
	done
	date=$(date)
	echo "$date:Response_to_selected_item (For AT cmd AT+QSTKRSP=36,0,1 response obtained is ) -> $Response_to_selected_item" >> "$Logfile"
	echo " "

else 
		Response_to_selected_item=$(gcom -d "$EnmComPort" -s /etc/gcom/Response_to_selected_item.gcom)
		date=$(date)
		echo "$date:Response_to_selected_item (For AT cmd AT+QSTKRSP=36,0,1 response obtained is ) -> $Response_to_selected_item" >> "$Logfile"
		echo " "
fi
if echo "$Response_to_selected_item" | grep -q "QSTKURC:"; then
	for i in 1 2 3;do
			sleep 2
		Select_item=$(gcom -d "$EnmComPort" -s /etc/gcom/Select_item.gcom)
		if echo "$Select_item" | grep -q "+QSTKGI"; then
			break 
		else
			continue
		fi
	done
	date=$(date)
	echo "$date:Select_item(For AT cmd AT+QSTKGI=36 response obtained is )  -> $Select_item" >> "$Logfile"
	echo " "

else
		Select_item=$(gcom -d "$EnmComPort" -s /etc/gcom/Select_item.gcom)
		date=$(date)
		echo "$date:Select_item(For AT cmd AT+QSTKGI=36 response obtained is )  -> $Select_item" >> "$Logfile"
		echo " "
fi
if echo "$Select_item" | grep -q "+QSTKGI"; then
	sleep 2
	for i in 1 2 3;do
		Disable_manage_off=$(gcom -d "$EnmComPort" -s /etc/gcom/Disable_manage_off.gcom)
		if echo "$Disable_manage_off" | grep -q "+QSTKURC:"; then
			break 
		else
			continue
		fi
	done
    date=$(date)
    echo "$date:Disable_manage_off(For AT cmd AT+QSTKRSP=36,0,12 response obtained is )  -> $Disable_manage_off" >> "$Logfile"
	echo " "

else 
		Disable_manage_off=$(gcom -d "$EnmComPort" -s /etc/gcom/Disable_manage_off.gcom)
		date=$(date)
		echo "$date:Disable_manage_off(For AT cmd AT+QSTKRSP=36,0,12 response obtained is )  -> $Disable_manage_off" >> "$Logfile"
		echo " "
fi

if echo "$Disable_manage_off" | grep -q "QSTKURC"; then
    date=$(date)
    echo "$date: AT commands executed successfully"

fi
echo "****************************END******************************" >> "$Logfile"

}

STK_Commands
logrotate "$LogrotateConfigFile"
exit 0
