#!/bin/sh

. /lib/functions.sh

BLCsrcpath="/etc/config/BLControlSensorEventsActions"
AIsrcpath="/etc/config/analoginputconfig"
BLCEventsConfigcfgpath="/root/BLControlAppComponent/etc/Config/BLControlSensorEventsActions.cfg"
BLCAIlimitscfgpath="/root/BLControlAppComponent/etc/Config/BLControlAI.cfg"
NoOfEvents=0

updateBLCcfg()
{
	NoOfEvents=$((NoOfEvents+1))
	{
		config_get name SensorEventsActions name
		config_get EEnable SensorEventsActions EEnable
		config_get SensorType SensorEventsActions SensorType
		
		echo "Event${NoOfEvents}=\"${name}\""
		echo "${name}Enable=${EEnable}"
		
		if [ "$EEnable" = "1" ]
		then			
			echo "${name}NumberOfSensors=1"
			echo "ShutterSensor1Type=${SensorType}"
			
			if [ "$SensorType" = "0" ]
			then
				config_get DINo SensorEventsActions DINo
				config_get AlarmActiveState SensorEventsActions AlarmActiveState
				
				echo "ShutterSensor1Number=${DINo}"
				echo "ShutterSensor1TriggerState=${AlarmActiveState}"
				
			elif [ "$SensorType" = "1" ]
			then
				config_get RelayNo SensorEventsActions RelayNo
				config_get AlarmActiveState SensorEventsActions AlarmActiveState
				
				echo "ShutterSensor1Number=${RelayNo}"
				echo "ShutterSensor1TriggerState=${AlarmActiveState}"
				
			elif [ "$SensorType" = "2" ]
			then
				config_get AINo SensorEventsActions AINo
				
				echo "ShutterSensor1Number=${AINo}"
				
			elif [ "$SensorType" = "3" ]
			then
				config_get TempSensorNo SensorEventsActions TempSensorNo
				
				echo "ShutterSensor1Number=${TempSensorNo}"
			fi
			
			echo "ShutterNumberOfActions=2"
			
			for i in $(seq 1 2)
			do
				config_get ActionActiveType SensorEventsActions Action${i}ActiveType
				config_get ActionActiveRelayNo SensorEventsActions Action${i}ActiveRelayNo
				config_get ActionActiveRelayAction SensorEventsActions Action${i}ActiveRelayAction
				config_get ActionActiveRelayOnTimeOut SensorEventsActions Action${i}ActiveRelayOnTimeOut
				config_get ActionActiveRelayOffTimeOut SensorEventsActions Action${i}ActiveRelayOffTimeOut
				
				if [ "$ActionActiveType" = "relay" ]
				then
					echo "ShutterAction${i}AlarmRelayNumber=${ActionActiveRelayNo}"
				else
					echo "ShutterAction${i}AlarmRelayNumber=-1"
				fi
				
				echo "ShutterAction${i}AlarmRelayAction=${ActionActiveRelayAction}"
				echo "ShutterAction${i}AlarmRelayOnTimeOut=${ActionActiveRelayOnTimeOut}"
				echo "ShutterAction${i}AlarmRelayOffTimeOut=${ActionActiveRelayOffTimeOut}"

				config_get ActionInactiveType SensorEventsActions Action${i}InactiveType
				config_get ActionInactiveRelayNo SensorEventsActions Action${i}InactiveRelayNo
				config_get ActionInactiveRelayAction SensorEventsActions Action${i}InactiveRelayAction
				config_get ActionInactiveRelayOnTimeOut SensorEventsActions Action${i}InactiveRelayOnTimeOut
				config_get ActionInactiveRelayOffTimeOut SensorEventsActions Action${i}InactiveRelayOffTimeOut
				
				if [ "$ActionInactiveType" = "relay" ]
				then
					echo "ShutterAction${i}NormalRelayNumber=${ActionInactiveRelayNo}"
				else
					echo "ShutterAction${i}NormalRelayNumber=-1"
				fi
				
				echo "ShutterAction${i}NormalRelayAction=${ActionInactiveRelayAction}"
				echo "ShutterAction${i}NormalRelayOnTimeOut=${ActionInactiveRelayOnTimeOut}"
				echo "ShutterAction${i}NormalRelayOffTimeOut=${ActionInactiveRelayOffTimeOut}"

				if [ "$SensorType" = "2" ] || [ "$SensorType" = "3" ]
				then
					config_get ActionNormalType SensorEventsActions Action${i}NormalType
					config_get ActionNormalRelayNo SensorEventsActions Action${i}NormalRelayNo
					config_get ActionNormalRelayAction SensorEventsActions Action${i}NormalRelayAction
					config_get ActionNormalRelayOnTimeOut SensorEventsActions Action${i}NormalRelayOnTimeOut
					config_get ActionNormalRelayOffTimeOut SensorEventsActions Action${i}NormalRelayOffTimeOut
					
					if [ "$ActionNormalType" = "relay" ]
					then
						echo "ShutterAction${i}LowAlarmRelayNumber=${ActionNormalRelayNo}"
					else
						echo "ShutterAction${i}LowAlarmRelayNumber=-1"
					fi
					
					echo "ShutterAction${i}LowAlarmRelayAction=${ActionNormalRelayAction}"
					echo "ShutterAction${i}LowAlarmRelayOnTimeOut=${ActionNormalRelayOnTimeOut}"
					echo "ShutterAction${i}LowAlarmRelayOffTimeOut=${ActionNormalRelayOffTimeOut}"
					
				fi
			done
		fi
	} >> "$BLCEventsConfigcfgpath"
}			

updateBLC()
{
	rm -rf "${BLCEventsConfigcfgpath}"
	config_load "${BLCsrcpath}"
	config_foreach updateBLCcfg SensorEventsActions	
	#echo "NoOfEvents=${NoOfEvents}" >> "$BLCEventsConfigcfgpath"
	
	#rm -rf "${BLCAIlimitscfgpath}"
	#config_load "$AIsrcpath"
	#{
		#config_get numberOfAI analoginputconfig numberOfAI
		#echo "NoOfAI=${numberOfAI}"
		
		#for i in $(seq 1 $numberOfAI)
		#do
			#config_get AInputUpperThreshold analoginputconfig AInput${i}UpperThreshold
			#config_get AInputLowerThreshold analoginputconfig AInput${i}LowerThreshold
			
			#echo "AI${i}UpperThreshold=${AInputUpperThreshold}"
			#echo "AI${i}LowerThreshold=${AInputLowerThreshold}"
		#done
	#} >> "$BLCAIlimitscfgpath"
}

echo hi
updateBLC
	
