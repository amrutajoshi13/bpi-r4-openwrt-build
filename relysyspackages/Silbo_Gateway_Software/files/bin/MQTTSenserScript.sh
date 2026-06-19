#!/bin/sh
. /lib/functions.sh


#MQTT Configuration

MQTTCfgDirPath="/root/SenderAppComponent/etc/Config"
MQTTconfigureCfgPath="${MQTTCfgDirPath}/externalBrokerConfig"
MQTTExternalPath="${MQTTCfgDirPath}/externalTopics"
MQTTEventfile="cloudconfig"
MQTTconfigureEventSection="cloudconfig"
MQTTInternalTopics="${MQTTCfgDirPath}/internalTopics.cfg"

rm -rf "{$MQTTconfigureCfgPath}.cfg"

EnableMQTTCommand=$(uci get cloudconfig.cloudconfig.EnableMQTTCommand)
EnableMQTTCommand2=$(uci get cloudconfig.cloudconfig.EnableMQTTCommand2)



UpdateMQTTConfiguration()
{
    MQTTEnable=$(uci get cloudconfig.cloudconfig.cloudprotocol)
    MQTTEnable1=$(uci get cloudconfig.cloudconfig.cloudprotocol2)

    certs_dir="/root/SenderAppComponent/etc/certs/"
    config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"
    rootCAPathVariable="rootCAPath"
    ClientCertPathVariable="ClientCertPath"
    PrivateKeyPathVariable="PrivateKeyPath"

    # Remove old entries
    sed -i '/rootCAPath/d' "$config_file"
    sed -i '/ClientCertPath/d' "$config_file"
    sed -i '/PrivateKeyPath/d' "$config_file"

    # Append empty entries (will get updated later)
    echo "${rootCAPathVariable}=\"\"" >> "$config_file"
    echo "${ClientCertPathVariable}=\"\"" >> "$config_file"
    echo "${PrivateKeyPathVariable}=\"\"" >> "$config_file"

    # Find certificate file paths
    rootCA_file_path=$(find "$certs_dir" -name "*.pem" -type f | grep -E "RootCA|CA" | head -1)
    clientCert_file_path=$(find "$certs_dir" -name "*.cert.pem" -type f | head -1)
    privateKey_file_path=$(find "$certs_dir" -name "*.private.key" -type f | head -1)

    # Root CA
    if [[ -n "$rootCA_file_path" ]]; then
        echo "Root CA file found: $rootCA_file_path"
        sed -i "s|^${rootCAPathVariable}=.*|${rootCAPathVariable}=\"${rootCA_file_path}\"|" "$config_file"
    else
        echo "No Root CA file found in $certs_dir"
    fi

    # Client Certificate
    if [[ -n "$clientCert_file_path" ]]; then
        echo "Client certificate found: $clientCert_file_path"
        sed -i "s|^${ClientCertPathVariable}=.*|${ClientCertPathVariable}=\"${clientCert_file_path}\"|" "$config_file"
    else
        echo "No client certificate found in $certs_dir"
    fi

    # Private Key
    if [[ -n "$privateKey_file_path" ]]; then
        echo "Private key found: $privateKey_file_path"
        sed -i "s|^${PrivateKeyPathVariable}=.*|${PrivateKeyPathVariable}=\"${privateKey_file_path}\"|" "$config_file"
    else
        echo "No private key file found in $certs_dir"
    fi

    echo "Config file updated with the new file paths."


 if { [ "$MQTTEnable1" = "mqtt" ]; } || \
     { [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; }; then
        # Extract actual value from config file
        rootCAPath=$(grep "^${rootCAPathVariable}=" "$config_file" | cut -d'=' -f2 | tr -d '"')

        if [ -n "$rootCAPath" ]; then
            echo "TLS: Validation succeeded. Proceeding with next task."
        else
            if [ ! -f /tmp/updateconfigoutput.txt ]; then
                touch /tmp/updateconfigoutput.txt
            fi
            echo "TLS: Validation failed. Please upload TLS certificate." >> /tmp/updateconfigoutput.txt
            return 1
        fi
    fi
}




UpdateMQTTConfiguration2()
{
    MQTTEnable1=$(uci get cloudconfig.cloudconfig.cloudprotocol2)

    certs_dir="/root/SenderAppComponent/etc/certs2/"
    config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"
    rootCAPathVariable="rootCAPath_1"
    ClientCertPathVariable="ClientCertPath_1"
    PrivateKeyPathVariable="PrivateKeyPath_1"

    # Remove existing lines
    sed -i "/^$rootCAPathVariable=/d" "$config_file"
    sed -i "/^$ClientCertPathVariable=/d" "$config_file"
    sed -i "/^$PrivateKeyPathVariable=/d" "$config_file"

    # Append empty placeholders
    echo "$rootCAPathVariable=\"\"" >> "$config_file"
    echo "$ClientCertPathVariable=\"\"" >> "$config_file"
    echo "$PrivateKeyPathVariable=\"\"" >> "$config_file"

    # Find file paths
    rootCA_file_path_1=$(find "$certs_dir" -name "*.pem" -type f | grep -E "RootCA|CA" | head -1)
    clientCert_file_path=$(find "$certs_dir" -name "*.cert.pem" -type f | head -1)
    privateKey_file_path=$(find "$certs_dir" -name "*.private.key" -type f | head -1)

    # Root CA
    if [[ -n "$rootCA_file_path_1" ]]; then
        echo "Root CA file found: $rootCA_file_path_1"
        sed -i "s|^$rootCAPathVariable=\".*|$rootCAPathVariable=\"${rootCA_file_path_1}\"|" "$config_file"
    else
        echo "No Root CA file found in $certs_dir"
    fi

    # Client Certificate
    if [[ -n "$clientCert_file_path" ]]; then
        echo "Client certificate found: $clientCert_file_path"
        sed -i "s|^$ClientCertPathVariable=\".*|$ClientCertPathVariable=\"${clientCert_file_path}\"|" "$config_file"
    else
        echo "No client certificate found in $certs_dir"
    fi

    # Private Key
    if [[ -n "$privateKey_file_path" ]]; then
        echo "Private key found: $privateKey_file_path"
        sed -i "s|^$PrivateKeyPathVariable=\".*|$PrivateKeyPathVariable=\"${privateKey_file_path}\"|" "$config_file"
    else
        echo "No private key found in $certs_dir"
    fi

    echo "Config file updated with the new file paths."

    # TLS Validation
    echo "MQTTEnable1=$MQTTEnable1"

 if { [ "$MQTTEnable1" = "mqtt" ]; } || \
     { [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; }; then
        # Extract actual value from config
        actual_rootCA=$(grep "^$rootCAPathVariable=" "$config_file" | cut -d'=' -f2 | tr -d '"')

        if [ -n "$actual_rootCA" ]; then
            echo -e "\033[0;32mTLS: Validation succeeded. Proceeding with next task.\033[0m"
        else
            if [ ! -f /tmp/updateconfigoutput.txt ]; then
                touch /tmp/updateconfigoutput.txt
            fi
            echo -e "\033[0;31mTLS: Validation failed. Please upload TLS certificate.\033[0m"
            echo "TLS: Validation failed. Please upload TLS certificate." >> /tmp/updateconfigoutput.txt
            return 1
        fi
    fi
}

UpdateMQTTConfigurationCA()
{
	
certs_dir="/root/SenderAppComponent/etc/certs/"
config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"
rootCAPathVariable="rootCAPath"

echo "rootCAPath=""" >> "$config_file"

rootCA_file_path=$(ls /root/SenderAppComponent/etc/certs/*)
rootCA_file_path=\"$rootCA_file_path\"

if [[ -n "$rootCA_file_path" ]]; then
    echo "Root CA file found: $rootCA_file_path"
    sed -i '/rootCAPath/d' "$config_file"
    echo "rootCAPath=$rootCA_file_path" >> "$config_file"
    
else
    echo "No root CA file found with the extension .crt in $certs_dir"
    rootCA_file_path=""
    echo "rootCAPath set to empty string"
fi



}

UpdateMQTTConfigurationCA2()
{
	
certs_dir="/root/SenderAppComponent/etc/certs2/"
config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"
rootCAPathVariable="rootCAPath_1"

echo "rootCAPath_1=""" >> "$config_file"

rootCA_file_path_1=$(ls /root/SenderAppComponent/etc/certs2/*)
rootCA_file_path_1=\"$rootCA_file_path_1\"

if [[ -n "$rootCA_file_path_1" ]]; then
    echo "Root CA file 2 found: $rootCA_file_path_1"
    sed -i '/rootCAPath_1/d' "$config_file"
    echo "rootCAPath_1=$rootCA_file_path_1" >> "$config_file"
    
else
    echo "No root CA file found with the extension .crt in $certs_dir"
    rootCA_file_path_1=""
    echo "rootCAPath_1 set to empty string"
fi



}




UpdateMQTTCfg()
{
	MQTTEnable=$(uci get cloudconfig.cloudconfig.cloudprotocol)
	MQTTEnable1=$(uci get cloudconfig.cloudconfig.cloudprotocol2)
	EnableMQTTCommand=$(uci get cloudconfig.cloudconfig.EnableMQTTCommand)
	EnableMQTTCommand2=$(uci get cloudconfig.cloudconfig.EnableMQTTCommand2)
	

	    config_load "$MQTTEventfile"
	    config_get  host                  "$MQTTconfigureEventSection"    host
	    config_get  mqttport                  "$MQTTconfigureEventSection"    mqttport
	    config_get  mqttauthmode                  "$MQTTconfigureEventSection"    mqttauthmode
	    config_get  mqttusername "$MQTTconfigureEventSection" mqttusername
	    config_get  mqttpassword    "$MQTTconfigureEventSection"    mqttpassword
	    config_get  enablepublishoverlan    "$MQTTconfigureEventSection"    enablepublishoverlan
	    config_get  enable_clientID    "$MQTTconfigureEventSection"    enable_clientID
	    config_get  ClientID    "$MQTTconfigureEventSection"    ClientID
	    config_get  qos    "$MQTTconfigureEventSection"    qos
	    config_get  subqos    "$MQTTconfigureEventSection"    subqos
	    config_get  enable_subcribe_topic    "$MQTTconfigureEventSection"    enable_subcribe_topic
	    config_get  enable_loopforever    "$MQTTconfigureEventSection"    enable_loopforever

	
	    config_get  host2                  "$MQTTconfigureEventSection"    host2
	    config_get  mqttport2                  "$MQTTconfigureEventSection"    mqttport2
	    config_get  mqttauthmode2                  "$MQTTconfigureEventSection"    mqttauthmode2
	    config_get  mqttusername2 "$MQTTconfigureEventSection" mqttusername2
	    config_get  mqttpassword2    "$MQTTconfigureEventSection"    mqttpassword2
	    config_get  enablepublishoverlan2    "$MQTTconfigureEventSection"    enablepublishoverlan2
	    config_get  enable_clientID_1    "$MQTTconfigureEventSection"    enable_clientID_1
	    config_get  ClientID_1    "$MQTTconfigureEventSection"    ClientID_1
	    config_get  qos2    "$MQTTconfigureEventSection"    qos2
	    config_get  subqos2    "$MQTTconfigureEventSection"    subqos2
	    config_get  enable_subcribe_topic_1    "$MQTTconfigureEventSection"    enable_subcribe_topic_1
	    config_get  enable_loopforever_1    "$MQTTconfigureEventSection"    enable_loopforever_1
	{
		
MQTT_PASS=$(uci get cloudconfig.cloudconfig.mqttpassword 2>/dev/null)
MQTT_PASS2=$(uci get cloudconfig.cloudconfig.mqttpassword2 2>/dev/null)

	
			
if { [ "$MQTTEnable" = "mqtt" ] && [ "$MQTTEnable1" = "mqtt" ]; } || \
   { [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ] && \
     [ "$MQTTEnable2" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; } || \
   { [ "$MQTTEnable" = "mqtt" ] && \
     [ "$MQTTEnable2" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; } || \
   { [ "$MQTTEnable1" = "mqtt" ] && \
     [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ]; }
then
  
		
		echo "host=\"$host\""
        if [[ -z "$mqttport" ]]; then
	             echo "port=1883"
	        else
		        echo "port=$mqttport"
	        fi
        echo "max_inflight=20"
        echo "KeepAlive=60"
        echo "clean_session=true"
        echo "eol=true"
        echo "protocol_version=true"
        echo "sub_qos=$subqos"
        echo "pub_qos=$qos"
        echo "debug=true" 
        echo "rootCAPath=\"/root/SenderAppComponent/etc/certs/\""
        echo "ClientCertPath=\"\""   
        echo "PrivateKeyPath=\"\""
        if [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ]
        then
        echo "enable_subscribe_topic=1"
        else
		echo "enable_subscribe_topic=$enable_subcribe_topic"
		fi
        
        
        echo "enable_clientID=$enable_clientID"
        if [ "$enable_clientID" = "1" ]
        then
        echo "ClientID=\"$ClientID\""
		 fi     
        
        if [ "$mqttauthmode" = "2" ]
        then 
            echo "enable_username_password=1"
            echo "username=\"$mqttusername\""
            
		if [ -z "$MQTT_PASS" ]; then
		
			echo "password=\"1234\""
		else
			echo "password=\"$mqttpassword\""
		fi
	
        
        elif [ "$mqttauthmode" = "1" ] || [ "$mqttauthmode" = "4" ]
		then 
            echo "enable_username_password=1"
            echo "enable_tls_ca_certificate=1"
            echo "username=\"$mqttusername\""
		if [ -z "$MQTT_PASS" ]; then
		
			echo "password=\"1234\""
		else
			echo "password=\"$mqttpassword\""
		fi	
		elif [ "$mqttauthmode" = "0" ]
		then 
			echo "enable_tls_ca_certificate=1"
			echo "enable_tls_ca_certificate=1"
			
        else
            echo "enable_username_password=0"
			echo "enable_tls_ca_certificate=0"
            
        fi
        
        echo "enablepublishoverlan=$enablepublishoverlan"
        echo "enable_loopforever=$enable_loopforever"
        
        
        
        echo "host_1=\"$host2\""
        if [[ -z "$mqttport" ]]; then
	             echo "port_1=1883"
		else
			echo "port_1=$mqttport2"
		fi
        echo "max_inflight_1=20"
        echo "KeepAlive_1=60"
        echo "clean_session_1=true"
        echo "eol_1=true"
        echo "protocol_version_1=true"
        echo "sub_qos_1=$subqos2"
        echo "pub_qos_1=$qos2"
        echo "debug_1=true" 
        echo "rootCAPath_1=\"/root/SenderAppComponent/etc/certs2/\""
        echo "ClientCertPath_1=\"\""   
        echo "PrivateKeyPath_1=\"\""
		if [ "$MQTTEnable2" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]
        then
        echo "enable_subscribe_topic_1=1"
        else
        echo "enable_subscribe_topic_1=$enable_subcribe_topic_1"
		fi

        echo "enable_clientID_1=$enable_clientID_1"
        if [ "$enable_clientID_1" = "1" ]
        then
        echo "ClientID_1=\"$ClientID_1\""
		 fi                    
        
        if [ "$mqttauthmode2" = "2" ]
        then 
            echo "enable_username_password_1=1"
            echo "username_1=\"$mqttusername2\""
		if [ -z "$MQTT_PASS2" ]; then
		
			echo "password_1=\"1234\""
		else
			echo "password_1=\"$mqttpassword2\""
		fi            
            
			
        elif [ "$mqttauthmode2" = "1" ] || [ "$mqttauthmode2" = "4" ]
		then 
            echo "enable_username_password_1=1"
            echo "enable_tls_ca_certificate_1=1"
            echo "username_1=\"$mqttusername2\""
		if [ -z "$MQTT_PASS2" ]; then
		
			echo "password_1=\"1234\""
		else
			echo "password_1=\"$mqttpassword2\""
		fi      		
		elif [ "$mqttauthmode2" = "0" ]
		then 
			echo "enable_tls_ca_certificate_1=1"
        else
            echo "enable_username_password_1=0"
			echo "enable_tls_ca_certificate_1=0"
            
        fi
        
        echo "enablepublishoverlan_1=$enablepublishoverlan2"
        echo "enable_loopforever_1=$enable_loopforever_1"
        
        
        
   #elif [ "$MQTTEnable" = "mqtt" ]; then
   
   
   
   elif { [ "$MQTTEnable" = "mqtt" ]; } || \
     { [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ]; }; then


				echo "host=\"$host\""
				if [[ -z "$mqttport" ]]; then
						 echo "port=1883"
					else
						echo "port=$mqttport"
					fi
				echo "max_inflight=20"
				echo "KeepAlive=60"
				echo "clean_session=true"
				echo "eol=true"
				echo "protocol_version=true"
				echo "sub_qos=$subqos"
				echo "pub_qos=$qos"
				echo "debug=true" 
				echo "rootCAPath=\"/root/SenderAppComponent/etc/certs/\""
				echo "ClientCertPath=\"\""   
				echo "PrivateKeyPath=\"\""
				if [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ]
				then
				echo "enable_subscribe_topic=1"
				else
				echo "enable_subscribe_topic=$enable_subcribe_topic"
				fi
        				echo "enable_clientID=$enable_clientID"
				if [ "$enable_clientID" = "1" ]
				then
				echo "ClientID=\"$ClientID\""
				 fi  						  
				
				if [ "$mqttauthmode" = "2" ]
				then 
					echo "enable_username_password=1"
					echo "username=\"$mqttusername\""
				if [ -z "$MQTT_PASS" ]; then
				
					echo "password=\"1234\""
				else
					echo "password=\"$mqttpassword\""
				fi	
						elif [ "$mqttauthmode" = "1" ] || [ "$mqttauthmode" = "4" ]
				then 
					echo "enable_username_password=1"
					echo "enable_tls_ca_certificate=1"
					echo "username=\"$mqttusername\""
					if [ -z "$MQTT_PASS" ]; then
					
						echo "password=\"1234\""
					else
						echo "password=\"$mqttpassword\""
					fi	

				elif [ "$mqttauthmode" = "0" ]
				then 
					echo "enable_tls_ca_certificate=1"
				else
					echo "enable_username_password=0"
					echo "enable_tls_ca_certificate=0"
					
				fi
				echo "enable_loopforever=$enable_loopforever"
				echo "enablepublishoverlan=$enablepublishoverlan"
				   echo "host_1=\"XXXXXXX1\""   
					echo "port_1=1883"   
					 echo "max_inflight_1=20"
					echo "KeepAlive_1=60"
					echo "clean_session_1=true"
					echo "eol_1=true"
					echo "protocol_version_1=true"
					echo "sub_qos_1=1"
					echo "pub_qos_1=2"
					echo "debug_1=true" 
					echo "rootCAPath_1=\"\""   
					echo "ClientCertPath_1=\"\""   
					echo "PrivateKeyPath_1=\"\""   
					echo "enable_username_password_1=0"  
					echo "enable_tls_ca_certificate_1=0"            		  					 
					echo "enablepublishoverlan_1=\"\""  
					echo "enable_subscribe_topic_1=0" 
					echo "enable_loopforever_1=0"

				
		
				
 #elif [ "$MQTTEnable1" = "mqtt" ]; then
 
 elif { [ "$MQTTEnable1" = "mqtt" ]; } || \
     { [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; }; then




        echo "host_1=\"$host2\""
        if [[ -z "$mqttport" ]]; then
	             echo "port_1=1883"
	        else
		        echo "port_1=$mqttport2"
	        fi
        echo "max_inflight_1=20"
        echo "KeepAlive_1=60"
        echo "clean_session_1=true"
        echo "eol_1=true"
        echo "protocol_version_1=true"
        echo "sub_qos_1=$subqos2"
        echo "pub_qos_1=$qos2"
        echo "debug_1=true" 
        echo "rootCAPath_1=\"/root/SenderAppComponent/etc/certs2/\""
        echo "ClientCertPath_1=\"\""   
        echo "PrivateKeyPath_1=\"\""
		if [ "$MQTTEnable2" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]
        then
        echo "enable_subscribe_topic_1=1"
        else
        echo "enable_subscribe_topic_1=$enable_subcribe_topic_1"
		fi
		echo "enable_clientID_1=$enable_clientID_1"
        if [ "$enable_clientID_1" = "1" ]
        then
        echo "ClientID_1=\"$ClientID_1\""
		 fi                    
        
        if [ "$mqttauthmode2" = "2" ]
        then 
            echo "enable_username_password_1=1"
            echo "username_1=\"$mqttusername2\""
		if [ -z "$MQTT_PASS2" ]; then
		
			echo "password_1=\"1234\""
		else
			echo "password_1=\"$mqttpassword2\""
		fi                  
        elif [ "$mqttauthmode2" = "1" ] || [ "$mqttauthmode2" = "4" ]
		then 
            echo "enable_username_password_1=1"
            echo "enable_tls_ca_certificate_1=1"
            echo "username_1=\"$mqttusername2\""
		if [ -z "$MQTT_PASS2" ]; then
		
			echo "password_1=\"1234\""
		else
			echo "password_1=\"$mqttpassword2\""
		fi      		
		elif [ "$mqttauthmode2" = "0" ]
		then 
			echo "enable_tls_ca_certificate_1=1"            
        else
            echo "enable_username_password_1=0"
			echo "enable_tls_ca_certificate_1=0"            
        fi
        echo "enable_loopforever_1=$enable_loopforever_1"

        echo "enablepublishoverlan_1=$enablepublishoverlan2"
        
        
        echo "host=\"XXXXXXX2\""   
		echo "port=1883"   
        echo "max_inflight=20"
        echo "KeepAlive=60"
        echo "clean_session=true"
        echo "eol=true"
        echo "protocol_version=true"
        echo "sub_qos=1"
        echo "pub_qos=2"
        echo "debug=true"  
		echo "ClientCertPath=\"\""   
		echo "PrivateKeyPath=\"\""   
		echo "enable_username_password=0" 
		echo "enable_tls_ca_certificate=0"            		  		  
		echo "enablepublishoverlan=\"\""   
		echo "enable_subscribe_topic=0" 
		echo "enable_loopforever=0"



       else
        echo "host=\"XXXXXXX2\""   
		echo "port=1883"   
        echo "max_inflight=20"
        echo "KeepAlive=60"
        echo "clean_session=true"
        echo "eol=true"
        echo "protocol_version=true"
        echo "sub_qos=1"
        echo "pub_qos=2"
        echo "debug=true"  
		echo "ClientCertPath=\"\""   
		echo "PrivateKeyPath=\"\""   
		echo "enable_username_password=0" 
		echo "enable_tls_ca_certificate=0"            		  
		echo "enablepublishoverlan=\"\"" 
		echo "enable_subscribe_topic=0" 
		echo "enable_loopforever=0"


		echo "host_1=\"XXXXXXX1\""   
		echo "port_1=1883"   
		echo "max_inflight_1=20"
		echo "KeepAlive_1=60"
		echo "clean_session_1=true"
		echo "eol_1=true"
		echo "protocol_version_1=true"
		echo "sub_qos_1=1"
		echo "pub_qos_1=2"
		echo "debug_1=true" 
		echo "rootCAPath_1=\"\""   
		echo "ClientCertPath_1=\"\""   
		echo "PrivateKeyPath_1=\"\""   
		echo "enable_username_password_1=0"
		echo "enable_tls_ca_certificate_1=0"            
		echo "enablepublishoverlan_1=\"\"" 
		echo "enable_subscribe_topic_1=0" 
		echo "enable_loopforever_1=0"





		fi    
           
     } > "${MQTTconfigureCfgPath}.cfg"	
     
      
        if [ "$mqttauthmode" = "0" ] 
        then
        
             UpdateMQTTConfiguration
                 
        elif [ "$mqttauthmode" = "1" ]
        then     
             
             #UpdateMQTTConfiguration
             UpdateMQTTConfigurationCA        
        elif [ "$mqttauthmode" = "4" ]
        then     
             
            UpdateMQTTConfiguration
            #UpdateMQTTConfigurationCA        
        fi 
        
        if [ "$mqttauthmode2" = "0" ] 
        then
        
             UpdateMQTTConfiguration2
                 
        elif [ "$mqttauthmode2" = "1" ]
        then     
             
             #UpdateMQTTConfiguration2
             UpdateMQTTConfigurationCA2        
        elif [ "$mqttauthmode2" = "4" ]
        then     
             
             UpdateMQTTConfiguration2
             #UpdateMQTTConfigurationCA2        
        fi 
        
        sed -i 's/HTTP/MQTT/g' "$MQTTInternalTopics"      
  
}





UpdateExternalMQTTTopicCfg()
{
	MQTTEnable=$(uci get cloudconfig.cloudconfig.cloudprotocol)
	MQTTEnable1=$(uci get cloudconfig.cloudconfig.cloudprotocol2)
	#SiteID=$(uci get FixedPacketConfigGeneric.fixedpacketconfig.SiteID)
	config_load "$FixedPacketconfigureFile"
	config_get SiteID     "$FixedPacketconfigureEventSection"   SiteID 
	SerialNumber=$(uci get boardconfig.board.serialnum)
	EnablePrefixtopic=$(uci get cloudconfig.cloudconfig.EnablePrefixtopic)
	topicPrefix=$(uci get cloudconfig.cloudconfig.topicPrefix)
	EnableServer=$(uci get cloudconfig.cloudconfig.server)
	
if [ "$EnableServer" = "primary" ]
then

	uci set cloudconfig.cloudconfig.cloudprotocol2=http
	uci commit cloudconfig
	MQTTEnable1=$(uci get cloudconfig.cloudconfig.cloudprotocol2)
	echo "$MQTTEnable1=MQTTEnable1"
fi

	echo "$SiteID=SiteID"
	
	
	    
	
	    config_load "$MQTTEventfile"
	     config_get  RS485Enable        "$MQTTconfigureEventSection"  RS485Enable
	    config_get  rs485topic         "$MQTTconfigureEventSection"   rs485topic 	    
	    config_get  rs232topic         "$MQTTconfigureEventSection"   rs232topic  
	    config_get  diotopic           "$MQTTconfigureEventSection"   diotopic 
	    config_get  aiotopic           "$MQTTconfigureEventSection"   aiotopic 
	    config_get  temperaturetopic   "$MQTTconfigureEventSection"   temperaturetopic 
	    config_get  snmptopic   		"$MQTTconfigureEventSection"   snmptopic 
	    config_get  customtopic   		"$MQTTconfigureEventSection"   customtopic 
	    config_get  commandrequesttopic   "$MQTTconfigureEventSection"   commandrequesttopic 
	    config_get  commandresponsetopic   "$MQTTconfigureEventSection"   commandresponsetopic 
	    
	    
	     config_get  RS485Enable2        "$MQTTconfigureEventSection"  RS485Enable2
	    config_get  rs485topic2         "$MQTTconfigureEventSection"   rs485topic2 	    
	    config_get  rs232topic2         "$MQTTconfigureEventSection"   rs232topic2  
	    config_get  diotopic2           "$MQTTconfigureEventSection"   diotopic2 
	    config_get  aiotopic2           "$MQTTconfigureEventSection"   aiotopic2 
	    config_get  temperaturetopic2   "$MQTTconfigureEventSection"   temperaturetopic2 
	    config_get  snmptopic2   		"$MQTTconfigureEventSection"   snmptopic2 
	    config_get  customtopic2   		"$MQTTconfigureEventSection"   customtopic2 	    
	    config_get  commandrequesttopic2   "$MQTTconfigureEventSection"   commandrequesttopic2 
	    config_get  commandresponsetopic2   "$MQTTconfigureEventSection"   commandresponsetopic2 
	    
	    
	    
	    { 
			
			
			
			
if { [ "$MQTTEnable" = "mqtt" ] && [ "$MQTTEnable1" = "mqtt" ]; } || \
   { [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ] && \
     [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; } || \
   { [ "$MQTTEnable" = "mqtt" ] && \
     [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; } || \
   { [ "$MQTTEnable1" = "mqtt" ] && \
     [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ]; }
then
  

	 		
					if [ "$EnablePrefixtopic" = "1" ]
					then
					
							if [[ -z "$rs485topic" ]]; then
								 #echo "rs485 is blank"
								 echo "externalBrokerPubTopic_0=\"$topicPrefix/$SerialNumber/RS485Data\""
							else
								#echo "rs485 is not blank"
								echo "externalBrokerPubTopic_0=\"$rs485topic\""
							fi	
							if [[ -z "$rs232topic" ]]; then
								 #echo "rs232 is blank"
								 echo "externalBrokerPubTopic_2=\"$topicPrefix/$SerialNumber/RS232Data\""
							else
								echo "externalBrokerPubTopic_2=\"$rs232topic\""
							fi	        
							if [[ -z "$diotopic" ]]; then
								 #echo "diotopic is blank"
								 echo "externalBrokerPubTopic_1=\"$topicPrefix/$SerialNumber/DIOData\""
							else
								echo "externalBrokerPubTopic_1=\"$diotopic\""
							fi	     
							
							 if [[ -z "$aiotopic" ]]; then
								 #echo "aiodata is blank"
								 echo "externalBrokerPubTopic_4=\"$topicPrefix/$SerialNumber/AIOData\""
							else
								echo "externalBrokerPubTopic_4=\"$aiotopic\""
							fi	    
							if [[ -z "$temperaturetopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_3=\"$topicPrefix/$SerialNumber/TemperatureData\""
							else
								echo "externalBrokerPubTopic_3=\"$temperaturetopic\""
							fi	
							
							if [[ -z "$snmptopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_6=\"$topicPrefix/$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic_6=\"$snmptopic\""
							fi	
							if [[ -z "$customtopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_7=\"$topicPrefix/$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic_7=\"$customtopic\""
							fi	
							
							 if [[ -z "$commandrequesttopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerSubTopic_0=\"$topicPrefix/$SerialNumber/IOcommandRequest\""
							else
								echo "externalBrokerSubTopic_0=\"$commandrequesttopic\""
							fi	
							
							 if [[ -z "$commandresponsetopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_5=\"$topicPrefix/$SerialNumber/IOcommandResponse\""
							else
								echo "externalBrokerPubTopic_5=\"$commandresponsetopic\""
							fi
					else
							if [[ -z "$rs485topic" ]]; then
								 #echo "rs485 is blank"
								 echo "externalBrokerPubTopic_0=\"$SerialNumber/RS485Data\""
							else
								#echo "rs485 is not blank"
								echo "externalBrokerPubTopic_0=\"$rs485topic\""
							fi	
							if [[ -z "$rs232topic" ]]; then
								 #echo "rs232 is blank"
								 echo "externalBrokerPubTopic_2=\"$SerialNumber/RS232Data\""
							else
								echo "externalBrokerPubTopic_2=\"$rs232topic\""
							fi	        
							if [[ -z "$diotopic" ]]; then
								 #echo "diotopic is blank"
								 echo "externalBrokerPubTopic_1=\"$SerialNumber/DIOData\""
							else
								echo "externalBrokerPubTopic_1=\"$diotopic\""
							fi	     
							
							 if [[ -z "$aiotopic" ]]; then
								 #echo "aiodata is blank"
								 echo "externalBrokerPubTopic_4=\"$SerialNumber/AIOData\""
							else
								echo "externalBrokerPubTopic_4=\"$aiotopic\""
							fi	  
							
							if [[ -z "$snmptopic" ]]; then
								 echo "externalBrokerPubTopic_6=\"$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic_6=\"$snmptopic\""
							fi	
							if [[ -z "$customtopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_7=\"$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic_7=\"$customtopic\""
							fi		
							  
							if [[ -z "$temperaturetopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_3=\"$SerialNumber/TemperatureData\""
							else
								echo "externalBrokerPubTopic_3=\"$temperaturetopic\""
							fi	
							
							 if [[ -z "$commandrequesttopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerSubTopic_0=\"$SerialNumber/IOcommandRequest\""
							else
								echo "externalBrokerSubTopic_0=\"$commandrequesttopic\""
							fi	
							
							 if [[ -z "$commandresponsetopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_5=\"$SerialNumber/IOcommandResponse\""
							else
								echo "externalBrokerPubTopic_5=\"$commandresponsetopic\""
							fi        
							
					fi
	        
	        echo "NoOfSubscribeTopics=1"	        	  
	        echo "NoOfPublishTopics=8"	
	        
	       
			if [ "$EnablePrefixtopic" = "1" ]
			then
				
						if [[ -z "$rs485topic2" ]]; then
							 #echo "rs485 is blank"
							 echo "externalBrokerPubTopic2_0=\"$topicPrefix/$SerialNumber/RS485Data\""
						else
							#echo "rs485 is not blank"
							echo "externalBrokerPubTopic2_0=\"$rs485topic2\""
						fi	
						if [[ -z "$rs232topic2" ]]; then
							 #echo "rs232 is blank"
							 echo "externalBrokerPubTopic2_2=\"$topicPrefix/$SerialNumber/RS232Data\""
						else
							echo "externalBrokerPubTopic2_2=\"$rs232topic2\""
						fi	        
						if [[ -z "$diotopic2" ]]; then
							 #echo "diotopic is blank"
							 echo "externalBrokerPubTopic2_1=\"$topicPrefix/$SerialNumber/DIOData\""
						else
							echo "externalBrokerPubTopic2_1=\"$diotopic2\""
						fi	     
						
						 if [[ -z "$aiotopic2" ]]; then
							 #echo "aiodata is blank"
							 echo "externalBrokerPubTopic2_4=\"$topicPrefix/$SerialNumber/AIOData\""
						else
							echo "externalBrokerPubTopic2_4=\"$aiotopic2\""
						fi	    
						if [[ -z "$temperaturetopic2" ]]; then
							 #echo "temperaturetopic is blank"
							 echo "externalBrokerPubTopic2_3=\"$topicPrefix/$SerialNumber/TemperatureData\""
						else
							echo "externalBrokerPubTopic2_3=\"$temperaturetopic2\""
						fi	
							if [[ -z "$snmptopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_6=\"$topicPrefix/$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic2_6=\"$snmptopic2\""
							fi	
							if [[ -z "$customtopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_7=\"$topicPrefix/$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic2_7=\"$customtopic2\""
							fi							
						
						 if [[ -z "$commandrequesttopic2" ]]; then
							 #echo "temperaturetopic is blank"
							 echo "externalBrokerSubTopic2_0=\"$topicPrefix/$SerialNumber/IOcommandRequest\""
						else
							echo "externalBrokerSubTopic2_0=\"$commandrequesttopic2\""
						fi	
						
						 if [[ -z "$commandresponsetopic2" ]]; then
							 #echo "temperaturetopic is blank"
							 echo "externalBrokerPubTopic2_5=\"$topicPrefix/$SerialNumber/IOcommandResponse\""
						else
							echo "externalBrokerPubTopic2_5=\"$commandresponsetopic2\""
						fi
				else
						if [[ -z "$rs485topic2" ]]; then
							 #echo "rs485 is blank"
							 echo "externalBrokerPubTopic2_0=\"$SerialNumber/RS485Data\""
						else
							#echo "rs485 is not blank"
							echo "externalBrokerPubTopic2_0=\"$rs485topic2\""
						fi	
						if [[ -z "$rs232topic2" ]]; then
							 #echo "rs232 is blank"
							 echo "externalBrokerPubTopic2_2=\"$SerialNumber/RS232Data\""
						else
							echo "externalBrokerPubTopic2_2=\"$rs232topic2\""
						fi	        
						if [[ -z "$diotopic2" ]]; then
							 #echo "diotopic is blank"
							 echo "externalBrokerPubTopic2_1=\"$SerialNumber/DIOData\""
						else
							echo "externalBrokerPubTopic2_1=\"$diotopic2\""
						fi	     
						
						 if [[ -z "$aiotopic2" ]]; then
							 #echo "aiodata is blank"
							 echo "externalBrokerPubTopic2_4=\"$SerialNumber/AIOData\""
						else
							echo "externalBrokerPubTopic2_4=\"$aiotopic2\""
						fi	    
						if [[ -z "$temperaturetopic2" ]]; then
							 #echo "temperaturetopic is blank"
							 echo "externalBrokerPubTopic2_3=\"$SerialNumber/TemperatureData\""
						else
							echo "externalBrokerPubTopic2_3=\"$temperaturetopic2\""
						fi	
							if [[ -z "$snmptopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_6=\"$$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic2_6=\"$snmptopic2\""
							fi	
							if [[ -z "$customtopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_7=\"$$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic2_7=\"$customtopic2\""
							fi							
						
						 if [[ -z "$commandrequesttopic2" ]]; then
							 #echo "temperaturetopic is blank"
							 echo "externalBrokerSubTopic2_0=\"$SerialNumber/IOcommandRequest\""
						else
							echo "externalBrokerSubTopic2_0=\"$commandrequesttopic2\""
						fi	
						
						 if [[ -z "$commandresponsetopic2" ]]; then
							 #echo "temperaturetopic is blank"
							 echo "externalBrokerPubTopic2_5=\"$SerialNumber/IOcommandResponse\""
						else
							echo "externalBrokerPubTopic2_5=\"$commandresponsetopic2\""
						fi        
						
				fi
				
				echo "NoOfSubscribeTopics_1=1"	        	  
				echo "NoOfPublishTopics_1=8"	

			
  
   elif { [ "$MQTTEnable" = "http" ] && [ "$EnableMQTTCommand" = "1" ]; } || \
		{ [ "$MQTTEnable" = "mqtt" ]; }; then
	

					if [ "$EnablePrefixtopic" = "1" ]
					then
						
								if [[ -z "$rs485topic" ]]; then
									 #echo "rs485 is blank"
									 echo "externalBrokerPubTopic_0=\"$topicPrefix/$SerialNumber/RS485Data\""
								else
									#echo "rs485 is not blank"
									echo "externalBrokerPubTopic_0=\"$rs485topic\""
								fi	
								if [[ -z "$rs232topic" ]]; then
									 #echo "rs232 is blank"
									 echo "externalBrokerPubTopic_2=\"$topicPrefix/$SerialNumber/RS232Data\""
								else
									echo "externalBrokerPubTopic_2=\"$rs232topic\""
								fi	        
								if [[ -z "$diotopic" ]]; then
									 #echo "diotopic is blank"
									 echo "externalBrokerPubTopic_1=\"$topicPrefix/$SerialNumber/DIOData\""
								else
									echo "externalBrokerPubTopic_1=\"$diotopic\""
								fi	     
								
								 if [[ -z "$aiotopic" ]]; then
									 #echo "aiodata is blank"
									 echo "externalBrokerPubTopic_4=\"$topicPrefix/$SerialNumber/AIOData\""
								else
									echo "externalBrokerPubTopic_4=\"$aiotopic\""
								fi	    
							if [[ -z "$snmptopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_6=\"$topicPrefix/$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic_6=\"$snmptopic\""
							fi	
							if [[ -z "$customtopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_7=\"$topicPrefix/$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic_7=\"$customtopic\""
							fi									
								if [[ -z "$temperaturetopic" ]]; then
									 #echo "temperaturetopic is blank"
									 echo "externalBrokerPubTopic_3=\"$topicPrefix/$SerialNumber/TemperatureData\""
								else
									echo "externalBrokerPubTopic_3=\"$temperaturetopic\""
								fi	
								
								 if [[ -z "$commandrequesttopic" ]]; then
									 #echo "temperaturetopic is blank"
									 echo "externalBrokerSubTopic_0=\"$topicPrefix/$SerialNumber/IOcommandRequest\""
								else
									echo "externalBrokerSubTopic_0=\"$commandrequesttopic\""
								fi	
								
								 if [[ -z "$commandresponsetopic" ]]; then
									 #echo "temperaturetopic is blank"
									 echo "externalBrokerPubTopic_5=\"$topicPrefix/$SerialNumber/IOcommandResponse\""
								else
									echo "externalBrokerPubTopic_5=\"$commandresponsetopic\""
								fi
						else
								if [[ -z "$rs485topic" ]]; then
									 #echo "rs485 is blank"
									 echo "externalBrokerPubTopic_0=\"$SerialNumber/RS485Data\""
								else
									#echo "rs485 is not blank"
									echo "externalBrokerPubTopic_0=\"$rs485topic\""
								fi	
								if [[ -z "$rs232topic" ]]; then
									 #echo "rs232 is blank"
									 echo "externalBrokerPubTopic_2=\"$SerialNumber/RS232Data\""
								else
									echo "externalBrokerPubTopic_2=\"$rs232topic\""
								fi	        
								if [[ -z "$diotopic" ]]; then
									 #echo "diotopic is blank"
									 echo "externalBrokerPubTopic_1=\"$SerialNumber/DIOData\""
								else
									echo "externalBrokerPubTopic_1=\"$diotopic\""
								fi	     
								
								 if [[ -z "$aiotopic" ]]; then
									 #echo "aiodata is blank"
									 echo "externalBrokerPubTopic_4=\"$SerialNumber/AIOData\""
								else
									echo "externalBrokerPubTopic_4=\"$aiotopic\""
								fi	    
								if [[ -z "$temperaturetopic" ]]; then
									 #echo "temperaturetopic is blank"
									 echo "externalBrokerPubTopic_3=\"$SerialNumber/TemperatureData\""
								else
									echo "externalBrokerPubTopic_3=\"$temperaturetopic\""
								fi	
							if [[ -z "$snmptopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_6=\"$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic_6=\"$snmptopic\""
							fi	
							if [[ -z "$customtopic" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic_7=\"$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic_7=\"$customtopic\""
							fi									
								 if [[ -z "$commandrequesttopic" ]]; then
									 #echo "temperaturetopic is blank"
									 echo "externalBrokerSubTopic_0=\"$SerialNumber/IOcommandRequest\""
								else
									echo "externalBrokerSubTopic_0=\"$commandrequesttopic\""
								fi	
								
								 if [[ -z "$commandresponsetopic" ]]; then
									 #echo "temperaturetopic is blank"
									 echo "externalBrokerPubTopic_5=\"$SerialNumber/IOcommandResponse\""
								else
									echo "externalBrokerPubTopic_5=\"$commandresponsetopic\""
								fi        
								
						fi
						
						echo "NoOfSubscribeTopics=1"	        	  
						echo "NoOfPublishTopics=8"
						
						 echo "externalBrokerPubTopic2_0=\"XXXXXX1\""        
						 echo "externalBrokerPubTopic2_2=\"XXXXXX2\""        
						 echo "externalBrokerPubTopic2_1=\"XXXXXX3\""        
						 echo "externalBrokerPubTopic2_4=\"XXXXXX4\""        
						 echo "externalBrokerPubTopic2_3=\"XXXXXX5\""        
						 echo "externalBrokerSubTopic2_0=\"XXXXXX6\""        
						 echo "externalBrokerPubTopic2_5=\"XXXXXX7\""        
						 echo "externalBrokerPubTopic2_6=\"XXXXXX8\""        
						 echo "externalBrokerPubTopic2_7=\"XXXXXX9\""        
						 echo "NoOfSubscribeTopics_1=1"        
						 echo "NoOfPublishTopics_1=8" 	
						

 elif { [ "$MQTTEnable1" = "mqtt" ]; } || \
     { [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; }; then

   
					if [ "$EnablePrefixtopic" = "1" ]
					then
					
							if [[ -z "$rs485topic2" ]]; then
								 #echo "rs485 is blank"
								 echo "externalBrokerPubTopic2_0=\"$topicPrefix/$SerialNumber/RS485Data\""
							else
								#echo "rs485 is not blank"
								echo "externalBrokerPubTopic2_0=\"$rs485topic2\""
							fi	
							if [[ -z "$rs232topic2" ]]; then
								 #echo "rs232 is blank"
								 echo "externalBrokerPubTopic2_2=\"$topicPrefix/$SerialNumber/RS232Data\""
							else
								echo "externalBrokerPubTopic2_2=\"$rs232topic2\""
							fi	        
							if [[ -z "$diotopic2" ]]; then
								 #echo "diotopic is blank"
								 echo "externalBrokerPubTopic2_1=\"$topicPrefix/$SerialNumber/DIOData\""
							else
								echo "externalBrokerPubTopic2_1=\"$diotopic2\""
							fi	     
							
							 if [[ -z "$aiotopic2" ]]; then
								 #echo "aiodata is blank"
								 echo "externalBrokerPubTopic2_4=\"$topicPrefix/$SerialNumber/AIOData\""
							else
								echo "externalBrokerPubTopic2_4=\"$aiotopic2\""
							fi	    
							if [[ -z "$temperaturetopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_3=\"$topicPrefix/$SerialNumber/TemperatureData\""
							else
								echo "externalBrokerPubTopic2_3=\"$temperaturetopic2\""
							fi	
							if [[ -z "$snmptopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_6=\"$topicPrefix/$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic2_6=\"$snmptopic2\""
							fi	
							if [[ -z "$customtopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_7=\"$topicPrefix/$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic2_7=\"$customtopic2\""
							fi								
							 if [[ -z "$commandrequesttopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerSubTopic2_0=\"$topicPrefix/$SerialNumber/IOcommandRequest\""
							else
								echo "externalBrokerSubTopic2_0=\"$commandrequesttopic2\""
							fi	
							
							 if [[ -z "$commandresponsetopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_5=\"$topicPrefix/$SerialNumber/IOcommandResponse\""
							else
								echo "externalBrokerPubTopic2_5=\"$commandresponsetopic2\""
							fi
					else
							if [[ -z "$rs485topic2" ]]; then
								 #echo "rs485 is blank"
								 echo "externalBrokerPubTopic2_0=\"$SerialNumber/RS485Data\""
							else
								#echo "rs485 is not blank"
								echo "externalBrokerPubTopic2_0=\"$rs485topic2\""
							fi	
							if [[ -z "$rs232topic2" ]]; then
								 #echo "rs232 is blank"
								 echo "externalBrokerPubTopic2_2=\"$SerialNumber/RS232Data\""
							else
								echo "externalBrokerPubTopic2_2=\"$rs232topic2\""
							fi	        
							if [[ -z "$diotopic2" ]]; then
								 #echo "diotopic is blank"
								 echo "externalBrokerPubTopic2_1=\"$SerialNumber/DIOData\""
							else
								echo "externalBrokerPubTopic2_1=\"$diotopic2\""
							fi	     
							
							 if [[ -z "$aiotopic2" ]]; then
								 #echo "aiodata is blank"
								 echo "externalBrokerPubTopic2_4=\"$SerialNumber/AIOData\""
							else
								echo "externalBrokerPubTopic2_4=\"$aiotopic2\""
							fi	 
							if [[ -z "$snmptopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_6=\"$SerialNumber/SNMPData\""
							else
								echo "externalBrokerPubTopic2_6=\"$snmptopic2\""
							fi	
							if [[ -z "$customtopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_7=\"$SerialNumber/CustomData\""
							else
								echo "externalBrokerPubTopic2_7=\"$customtopic2\""
							fi								   
							if [[ -z "$temperaturetopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_3=\"$SerialNumber/TemperatureData\""
							else
								echo "externalBrokerPubTopic2_3=\"$temperaturetopic2\""
							fi	
							
							 if [[ -z "$commandrequesttopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerSubTopic2_0=\"$SerialNumber/IOcommandRequest\""
							else
								echo "externalBrokerSubTopic2_0=\"$commandrequesttopic2\""
							fi	
							
							 if [[ -z "$commandresponsetopic2" ]]; then
								 #echo "temperaturetopic is blank"
								 echo "externalBrokerPubTopic2_5=\"$SerialNumber/IOcommandResponse\""
							else
								echo "externalBrokerPubTopic2_5=\"$commandresponsetopic2\""
							fi        
							
					fi
					
					echo "NoOfSubscribeTopics_1=1"	        	  
					echo "NoOfPublishTopics_1=8"	
					
					
					     echo "externalBrokerPubTopic_0=\"XXXXXX1\""        
						 echo "externalBrokerPubTopic_2=\"XXXXXX2\""        
						 echo "externalBrokerPubTopic_1=\"XXXXXX3\""        
						 echo "externalBrokerPubTopic_4=\"XXXXXX4\""        
						 echo "externalBrokerPubTopic_3=\"XXXXXX5\""        
						 echo "externalBrokerSubTopic_0=\"XXXXXX6\""        
						 echo "externalBrokerPubTopic_5=\"XXXXXX7\""        
						 echo "externalBrokerPubTopic_6=\"XXXXXX8\""        
						 echo "externalBrokerPubTopic_7=\"XXXXXX9\""        
						 echo "NoOfSubscribeTopics=1"        
						 echo "NoOfPublishTopics=8" 
					
					
					
					
		else
						 echo "externalBrokerPubTopic2_0=\"XXXXXX1\""        
						 echo "externalBrokerPubTopic2_2=\"XXXXXX2\""        
						 echo "externalBrokerPubTopic2_1=\"XXXXXX3\""        
						 echo "externalBrokerPubTopic2_4=\"XXXXXX4\""        
						 echo "externalBrokerPubTopic2_3=\"XXXXXX5\""        
						 echo "externalBrokerSubTopic2_0=\"XXXXXX6\""        
						 echo "externalBrokerPubTopic2_5=\"XXXXXX7\""        
						 echo "externalBrokerPubTopic2_6=\"XXXXXX8\""        
						 echo "externalBrokerPubTopic2_7=\"XXXXXX9\""        
						 echo "NoOfSubscribeTopics_1=1"        
						 echo "NoOfPublishTopics_1=8" 
						 	
					     echo "externalBrokerPubTopic_0=\"XXXXXX1\""        
						 echo "externalBrokerPubTopic_2=\"XXXXXX2\""        
						 echo "externalBrokerPubTopic_1=\"XXXXXX3\""        
						 echo "externalBrokerPubTopic_4=\"XXXXXX4\""        
						 echo "externalBrokerPubTopic_3=\"XXXXXX5\""        
						 echo "externalBrokerSubTopic_0=\"XXXXXX6\""        
						 echo "externalBrokerPubTopic_5=\"XXXXXX7\""        
						 echo "externalBrokerPubTopic_6=\"XXXXXX8\""        
						 echo "externalBrokerPubTopic_7=\"XXXXXX9\""        
						 echo "NoOfSubscribeTopics=1"        
						 echo "NoOfPublishTopics=8" 						 

		fi    
	        
	           	  
	        } > "${MQTTExternalPath}.cfg"
	
}      

	    sed -i '/EnableMQTTCommand/d' /root/SenderAppComponent/etc/Config/SenderGeneric.cfg
	    echo "EnableMQTTCommand=$EnableMQTTCommand" >> "/root/SenderAppComponent/etc/Config/SenderGeneric.cfg"

	    sed -i '/EnableMQTTCommand2/d' /root/SenderAppComponent/etc/Config/SenderGeneric.cfg
	    echo "EnableMQTTCommand2=$EnableMQTTCommand2" >> "/root/SenderAppComponent/etc/Config/SenderGeneric.cfg"


UpdateExternalMQTTTopicCfg
UpdateMQTTCfg

