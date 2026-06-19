#!/bin/sh
. /lib/functions.sh

RS485DeviceCfgDirPath="/root/EnergyMeterAppComponent/etc/Config"
PseudoCloudconfigureCfgPath="${RS485DeviceCfgDirPath}/Cloudconfig3"
PseudoCloudconfigureFile="PseudoCloudconfig"
pseudoslavedatasendingenable=$(uci get cloudconfig.cloudconfig.slaveDataSending)

rm -f "${PseudoCloudconfigureCfgPath}.cfg"

UpdatepseudoCloudConfig() {
    config_load "$PseudoCloudconfigureFile" 
    
    index=1 
    config_foreach process_pseudo_cloud_config pseudocloudConfig
}

# Function to process each pseudo cloud config section
process_pseudo_cloud_config() {

    config_get enablepseudoSlaveCloudStatus "$1" "enablepseudoSlaveCloudStatus"
    config_get pseudoDataSendingMethod "$1" "pseudoDataSendingMethod"
    config_get pseudoTopicName "$1" "pseudoTopicName"
    config_get pseudoTopicNameTwo "$1" "pseudoTopicNameTwo"
    config_get enablepseudoJsonHeaderKeyStatus "$1" "enablepseudoJsonHeaderKeyStatus"
    config_get pseudoJsonHeaderKeyName "$1" "pseudoJsonHeaderKeyName"
    config_get pseudocustomfield1 "$1" "enablepseudoCustomFieldStatus1"
    config_get pseudocustomjsonkeyname1 "$1" "pseudoJsonKeyName1"
    config_get pseudocustomjsonkeyvalue1 "$1" "pseudoJsonKeyValue1"
    config_get pseudocustomfield2 "$1" "enablepseudoCustomFieldStatus2"
    config_get pseudocustomjsonkeyname2 "$1" "pseudoJsonKeyName2"
    config_get pseudocustomjsonkeyvalue2 "$1" "pseudoJsonKeyValue2"
    config_get pseudocustomfield3 "$1" "enablepseudoCustomFieldStatus3"   
    config_get pseudocustomjsonkeyname3 "$1" "pseudoJsonKeyName3"
    config_get pseudocustomjsonkeyvalue3 "$1" "pseudoJsonKeyValue3"
   pseudoslavedatasendingenable=$(uci get cloudconfig.cloudconfig.slaveDataSending)
 
if  [ "$pseudoslavedatasendingenable" = "1" ]; then

    {
		
        echo "slavedatasendingenable_${index}=${pseudoslavedatasendingenable}"
        #echo "pseudocloudconfigenable_${index}=${enablepseudoSlaveCloudStatus}"
        #echo "datasendingmethod_${index}=${pseudoDataSendingMethod}"
         
		if [[ "$pseudoDataSendingMethod" == "1" ]]; then
		echo "datasendingmethod_${index}=${pseudoDataSendingMethod}"
		elif [[ "$pseudoDataSendingMethod" == "2" ]]; then
		echo "datasendingmethod_${index}=3"
		else
		echo "datasendingmethod_${index}=2"		
		fi
		if [[ "$pseudoDataSendingMethod" == "1" ]]; then
			echo "topicname1_${index}=\"${pseudoTopicName}\""
		elif [[ "$pseudoDataSendingMethod" == "2" ]]; then
			echo "topicname2_${index}=\"${pseudoTopicNameTwo}\""
		else
			echo "topicname1_${index}=\"${pseudoTopicName}\""
			echo "topicname2_${index}=\"${pseudoTopicNameTwo}\""			
		fi
        echo "jsonheaderkeyenable_${index}=$enablepseudoJsonHeaderKeyStatus"

        if [ "${enablepseudoJsonHeaderKeyStatus}" = "1" ]; then
            echo "jsonheaderkeyname_${index}=\"${pseudoJsonHeaderKeyName}\""
        fi

        echo "customfield1_${index}=${pseudocustomfield1}"
        if [ "${pseudocustomfield1}" = "1" ]; then
            echo "customjsonkeyname1_${index}=\"${pseudocustomjsonkeyname1}\""
            echo "customjsonkeyvalue1_${index}=\"${pseudocustomjsonkeyvalue1}\""
        fi

        echo "customfield2_${index}=${pseudocustomfield2}"
        if [ "${pseudocustomfield2}" = "1" ]; then
            echo "customjsonkeyname2_${index}=\"${pseudocustomjsonkeyname2}\""
            echo "customjsonkeyvalue2_${index}=\"${pseudocustomjsonkeyvalue2}\""
        fi

        echo "customfield3_${index}=${pseudocustomfield3}"
        if [ "${pseudocustomfield3}" = "1" ]; then
            echo "customjsonkeyname3_${index}=\"${pseudocustomjsonkeyname3}\""
            echo "customjsonkeyvalue3_${index}=\"${pseudocustomjsonkeyvalue3}\""
        fi
    } >> "${PseudoCloudconfigureCfgPath}.cfg"

    # Increment index for the next section
    index=$((index + 1))
    fi
}


# Call the function to update the pseudo cloud config
UpdatepseudoCloudConfig

# Print the number of devices
NoOfDevices=$((index - 1))
echo "NoOfDevices=$NoOfDevices" >> "${PseudoCloudconfigureCfgPath}.cfg"
