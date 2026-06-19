#!/bin/sh
. /lib/functions.sh

RS485DeviceCfgDirPath="/root/EnergyMeterAppComponent/etc/Config"
CloudconfigureCfgPath="${RS485DeviceCfgDirPath}/Cloudconfig1"
CloudconfigureCfgPath2="${RS485DeviceCfgDirPath}/Cloudconfig2"
CloudconfigureFile="cloudconfigGeneric"

slavedatasendingenable=$(uci get cloudconfig.cloudconfig.slaveDataSending)

# Remove the old config file
rm -f "${CloudconfigureCfgPath}.cfg"
rm -f "${CloudconfigureCfgPath2}.cfg"

UpdateCloudConfig() {
    config_load "$CloudconfigureFile"
    index=0
    index2=0
    config_foreach process_cloud_config cloudConfig
}

process_cloud_config() {
    #config_get enableSlaveDatastatus "$1" "enableSlaveDatastatus"
    config_get enableSlaveCloudDatastatus "$1" "enableSlaveCloudDatastatus"
    config_get datasendingmethod "$1" "dataSendingMethod"
    config_get topicname "$1" "topicname"
    config_get topicnametwo "$1" "topicnametwo"
    config_get enableJsonHeaderKeystatus "$1" "enableJsonHeaderKeystatus"
    config_get jsonHeaderKeyName "$1" "jsonHeaderKeyName"
    config_get enableCustomFieldStatus1 "$1" "enableCustomFieldStatus1"
    config_get jsonKeyName1 "$1" "jsonKeyName1"
    config_get jsonKeyValue1 "$1" "jsonKeyValue1"
    config_get enableCustomFieldStatus2 "$1" "enableCustomFieldStatus2"
    config_get jsonKeyName2 "$1" "jsonKeyName2"
    config_get jsonKeyValue2 "$1" "jsonKeyValue2"
    config_get enableCustomFieldStatus3 "$1" "enableCustomFieldStatus3"
    config_get jsonKeyName3 "$1" "jsonKeyName3"
    config_get jsonKeyValue3 "$1" "jsonKeyValue3"
    config_get topicnametwo "$1" "topicnametwo"
serialport1=$(uci get DeviceConfigGeneric.$1.serialport1)

    
		    if [ "$serialport1" = "1" ]; then
			index=$((index + 1))

{
        echo "slavedatasendingenable_${index}=${slavedatasendingenable}"
        #echo "cloudconfigenable_${index}=${enableSlaveCloudDatastatus}"
        
        
       # echo "datasendingmethod_${index}=${datasendingmethod}"

		if [[ "$datasendingmethod" == "1" ]]; then
			echo "datasendingmethod_${index}=$datasendingmethod"
		elif [[ "$datasendingmethod" == "2" ]]; then
			echo "datasendingmethod_${index}=3"
		else
			echo "datasendingmethod_${index}=2"			
		fi        
		
		
		
		if [[ "$datasendingmethod" == "1" ]]; then
			echo "topicname1_${index}=\"${topicname}\""
		elif [[ "$datasendingmethod" == "2" ]]; then
			echo "topicname2_${index}=\"${topicnametwo}\""
		else
			echo "topicname1_${index}=\"${topicname}\""
			echo "topicname2_${index}=\"${topicnametwo}\""			
		fi        
        echo "jsonheaderkeyenable_${index}=${enableJsonHeaderKeystatus}"

        if [ "${enableJsonHeaderKeystatus}" = "1" ]; then
            echo "jsonheaderkeyname_${index}=\"${jsonHeaderKeyName}\""
        fi

        echo "customfield1_${index}=${enableCustomFieldStatus1}"
        if [ "${enableCustomFieldStatus1}" = "1" ]; then
            echo "customjsonkeyname1_${index}=\"${jsonKeyName1}\""
            echo "customjsonkeyvalue1_${index}=\"${jsonKeyValue1}\""
        fi

        echo "customfield2_${index}=${enableCustomFieldStatus2}"
        if [ "${enableCustomFieldStatus2}" = "1" ]; then
            echo "customjsonkeyname2_${index}=\"${jsonKeyName2}\""
            echo "customjsonkeyvalue2_${index}=\"${jsonKeyValue2}\""
        fi

        echo "customfield3_${index}=${enableCustomFieldStatus3}"
        if [ "${enableCustomFieldStatus3}" = "1" ]; then
            echo "customjsonkeyname3_${index}=\"${jsonKeyName3}\""
            echo "customjsonkeyvalue3_${index}=\"${jsonKeyValue3}\""
        fi
        
        
        
    } >> "${CloudconfigureCfgPath}.cfg"
			sed -i 's/\s*$//' "${CloudconfigureCfgPath}.cfg"
            sed -i -e '/=$/d' "${CloudconfigureCfgPath}.cfg"
        
	fi
			    if [ "$serialport1" = "2" ]; then
			        index2=$((index2 + 1))
{

        echo "slavedatasendingenable_${index2}=${slavedatasendingenable}"
        #echo "cloudconfigenable_${index2}=${enableSlaveCloudDatastatus}"
        echo "datasendingmethod_${index2}=${datasendingmethod}"
        if [ "$datasendingmethod =1" ]; then
        echo "topicname1_${index2}=\"${topicname}\""
        else
         echo "topicname1_${index2}=\"${topicname}\""
         echo "topicname2_${index2}=\"${topicnametwo}\""
         
        fi
        echo "jsonheaderkeyenable_${index2}=${enableJsonHeaderKeystatus}"

        if [ "${enableJsonHeaderKeystatus}" = "1" ]; then
            echo "jsonheaderkeyname_${index2}=\"${jsonHeaderKeyName}\""
        fi

        echo "customfield1_${index2}=${enableCustomFieldStatus1}"
        if [ "${enableCustomFieldStatus1}" = "1" ]; then
            echo "customjsonkeyname1_${index2}=\"${jsonKeyName1}\""
            echo "customjsonkeyvalue1_${index2}=\"${jsonKeyValue1}\""
        fi

        echo "customfield2_${index2}=${enableCustomFieldStatus2}"
        if [ "${enableCustomFieldStatus2}" = "1" ]; then
            echo "customjsonkeyname2_${index2}=\"${jsonKeyName2}\""
            echo "customjsonkeyvalue2_${index2}=\"${jsonKeyValue2}\""
        fi

        echo "customfield3_${index2}=${enableCustomFieldStatus3}"
        if [ "${enableCustomFieldStatus3}" = "1" ]; then
            echo "customjsonkeyname3_${index2}=\"${jsonKeyName3}\""
            echo "customjsonkeyvalue3_${index2}=\"${jsonKeyValue3}\""
        fi
        
        
        
      
    } >> "${CloudconfigureCfgPath2}.cfg"

			sed -i 's/\s*$//' "${CloudconfigureCfgPath2}.cfg"
            sed -i -e '/=$/d' "${CloudconfigureCfgPath2}.cfg"
        fi

}
# Call the function to update the cloud config
UpdateCloudConfig
NoOfDevices1=$((index))
NoOfDevices2=$((index2))

echo "" >> "${CloudconfigureCfgPath}.cfg"
echo "NoOfDevices=$NoOfDevices1" >> "${CloudconfigureCfgPath}.cfg"
echo "NoOfDevices=$NoOfDevices2" >> "${CloudconfigureCfgPath2}.cfg"
