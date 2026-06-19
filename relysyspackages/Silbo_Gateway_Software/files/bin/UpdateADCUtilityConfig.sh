#!/bin/sh
. /lib/functions.sh

#AIO Configuration
AIODeviceCfgDirPath="/root/ADCUtilityComponent/etc/Config"
AIODeviceconfigureCfgPath="${AIODeviceCfgDirPath}/ADCUtilityConfig"
AIOEventfile="ADCUtilityConfigGeneric"
AIOconfigureEventSection="adcutilityconfig"


UpdateADCfg()
{
	rm "${AIODeviceconfigureCfgPath}.cfg" 

	config_load "$AIOEventfile"
    config_get  SamplingRate                  "$AIOconfigureEventSection"    SamplingRate 
    config_get  ConversionMode                  "$AIOconfigureEventSection"    ConversionMode 
    config_get  NoOfSamples                  "$AIOconfigureEventSection"    NoOfSamples 
    config_get  filename                  "$AIOconfigureEventSection"    filename 
    config_get  ADCType                  "$AIOconfigureEventSection"    ADCType 
    config_get  NoOfInputs                  "$AIOconfigureEventSection"    NoOfInputs 
    config_get  address_1                  "$AIOconfigureEventSection"    address_1 
    config_get  address_2                  "$AIOconfigureEventSection"    address_2 
    config_get  address_3                  "$AIOconfigureEventSection"    address_3 
    config_get  address_4                  "$AIOconfigureEventSection"    address_4 
    config_get  CurDevResistance_1                  "$AIOconfigureEventSection"    CurDevResistance_1 
    config_get  CurDevResistance_2                  "$AIOconfigureEventSection"    CurDevResistance_2 
    config_get  CurDevResistance_3                  "$AIOconfigureEventSection"    CurDevResistance_3 
    config_get  CurDevResistance_4                  "$AIOconfigureEventSection"    CurDevResistance_4
    config_get  VolMultiplier_1                  "$AIOconfigureEventSection"    VolMultiplier_1
    config_get  VolMultiplier_2                  "$AIOconfigureEventSection"    VolMultiplier_2
    config_get  VolMultiplier_3                  "$AIOconfigureEventSection"    VolMultiplier_3
    config_get  VolMultiplier_4                  "$AIOconfigureEventSection"    VolMultiplier_4
    config_get  offset_1                  "$AIOconfigureEventSection"    offset_1
    config_get  offset_2                  "$AIOconfigureEventSection"    offset_2
    config_get  offset_3                  "$AIOconfigureEventSection"    offset_3
    config_get  offset_4                  "$AIOconfigureEventSection"    offset_4
    ChannelType1=$(uci get analoginputconfig.analoginputconfig.ChannelType1)
    ChannelType2=$(uci get analoginputconfig.analoginputconfig.ChannelType2)
    ChannelType3=$(uci get analoginputconfig.analoginputconfig.ChannelType3)
    ChannelType4=$(uci get analoginputconfig.analoginputconfig.ChannelType4)
    
     {
		 
		
		 echo "SamplingRate=$SamplingRate"
		 echo "ConversionMode=$ConversionMode"
		 echo "NoOfSamples=$NoOfSamples"
		 echo "NoOfInputs=$NoOfInputs"
		 echo "# type=1 : (16 bit type) type=2 : (12 bit type)"
		 echo "ADCType=$ADCType"
		 echo "filename=\"$filename\""
		 
		 echo "########## AIO1 Configuration############"
		 echo "address_1=$address_1"
		 echo "CurDevResistance_1=$CurDevResistance_1"
		 echo "VolMultiplier_1=$VolMultiplier_1"
		 echo "ChannelType_1=$ChannelType1"
		 echo "offset_1=$offset_1"
		
		 echo "########## AIO2 Configuration############"
		 echo "address_2=$address_2"
		 echo "CurDevResistance_2=$CurDevResistance_2"
		 echo "VolMultiplier_2=$VolMultiplier_2"
		 echo "ChannelType_2=$ChannelType2"
		 echo "offset_2=$offset_2"
		 
		 echo "########## AIO3 Configuration############"
		 echo "address_3=$address_3"
		 echo "CurDevResistance_3=$CurDevResistance_3"
		 echo "VolMultiplier_3=$VolMultiplier_3"
		 echo "ChannelType_3=$ChannelType3"
		 echo "offset_3=$offset_3"
		 
		 echo "########## AIO4 Configuration############"
		 echo "address_4=$address_4"
		 echo "CurDevResistance_4=$CurDevResistance_4"
		 echo "VolMultiplier_4=$VolMultiplier_4"
		 echo "ChannelType_4=$ChannelType4"
		 echo "offset_4=$offset_4"
		 
		 
	 } >>  "${AIODeviceconfigureCfgPath}.cfg" 
	
	
	sed -i 's/\s*$//' "${AIODeviceconfigureCfgPath}.cfg"  
    sed -i -e '/=$/d' "${AIODeviceconfigureCfgPath}.cfg" 
    
}
UpdateADCfg

