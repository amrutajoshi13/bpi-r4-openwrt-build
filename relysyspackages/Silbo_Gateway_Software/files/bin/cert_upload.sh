#!/bin/sh
. /lib/functions.sh

# === Load Configuration Files ===
. /root/SenderAppComponent/etc/Config/SenderGeneric.cfg
. /root/SenderAppComponent/etc/Config/HTTPSenderMosquittoClient.cfg
. /root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg
# === Debugging Info ===

echo "EnableMQTTCommand=$EnableMQTTCommand"
echo "EnableMQTTCommand2=$EnableMQTTCommand2"

echo "FirstServerdataMode=$FirstServerdataMode"
echo "SecondServerDataMode=$SecondServerDataMode"

echo "mqttauthmode=$mqttauthmode"
mqttauthmode2="$mqttauthmode_1"
echo "mqttauthmode2=$mqttauthmode_1"


# === Determine Protocol for First Server ===
if [ "$FirstServerdataMode" = "1" ]; then
    MQTTEnable1="http"
elif [ "$FirstServerdataMode" = "3" ]; then
    MQTTEnable1="mqtt"
else
    MQTTEnable1="ftp"
fi

# === Determine Protocol for Second Server ===
if [ "$SecondServerDataMode" = "1" ]; then
    MQTTEnable2="http"
elif [ "$SecondServerDataMode" = "3" ]; then
    MQTTEnable2="mqtt"
else
    MQTTEnable2="ftp"
fi

echo "First Server: Mode=$FirstServerdataMode → Protocol=$MQTTEnable1"
echo "Second Server: Mode=$SecondServerDataMode → Protocol=$MQTTEnable2"


###############################################################
# Function: UpdateMQTTConfiguration (First Broker)
###############################################################
UpdateMQTTConfiguration()
{
    certs_dir="/root/SenderAppComponent/etc/certs"
    config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"
    rootCAPathVariable="rootCAPath"
    ClientCertPathVariable="ClientCertPath"
    PrivateKeyPathVariable="PrivateKeyPath"

    echo "=== Starting UpdateMQTTConfiguration ==="
    echo "Certificates directory: $certs_dir"

    # === Step 1: Handle ZIP Extraction ===
    zip_file=$(find "$certs_dir" -maxdepth 1 -type f -name "*.zip" | head -1)
    if [ -n "$zip_file" ]; then
        echo "ZIP file found: $zip_file"
        echo "Extracting to $certs_dir ..."
        unzip -o "$zip_file" -d "$certs_dir" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Extraction successful."
            rm -f "$zip_file"
            echo "Deleted ZIP after extraction."
        else
            echo "Error extracting ZIP file: $zip_file"
            return 1
        fi
    else
        echo "No ZIP file found — proceeding with existing files."
    fi

    # === Step 2: Remove Old Entries ===
    sed -i "/^$rootCAPathVariable=/d" "$config_file"
    sed -i "/^$ClientCertPathVariable=/d" "$config_file"
    sed -i "/^$PrivateKeyPathVariable=/d" "$config_file"

    # === Step 3: Add Placeholders ===
    {
        echo "$rootCAPathVariable=\"\""
        echo "$ClientCertPathVariable=\"\""
        echo "$PrivateKeyPathVariable=\"\""
    } >> "$config_file"

    # === Step 4: Locate Certificate Files ===
    rootCA_file=$(find "$certs_dir" -type f -name "*.pem" | grep -E "RootCA|CA" | head -1)
    clientCert_file=$(find "$certs_dir" -type f -name "*.cert.pem" | head -1)
    privateKey_file=$(find "$certs_dir" -type f -name "*.private.key" | head -1)

    # === Step 5: Update Config ===
    [ -n "$rootCA_file" ] && sed -i "s|^$rootCAPathVariable=.*|$rootCAPathVariable=\"$rootCA_file\"|" "$config_file"
    [ -n "$clientCert_file" ] && sed -i "s|^$ClientCertPathVariable=.*|$ClientCertPathVariable=\"$clientCert_file\"|" "$config_file"
    [ -n "$privateKey_file" ] && sed -i "s|^$PrivateKeyPathVariable=.*|$PrivateKeyPathVariable=\"$privateKey_file\"|" "$config_file"

    echo "Root CA: ${rootCA_file:-Not found}"
    echo "Client Cert: ${clientCert_file:-Not found}"
    echo "Private Key: ${privateKey_file:-Not found}"
    echo "Config file updated with certificate paths."

    # === Step 6: TLS Validation ===
    if [ "$MQTTEnable1" = "mqtt" ] || { [ "$MQTTEnable1" = "http" ] && [ "$EnableMQTTCommand" = "1" ]; }; then
        rootCAPath=$(grep "^$rootCAPathVariable=" "$config_file" | cut -d'=' -f2 | tr -d '"')
        if [ -n "$rootCAPath" ]; then
            echo "TLS: Validation succeeded."
        else
            echo "TLS: Validation failed. Please upload TLS certificate." >> /tmp/updateconfigoutput.txt
            return 1
        fi
    fi

    echo "=== UpdateMQTTConfiguration Completed ==="
}


###############################################################
# Function: UpdateMQTTConfiguration2 (Second Broker)
###############################################################
UpdateMQTTConfiguration2()
{

    certs_dir="/root/SenderAppComponent/etc/certs2/"
    config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"
    rootCAPathVariable="rootCAPath_1"
    ClientCertPathVariable="ClientCertPath_1"
    PrivateKeyPathVariable="PrivateKeyPath_1"

    zip_file=$(find "$certs_dir" -maxdepth 1 -type f -name "*.zip" | head -1)
    if [ -n "$zip_file" ]; then
        echo "ZIP file found: $zip_file"
        echo "Extracting to $certs_dir ..."
        unzip -o "$zip_file" -d "$certs_dir" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Extraction successful."
            rm -f "$zip_file"
            echo "Deleted ZIP after extraction."
        else
            echo "Error extracting ZIP file: $zip_file"
            return 1
        fi
    else
        echo "No ZIP file found — proceeding with existing files."
    fi

    # Find new certificate paths
    rootCA_file_path_1=$(find "$certs_dir" -type f -name "*.pem" | grep -E "RootCA|CA" | head -1)
    clientCert_file_path=$(find "$certs_dir" -type f -name "*.cert.pem" | head -1)
    privateKey_file_path=$(find "$certs_dir" -type f -name "*.private.key" | head -1)

    # Update placeholders (create if missing)
    grep -q "^$rootCAPathVariable=" "$config_file" || echo "$rootCAPathVariable=\"\"" >> "$config_file"
    grep -q "^$ClientCertPathVariable=" "$config_file" || echo "$ClientCertPathVariable=\"\"" >> "$config_file"
    grep -q "^$PrivateKeyPathVariable=" "$config_file" || echo "$PrivateKeyPathVariable=\"\"" >> "$config_file"

    # Write new paths
    if [ -n "$rootCA_file_path_1" ]; then
        sed -i "s|^$rootCAPathVariable=.*|$rootCAPathVariable=\"${rootCA_file_path_1}\"|" "$config_file"
        echo "Root CA found: $rootCA_file_path_1"
    else
        echo "Warning: Root CA not found after extraction"
    fi

    if [ -n "$clientCert_file_path" ]; then
        sed -i "s|^$ClientCertPathVariable=.*|$ClientCertPathVariable=\"${clientCert_file_path}\"|" "$config_file"
        echo "Client certificate found: $clientCert_file_path"
    else
        echo "Warning: Client certificate not found"
    fi

    if [ -n "$privateKey_file_path" ]; then
        sed -i "s|^$PrivateKeyPathVariable=.*|$PrivateKeyPathVariable=\"${privateKey_file_path}\"|" "$config_file"
        echo "Private key found: $privateKey_file_path"
    else
        echo "Warning: Private key not found"
    fi

    echo "==== Config file updated ===="
    grep -E "rootCAPath_1|ClientCertPath_1|PrivateKeyPath_1" "$config_file"
    echo "============================="

    # TLS Validation
    if [ "$MQTTEnable2" = "mqtt" ] || { [ "$MQTTEnabl21" = "http" ] && [ "$EnableMQTTCommand2" = "1" ]; }; then
        actual_rootCA=$(grep "^$rootCAPathVariable=" "$config_file" | cut -d'=' -f2 | tr -d '"')

        if [ -n "$actual_rootCA" ]; then
            echo -e "\033[0;32mTLS: Validation succeeded. Certificates ready.\033[0m"
        else
            [ ! -f /tmp/updateconfigoutput.txt ] && touch /tmp/updateconfigoutput.txt
            echo -e "\033[0;31mTLS: Validation failed. Please upload proper TLS bundle.\033[0m"
            echo "TLS: Validation failed. Please upload proper TLS bundle." >> /tmp/updateconfigoutput.txt
            return 1
        fi
    fi
}



###############################################################
# UpdateMQTTConfigurationCA
###############################################################

UpdateMQTTConfigurationCA()
{
    certs_dir="/root/SenderAppComponent/etc/certs/"
    config_file="/root/SenderAppComponent/etc/Config/externalBrokerConfig.cfg"


    zip_file=$(ls "$certs_dir"/*.zip 2>/dev/null)
    if [ -n "$zip_file" ]; then
        echo "Zip file found: $zip_file"
        echo "Extracting certificates..."
        unzip -o "$zip_file" -d "$certs_dir" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Extraction successful."
            rm -f "$zip_file"
        else
            echo "Error extracting $zip_file"
        fi
    else
        echo "No ZIP file found in $certs_dir"
    fi

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


    # Step 1: Unzip uploaded ZIP file
    zip_file=$(ls "$certs_dir"/*.zip 2>/dev/null)
    if [ -n "$zip_file" ]; then
        echo "Zip file found: $zip_file"
        echo "Extracting certificates to $certs_dir..."
        unzip -o "$zip_file" -d "$certs_dir" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "Extraction successful."
            rm -f "$zip_file"
        else
            echo "Error: Failed to extract $zip_file"
        fi
    else
        echo "No ZIP file found in $certs_dir"
    fi
    
    
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




###############################################################
# Execute Updates
###############################################################

        if [ "$mqttauthmode" = "0" ] 
        then
            UpdateMQTTConfiguration
        elif [ "$mqttauthmode" = "1" ]
        then     
            UpdateMQTTConfigurationCA        
        elif [ "$mqttauthmode" = "4" ]
        then     
            UpdateMQTTConfiguration
        fi 
        
        
        if [ "$mqttauthmode2" = "0" ] 
        then
             UpdateMQTTConfiguration2
        elif [ "$mqttauthmode2" = "1" ]
        then     
             UpdateMQTTConfigurationCA2        
        elif [ "$mqttauthmode2" = "4" ]
        then     
             
             UpdateMQTTConfiguration2
        fi 
        
