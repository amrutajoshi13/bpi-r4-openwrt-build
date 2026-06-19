#!/bin/sh
. /lib/functions.sh


#AIO Configuration
AIODeviceCfgDirPath="/root/ReadAIAppComponent/etc/Config"
AIODeviceconfigureCfgPath="${AIODeviceCfgDirPath}/ReadAIAppWebConfig"
AIODeviceAppconfigureCfgPath="${AIODeviceCfgDirPath}/ReadAIAppConfig"
AIODeviceAppMaintainanceconfigureCfgPath="${AIODeviceCfgDirPath}/ReadAIAppMaintenance"
AIOEventfile="analoginputconfig"
AIOconfigureEventSection="analoginputconfig"
AIOAppEventfile="ADCUtilityConfigGeneric"
AIOconfigureAppEventSection="adcutilityconfig"
rm "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg" 
 
ChannelType1=$(uci get analoginputconfig.analoginputconfig.ChannelType1)
ChannelType2=$(uci get analoginputconfig.analoginputconfig.ChannelType2)
ChannelType3=$(uci get analoginputconfig.analoginputconfig.ChannelType3)
ChannelType4=$(uci get analoginputconfig.analoginputconfig.ChannelType4)
ADCType=$(uci get ADCUtilityConfigGeneric.adcutilityconfig.ADCType)
  
		NoOfAInput=$(uci get analoginputconfig.analoginputconfig.NoOfInputs)

		if [[ $ChannelType1 -eq 1 ]]; then
			echo "AInput1InputType=\"current_mA\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		elif [[ $ChannelType1 -eq 2 ]]; then
			echo "AInput1InputType=\"voltage_mV\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		fi						
		if [[ $ChannelType2 -eq 1 ]]; then 
			echo "AInput2InputType=\"current_mA\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		elif [[ $ChannelType2 -eq 2 ]]; then
			echo "AInput2InputType=\"voltage_mV\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		fi						
		if [[ $ChannelType3 -eq 1 ]]; then
			echo "AInput3InputType=\"current_mA\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		elif [[ $ChannelType3 -eq 2 ]]; then
			echo "AInput3InputType=\"voltage_mV\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		fi						
		if [[ $ChannelType4 -eq 1 ]]; then
			echo "AInput4InputType=\"current_mA\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		elif [[ $ChannelType4 -eq 2 ]]; then
			echo "AInput4InputType=\"voltage_mV\"" >> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"
		fi	
							
		echo "# type=1 : (16 bit type) type=2 : (12 bit type)"	>> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"	
		echo "ADCType=$ADCType"	>> "${AIODeviceAppMaintainanceconfigureCfgPath}.cfg"	


  
UpdateAIOAPPCfg()
{
	rm "${AIODeviceAppconfigureCfgPath}.cfg" 

	config_load "$AIOAppEventfile"
    config_get  SamplingRate                  "$AIOconfigureAppEventSection"    SamplingRate 
    config_get  ConversionMode                  "$AIOconfigureAppEventSection"    ConversionMode
    config_get  CurDevResistance_1                  "$AIOconfigureAppEventSection"    CurDevResistance_1
    config_get  CurDevResistance_2                  "$AIOconfigureAppEventSection"    CurDevResistance_3
    config_get  CurDevResistance_3                  "$AIOconfigureAppEventSection"    CurDevResistance_3
    config_get  CurDevResistance_4                  "$AIOconfigureAppEventSection"    CurDevResistance_4
    config_get  VolMultiplier_1                  "$AIOconfigureAppEventSection"    VolMultiplier_1
    config_get  VolMultiplier_2                  "$AIOconfigureAppEventSection"    VolMultiplier_2
    config_get  VolMultiplier_3                  "$AIOconfigureAppEventSection"    VolMultiplier_3
    config_get  VolMultiplier_4                  "$AIOconfigureAppEventSection"    VolMultiplier_4
    config_get  offset_1                  "$AIOconfigureAppEventSection"    offset_1
    config_get  offset_2                  "$AIOconfigureAppEventSection"    offset_2
    config_get  offset_3                  "$AIOconfigureAppEventSection"    offset_3
    config_get  offset_4                  "$AIOconfigureAppEventSection"    offset_4
    
    ChannelType1=$(uci get analoginputconfig.analoginputconfig.ChannelType1)
    ChannelType2=$(uci get analoginputconfig.analoginputconfig.ChannelType2)
    ChannelType3=$(uci get analoginputconfig.analoginputconfig.ChannelType3)
    ChannelType4=$(uci get analoginputconfig.analoginputconfig.ChannelType4)
       
        {
			
	if [ "$NoOfAInput" -ge 1 ]; then		
		echo "########## AIO1 Configuration############"
		echo "AInput1SamplingRate=$SamplingRate"				
		echo "AInput1ConversionMode=$ConversionMode"		
		echo "AInput1InputRange=2"		
		echo "AInput1ChannelNumber=1"		
		echo "AInput1CurDevResistance=$CurDevResistance_1"		
		echo "AInput1offset=$offset_1"		
		echo "AInput1VolMultiplier=$VolMultiplier_1"		
	fi
	if [ "$NoOfAInput" -ge 2 ]; then	
		echo "########## AIO2 Configuration############"
		echo "AInput2SamplingRate=$SamplingRate"				
		echo "AInput2ConversionMode=$ConversionMode"		
		echo "AInput2InputRange=2"		
		echo "AInput2ChannelNumber=2"		
		echo "AInput2CurDevResistance=$CurDevResistance_2"	
		echo "AInput2offset=$offset_2"			
		echo "AInput2VolMultiplier=$VolMultiplier_2"		
	fi
	if [ "$NoOfAInput" -ge 3 ]; then		
		echo "########## AIO3 Configuration############"
		echo "AInput3SamplingRate=$SamplingRate"				
		echo "AInput3ConversionMode=$ConversionMode"		
		echo "AInput3InputRange=2"		
		echo "AInput3ChannelNumber=1"		
		echo "AInput3CurDevResistance=$CurDevResistance_3"	
		echo "AInput3offset=$offset_3"			
		echo "AInput3VolMultiplier=$VolMultiplier_3"		
	fi
	if [ "$NoOfAInput" -ge 4 ]; then	
		echo "########## AIO4 Configuration############"
		echo "AInput4SamplingRate=$SamplingRate"				
		echo "AInput4ConversionMode=$ConversionMode"		
		echo "AInput4InputRange=2"		
		echo "AInput4ChannelNumber=2"		
		echo "AInput4CurDevResistance=$CurDevResistance_4"	
		echo "AInput4offset=$offset_4"			
		echo "AInput4VolMultiplier=$VolMultiplier_4"		
	fi	

		
		
	} >>  "${AIODeviceAppconfigureCfgPath}.cfg" 
	
	
	sed -i 's/\s*$//' "${AIODeviceAppconfigureCfgPath}.cfg"  
    sed -i -e '/=$/d' "${AIODeviceAppconfigureCfgPath}.cfg" 
   
} 

UpdateAIOCfg()
{
	rm "${AIODeviceconfigureCfgPath}.cfg" 

	config_load "$AIOEventfile"
    config_get  NoOfInputs                  "$AIOconfigureEventSection"    NoOfInputs 
    config_get  AInputBurstMode                  "$AIOconfigureEventSection"    AInputBurstMode 
    config_get  AInput1Enable                  "$AIOconfigureEventSection"    AInput1Enable
    config_get  AInput1AlarmActiveState                  "$AIOconfigureEventSection"    AInput1AlarmActiveState
    config_get  AInput1UpperThreshold                  "$AIOconfigureEventSection"    AInput1UpperThreshold
    config_get  AInput1UpperHysteresis                  "$AIOconfigureEventSection"    AInput1UpperHysteresis
    config_get  AInput1LowerThreshold                  "$AIOconfigureEventSection"    AInput1LowerThreshold
    config_get  AInput1LowerHysteresis                  "$AIOconfigureEventSection"    AInput1LowerHysteresis
    config_get  AInput1TimeDependency                  "$AIOconfigureEventSection"    AInput1TimeDependency
    config_get  AInput1AlarmStartTime                  "$AIOconfigureEventSection"    AInput1AlarmStartTime
    config_get  AInput1AlarmStopTime                  "$AIOconfigureEventSection"    AInput1AlarmStopTime
    config_get  AInput1DayDependency                  "$AIOconfigureEventSection"    AInput1DayDependency
    config_get  AInput1DayDependencyValue                  "$AIOconfigureEventSection"    AInput1DayDependencyValue
    config_get  AInput1MultiplicationFactorEnable                  "$AIOconfigureEventSection"    AInput1MultiplicationFactorEnable
    config_get  AInput1MultiplicationFactor                  "$AIOconfigureEventSection"    AInput1MultiplicationFactor
    config_get  AInput1Transducermax                  "$AIOconfigureEventSection"    AInput1Transducermax
    config_get  AInput1Transducermin                  "$AIOconfigureEventSection"    AInput1Transducermin
    config_get  AInput1Rawmax                 "$AIOconfigureEventSection"    AInput1Rawmax
    config_get  AInput1Rawmin                  "$AIOconfigureEventSection"    AInput1Rawmin
    config_get  AInput1ClampEnable                  "$AIOconfigureEventSection"    AInput1ClampEnable
    config_get  AInput1ClampMax                  "$AIOconfigureEventSection"    AInput1ClampMax
    config_get  AInput1ClampMin                  "$AIOconfigureEventSection"    AInput1ClampMin

    
    
	config_get  AInput2Enable                  "$AIOconfigureEventSection"    AInput2Enable
    config_get  AInput2AlarmActiveState                  "$AIOconfigureEventSection"    AInput2AlarmActiveState
    config_get  AInput2UpperThreshold                  "$AIOconfigureEventSection"    AInput2UpperThreshold
    config_get  AInput2UpperHysteresis                  "$AIOconfigureEventSection"    AInput2UpperHysteresis
    config_get  AInput2LowerThreshold                  "$AIOconfigureEventSection"    AInput2LowerThreshold
    config_get  AInput2LowerHysteresis                  "$AIOconfigureEventSection"    AInput2LowerHysteresis
    config_get  AInput2TimeDependency                  "$AIOconfigureEventSection"    AInput2TimeDependency
    config_get  AInput2AlarmStartTime                  "$AIOconfigureEventSection"    AInput2AlarmStartTime
    config_get  AInput2AlarmStopTime                  "$AIOconfigureEventSection"    AInput2AlarmStopTime
    config_get  AInput2DayDependency                  "$AIOconfigureEventSection"    AInput2DayDependency
    config_get  AInput2DayDependencyValue                  "$AIOconfigureEventSection"    AInput2DayDependencyValue
    config_get  AInput2MultiplicationFactorEnable                  "$AIOconfigureEventSection"    AInput2MultiplicationFactorEnable
    config_get  AInput2MultiplicationFactor                  "$AIOconfigureEventSection"    AInput2MultiplicationFactor
    config_get  AInput2Transducermax                  "$AIOconfigureEventSection"    AInput2Transducermax
    config_get  AInput2Transducermin                  "$AIOconfigureEventSection"    AInput2Transducermin
    config_get  AInput2Rawmax                 "$AIOconfigureEventSection"    AInput2Rawmax
    config_get  AInput2Rawmin                  "$AIOconfigureEventSection"    AInput2Rawmin
    config_get  AInput2ClampEnable                  "$AIOconfigureEventSection"    AInput2ClampEnable
    config_get  AInput2ClampMax                  "$AIOconfigureEventSection"    AInput2ClampMax
    config_get  AInput2ClampMin                  "$AIOconfigureEventSection"    AInput2ClampMin
    
    config_get  AInput3Enable                  "$AIOconfigureEventSection"    AInput3Enable
    config_get  AInput3AlarmActiveState                  "$AIOconfigureEventSection"    AInput3AlarmActiveState
    config_get  AInput3UpperThreshold                  "$AIOconfigureEventSection"    AInput3UpperThreshold
    config_get  AInput3UpperHysteresis                  "$AIOconfigureEventSection"    AInput3UpperHysteresis
    config_get  AInput3LowerThreshold                  "$AIOconfigureEventSection"    AInput3LowerThreshold
    config_get  AInput3LowerHysteresis                  "$AIOconfigureEventSection"    AInput3LowerHysteresis
    config_get  AInput3TimeDependency                  "$AIOconfigureEventSection"    AInput3TimeDependency
    config_get  AInput3AlarmStartTime                  "$AIOconfigureEventSection"    AInput3AlarmStartTime
    config_get  AInput3AlarmStopTime                  "$AIOconfigureEventSection"    AInput3AlarmStopTime
    config_get  AInput3DayDependency                  "$AIOconfigureEventSection"    AInput3DayDependency
    config_get  AInput3DayDependencyValue                  "$AIOconfigureEventSection"    AInput3DayDependencyValue
    config_get  AInput3MultiplicationFactorEnable                  "$AIOconfigureEventSection"    AInput3MultiplicationFactorEnable
    config_get  AInput3MultiplicationFactor                  "$AIOconfigureEventSection"    AInput3MultiplicationFactor
    config_get  AInput3Transducermax                  "$AIOconfigureEventSection"    AInput3Transducermax
    config_get  AInput3Transducermin                  "$AIOconfigureEventSection"    AInput3Transducermin
    config_get  AInput3Rawmax                 "$AIOconfigureEventSection"    AInput3Rawmax
    config_get  AInput3Rawmin                  "$AIOconfigureEventSection"    AInput3Rawmin
    config_get  AInput3ClampEnable                  "$AIOconfigureEventSection"    AInput3ClampEnable
    config_get  AInput3ClampMax                  "$AIOconfigureEventSection"    AInput3ClampMax
    config_get  AInput3ClampMin                  "$AIOconfigureEventSection"    AInput3ClampMin
  
    config_get  AInput4Enable                  "$AIOconfigureEventSection"    AInput4Enable
    config_get  AInput4AlarmActiveState                  "$AIOconfigureEventSection"    AInput4AlarmActiveState
    config_get  AInput4UpperThreshold                  "$AIOconfigureEventSection"    AInput4UpperThreshold
    config_get  AInput4UpperHysteresis                  "$AIOconfigureEventSection"    AInput4UpperHysteresis
    config_get  AInput4LowerThreshold                  "$AIOconfigureEventSection"    AInput4LowerThreshold
    config_get  AInput4LowerHysteresis                  "$AIOconfigureEventSection"    AInput4LowerHysteresis
    config_get  AInput4TimeDependency                  "$AIOconfigureEventSection"    AInput4TimeDependency
    config_get  AInput4AlarmStartTime                  "$AIOconfigureEventSection"    AInput4AlarmStartTime
    config_get  AInput4AlarmStopTime                  "$AIOconfigureEventSection"    AInput4AlarmStopTime
    config_get  AInput4DayDependency                  "$AIOconfigureEventSection"    AInput4DayDependency
    config_get  AInput4DayDependencyValue                  "$AIOconfigureEventSection"    AInput4DayDependencyValue
    config_get  AInput4MultiplicationFactorEnable                  "$AIOconfigureEventSection"    AInput4MultiplicationFactorEnable
    config_get  AInput4MultiplicationFactor                  "$AIOconfigureEventSection"    AInput4MultiplicationFactor
    config_get  AInput4Transducermax                  "$AIOconfigureEventSection"    AInput4Transducermax
    config_get  AInput4Transducermin                  "$AIOconfigureEventSection"    AInput4Transducermin
    config_get  AInput4Rawmax                 "$AIOconfigureEventSection"    AInput4Rawmax
    config_get  AInput4Rawmin                  "$AIOconfigureEventSection"    AInput4Rawmin
    config_get  AInput4ClampEnable                  "$AIOconfigureEventSection"    AInput4ClampEnable
    config_get  AInput4ClampMax                  "$AIOconfigureEventSection"    AInput4ClampMax
    config_get  AInput4ClampMin                  "$AIOconfigureEventSection"    AInput4ClampMin
    {
		
		
		
		
		NoOfAInput=$(uci get analoginputconfig.analoginputconfig.NoOfInputs)
		
		if [ "$NoOfAInput" -ge 1 ]; then
		
		echo "########## AIO1 Configuration############"
		echo "AInput1Enable=$AInput1Enable"				
		echo "AInput1MultiplicationFactorEnable=$AInput1MultiplicationFactorEnable"		
		if [ "$AInput1MultiplicationFactorEnable" = "1" ]
        then
			echo "AInput1MultiplicationFactor=$AInput1MultiplicationFactor"
		elif [ "$AInput1MultiplicationFactorEnable" = "2" ]	
		then
		    echo "AInput1MultiplicationFactor=$AInput1MultiplicationFactor"
		    echo "AInput1Transducermax=$AInput1Transducermax"
		    echo "AInput1Transducermin=$AInput1Transducermin"
		    echo "AInput1Rawmax=$AInput1Rawmax"
		    echo "AInput1Rawmin=$AInput1Rawmin"
		    echo "AInput1ClampEnable=$AInput1ClampEnable"
		    if [ "$AInput1ClampEnable" = "1" ]
            then
			    echo "AInput1ClampMax=$AInput1ClampMax"
			    echo "AInput1ClampMin=$AInput1ClampMin"
		    fi
            
        fi	
		echo "AInput1AlarmActiveState=$AInput1AlarmActiveState"
		echo "AInput1UpperThreshold=$AInput1UpperThreshold"
		echo "AInput1UpperHysteresis=$AInput1UpperHysteresis"
		echo "AInput1LowerThreshold=$AInput1LowerThreshold"
		echo "AInput1LowerHysteresis=$AInput1LowerHysteresis"
		echo "AInput1TimeDependency=$AInput1TimeDependency"
		echo "AInput1HolidayCheckStartTime=\"$AInput1AlarmStartTime\""
		echo "AInput1HolidayCheckEndTime=\"$AInput1AlarmStopTime\""
		
		echo "AInput1DayDependency=$AInput1DayDependency"
		echo "AInput1DayDependencyValue=$AInput1DayDependencyValue"
		
		if [ "$AInputBurstMode" = "1" ]
        then
			echo "AInput1NoOfSamples=1"
        else
			echo "AInput1NoOfSamples=20"    
        fi

		echo ""
		echo ""
		
	fi
	if [ "$NoOfAInput" -ge 2 ]; then

	
		
		echo "########## AIO2 Configuration############"
		echo "AInput2Enable=$AInput2Enable"		
		echo "AInput2MultiplicationFactorEnable=$AInput2MultiplicationFactorEnable"		
		if [ "$AInput2MultiplicationFactorEnable" = "1" ]
        then
			echo "AInput2MultiplicationFactor=$AInput2MultiplicationFactor"
		elif [ "$AInput2MultiplicationFactorEnable" = "2" ]	
		then
		    echo "AInput2Transducermax=$AInput2Transducermax"
		    echo "AInput2Transducermin=$AInput2Transducermin"
		    echo "AInput2Rawmax=$AInput2Rawmax"
		    echo "AInput2Rawmin=$AInput2Rawmin"	
		    echo "AInput2ClampEnable=$AInput2ClampEnable"
		    if [ "$AInput2ClampEnable" = "1" ]
            then
			    echo "AInput2ClampMax=$AInput2ClampMax"
			    echo "AInput2ClampMin=$AInput2ClampMin"
		    fi
  
        fi	
		echo "AInput2AlarmActiveState=$AInput2AlarmActiveState"
		echo "AInput2UpperThreshold=$AInput2UpperThreshold"
		echo "AInput2UpperHysteresis=$AInput2UpperHysteresis"
		echo "AInput2LowerThreshold=$AInput2LowerThreshold"
		echo "AInput2LowerHysteresis=$AInput2LowerHysteresis"
		echo "AInput2TimeDependency=$AInput2TimeDependency"
		echo "AInput2HolidayCheckStartTime=\"$AInput2AlarmStartTime\""
		echo "AInput2HolidayCheckEndTime=\"$AInput2AlarmStopTime\""
		
		echo "AInput2DayDependency=$AInput2DayDependency"
		echo "AInput2DayDependencyValue=$AInput2DayDependencyValue"
		
		if [ "$AInputBurstMode" = "1" ]
        then
			echo "AInput2NoOfSamples=1"
        else
			echo "AInput2NoOfSamples=20"    
        fi

		echo ""
		echo ""
		
		fi
		
		if [ "$NoOfAInput" -ge 3 ]; then

			echo "########## AIO3 Configuration############"
		echo "AInput3Enable=$AInput1Enable"				
		echo "AInput3MultiplicationFactorEnable=$AInput3MultiplicationFactorEnable"		
		if [ "$AInput3MultiplicationFactorEnable" = "1" ]
        then
			echo "AInput3MultiplicationFactor=$AInput3MultiplicationFactor"
		elif [ "$AInput3MultiplicationFactorEnable" = "2" ]	
		then
		    echo "AInput3Transducermax=$AInput3Transducermax"
		    echo "AInput3Transducermin=$AInput3Transducermin"
		    echo "AInput3Rawmax=$AInput3Rawmax"
		    echo "AInput3Rawmin=$AInput3Rawmin"
		    echo "AInput3ClampEnable=$AInput3ClampEnable"
		    if [ "$AInput3ClampEnable" = "1" ]
            then
			    echo "AInput3ClampMax=$AInput3ClampMax"
			    echo "AInput3ClampMin=$AInput3ClampMin"
		    fi
            
        fi	
		echo "AInput3AlarmActiveState=$AInput3AlarmActiveState"
		echo "AInput3UpperThreshold=$AInput3UpperThreshold"
		echo "AInput3UpperHysteresis=$AInput3UpperHysteresis"
		echo "AInput3LowerThreshold=$AInput3LowerThreshold"
		echo "AInput3LowerHysteresis=$AInput3LowerHysteresis"
		echo "AInput3TimeDependency=$AInput3TimeDependency"
		echo "AInput3HolidayCheckStartTime=\"$AInput3AlarmStartTime\""
		echo "AInput3HolidayCheckEndTime=\"$AInput3AlarmStopTime\""
		
		echo "AInput3DayDependency=$AInput3DayDependency"
		echo "AInput3DayDependencyValue=$AInput3DayDependencyValue"
		
		if [ "$AInputBurstMode" = "1" ]
        then
			echo "AInput3NoOfSamples=1"
        else
			echo "AInput3NoOfSamples=20"    
        fi

		echo ""
		echo ""
		
		fi
		
		if [ "$NoOfAInput" -ge 4 ]; then

		
			echo "########## AIO4 Configuration############"
		echo "AInput4Enable=$AInput4Enable"				
		echo "AInput4MultiplicationFactorEnable=$AInput4MultiplicationFactorEnable"		
		if [ "$AInput4MultiplicationFactorEnable" = "1" ]
        then
			echo "AInput4MultiplicationFactor=$AInput4MultiplicationFactor"
		elif [ "$AInput4MultiplicationFactorEnable" = "2" ]	
		then
		    echo "AInput4Transducermax=$AInput4Transducermax"
		    echo "AInput4Transducermin=$AInput4Transducermin"
		    echo "AInput4Rawmax=$AInput4Rawmax"
		    echo "AInput4Rawmin=$AInput4Rawmin"
		    
		    echo "AInput4ClampEnable=$AInput4ClampEnable"
		    if [ "$AInput4ClampEnable" = "1" ]
            then
			    echo "AInput4ClampMax=$AInput4ClampMax"
			    echo "AInput4ClampMin=$AInput4ClampMin"
		    fi
        fi	
		echo "AInput4AlarmActiveState=$AInput4AlarmActiveState"
		echo "AInput4UpperThreshold=$AInput4UpperThreshold"
		echo "AInput4UpperHysteresis=$AInput4UpperHysteresis"
		echo "AInput4LowerThreshold=$AInput4LowerThreshold"
		echo "AInput4LowerHysteresis=$AInput4LowerHysteresis"
		echo "AInput4TimeDependency=$AInput4TimeDependency"
		echo "AInput4HolidayCheckStartTime=\"$AInput4AlarmStartTime\""
		echo "AInput4HolidayCheckEndTime=\"$AInput4AlarmStopTime\""
		
		echo "AInput4DayDependency=$AInput4DayDependency"
		echo "AInput4DayDependencyValue=$AInput4DayDependencyValue"
		
		if [ "$AInputBurstMode" = "1" ]
        then
			echo "AInput4NoOfSamples=1"
        else
			echo "AInput4NoOfSamples=20"    
        fi

		echo ""
		echo ""
		
	fi	
		#if [ "$AInput1Enable" = "1" ] || [ "$AInput2Enable" = "1" ]
		#then
		#	echo "NoOfAInput=2"
		#elif [ "$AInput1Enable" = "0" ] && [ "$AInput2Enable" = "0" ]
		#then
		#	echo "NoOfAInput=0"
		#fi
		
		
		
		echo "NoOfAInput=$NoOfAInput"
		echo "AInputBurstMode=$AInputBurstMode"
		if [ "$AInputBurstMode" = "1" ]
        then
			echo "AInputNormalMode=0"
        else
			echo "AInputNormalMode=1"    
        fi
		
		
	} >>  "${AIODeviceconfigureCfgPath}.cfg" 
	
	
	sed -i 's/\s*$//' "${AIODeviceconfigureCfgPath}.cfg"  
    sed -i -e '/=$/d' "${AIODeviceconfigureCfgPath}.cfg" 
   
} 


UpdateAIOCfg
UpdateAIOAPPCfg
