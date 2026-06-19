#!/bin/sh
. /lib/functions.sh

#snmp configurations
SnmptrapConfigfile="/etc/snmp/snmptrapconfig.cfg"
SNMPUtilityDeviceconfigureFile="/etc/config/snmptrapconfig"
snmptrapdconf_file="/etc/snmp/snmptrapd.conf"
AppSleepInterval=5

# Function to check if a line exists in a file
line_exists() {
    local line="$1"
    grep -qF "$line" "$2"
}
app_restart() {
              /etc/init.d/snmptrapd restart                                                                                           
              killall -9 "ReadDIApp" > /dev/null 2>&1 &                                                                       
              sleep "$AppSleepInterval"                                                                                               
              /etc/snmp/ReadDIApp > /dev/null 2>&1 &                                                                          
              sleep "$AppSleepInterval"
}

line_removedefault() {                                                                                                                           
# Check if the file exists                                                                                                                      
if [ -f "$snmptrapdconf_file" ]; then                                                                                                           
        sed -i '/traphandle\|authCommunity/d' "$snmptrapdconf_file"                                                                                    
    echo "Lines removed successfully."                                                                                                          
fi                                                                                                                                              
}


line_removenoauth() {
# Check if the file exists
if [ -f "$snmptrapdconf_file" ]; then
	sed -i '/createUser\|rouser/d' "$snmptrapdconf_file"
    echo "Lines removed successfully."
fi
}

line_remove() {
# Check if the file exists
if [ -f "$snmptrapdconf_file" ]; then
	sed -i '/createUser\|authUser/d' "$snmptrapdconf_file"
	sed -i '/authtrapenable/d' "$snmptrapdconf_file"
    echo "Lines removed successfully."
fi
}


# Function to generate createUser and rouser lines for SNMPv3 and append to snmpd.conf                                       
generate_snmpv3_noauth() {                                                                                                   
    local username="$1"                                                                                                      
    snmpv3_config_exists="false"
    line_remove
    if line_exists "createUser -e 0x0102030405 $username" "$snmptrapdconf_file"; then
        snmpv3_config_exists="true"                                                                                          
    fi                                                                                                                       
    if ! "$snmpv3_config_exists"; then                                                                                       
                                                                                                                             
        # Add SNMPv3 configuration lines
	echo "authtrapenable 1" >> "$snmptrapdconf_file"                                                                                     
        echo "createUser -e 0x0102030405 $username " >> "$snmptrapdconf_file"                                                                    
        echo "authUser log,execute,net $username noauth" >> "$snmptrapdconf_file"                                                
    fi
}

# Function to generate createUser and rouser lines for SNMPv3 and append to snmpd.conf                                       
generate_snmpv3_authnopriv() {                                                                                               
    local username="$1"                                                                                                      
    local auth_protocol="$2"                                                                                                 
    local auth_password="$3"                                                                                                 
    line_remove    
    snmpv3_config_exists="false"                                                                                             
    if line_exists "createUser -e 0x0102030405 $username $auth_protocol $auth_password" "$snmptrapdconf_file"; then
        snmpv3_config_exists="true"                                                                                          
    fi                                                                                                                       
    if ! "$snmpv3_config_exists"; then                                                                                       
                                                                                                                             
        # Add SNMPv3 configuration lines                                                                                   
        echo "authtrapenable 1" >> "$snmptrapdconf_file"                                                                         
        echo "createUser -e 0x0102030405 $username $auth_protocol $auth_password" >> "$snmptrapdconf_file"                                                    
        echo "authUser log,execute,net $username auth" >> "$snmptrapdconf_file"   
    fi                                                                                                                                          
} 

# Function to generate createUser and rouser lines for SNMPv3 and append to snmpd.conf                                       
generate_snmpv3_authpriv() {                                                                                                 
    local username="$1"                                                                                                      
    local auth_protocol="$2"                                                                                                 
    local auth_password="$3"                                                                                                 
    local priv_protocol="$4"                                                                                                 
    local priv_password="$5"                                                                                                 
    line_remove
    snmpv3_config_exists="false"                                                                                             
    if line_exists "createUser -e 0x0102030405 $username $auth_protocol $auth_password $priv_protocol $priv_password" "$snmptrapdconf_file"; then
        snmpv3_config_exists="true"                                                                                          
    fi                                                                                                                       
    if ! "$snmpv3_config_exists"; then                                                                                       
                                                                                                                             
        # Add SNMPv3 configuration lines
	echo "authtrapenable 1" >> "$snmptrapdconf_file" 
        echo "createUser -e 0x0102030405 $username $auth_protocol $auth_password $priv_protocol $priv_password" >> "$snmptrapdconf_file"
	echo "authUser log,execute,net $username auth" >> "$snmptrapdconf_file"                                                   
    fi                                                                                                                       
}

SNMPUtilityDeviceConfigUpdate() 
 {
    local SnmpDeviceConfigSection="$1"
    #local device_count = 1  
                                                                                                                               
           config_get enablesnmptrap "$SnmpDeviceConfigSection" enablesnmptrap
	   config_get host "$SnmpDeviceConfigSection" host
           config_get community "$SnmpDeviceConfigSection" community
	   config_get enableiotrap "$SnmpDeviceConfigSection" enableiotrap
           config_get version3 "$SnmpDeviceConfigSection" version3                                        
           config_get snmptrapsecurity "$SnmpDeviceConfigSection" snmptrapsecurity                                        
           config_get username "$SnmpDeviceConfigSection" username                                         
           config_get authenticationpassword "$SnmpDeviceConfigSection" authenticationpassword             
           config_get privacypassword "$SnmpDeviceConfigSection" privacypassword 
      		
		echo "SNMPTrapStatus=$enablesnmptrap"  >> "${SnmptrapConfigfile}"
		echo "SNMPTrapHost=$host"  >> "${SnmptrapConfigfile}"
		echo "SNMPTrapCommunity=$community"  >> "${SnmptrapConfigfile}"
		echo "SNMPTrapIo=$enableiotrap"  >> "${SnmptrapConfigfile}"
		echo "SNMPTrapVersion3=$version3"  >> "${SnmptrapConfigfile}"                                 
		echo "SNMPTrapSecurity=$snmptrapsecurity"  >> "${SnmptrapConfigfile}"                                 
                echo "SNMPTrapUser=$username"  >> "${SnmptrapConfigfile}"                                 
                echo "SNMPTrapAuthPassword=$authenticationpassword"  >> "${SnmptrapConfigfile}"     
                echo "SNMPTrapPrivPassword=$privacypassword"  >> "${SnmptrapConfigfile}" 
                echo "SNMPTrapAuthProtocol=MD5"  >> "${SnmptrapConfigfile}"     
                echo "SNMPTrapPrivProtocol=DES"  >> "${SnmptrapConfigfile}"     
		
		echo "$snmptrapsecurity" 
	    
	    if [ $version3 = 0 ]; then
		line_removedefault

		echo "traphandle default /var/log/snmptraps.log" >> "$snmptrapdconf_file"
		echo "authCommunity log,execute,net public" >> "$snmptrapdconf_file"
		app_restart
	    elif [ $version3 = 1 ]; then
                if [ $snmptrapsecurity = 1 ]; then
                                snmpv3_user="$username"                                                                      
				echo "$snmpv3_user" 
                                generate_snmpv3_noauth "$snmpv3_user"                                                        
                                echo "SNMPv3 NoAuthNoPriv have been added in snmptrapd.conf"
				app_restart
                elif [ $snmptrapsecurity = 2 ]; then
                                snmpv3_user="$username"                                                                      
                                snmpv3_auth_protocol="MD5"                                   
                                snmpv3_auth_password="$authenticationpassword"                                               
                                generate_snmpv3_authnopriv "$snmpv3_user" "$snmpv3_auth_protocol" "$snmpv3_auth_password"    
                                echo "SNMP AuthNoPriv updated successfully." 
				app_restart 
                elif [ $snmptrapsecurity = 3 ]; then               
                        # Specify the SNMPv3 user credentials
                        snmpv3_user="$username"                                                                              
                        snmpv3_auth_protocol="MD5"                                                                           
                        snmpv3_auth_password="$authenticationpassword"                                                       
                        snmpv3_priv_protocol="DES"                                                                           
                        snmpv3_priv_password="$privacypassword"                                                              
                        # Generate SNMPv3 configuration lines                                                                
                        generate_snmpv3_authpriv "$snmpv3_user" "$snmpv3_auth_protocol" "$snmpv3_auth_password" "$snmpv3_priv_protocol" "$snmpv3_priv_password"
                        echo "SNMP configuration updated successfully."
			app_restart
                fi                                                     
        fi
}
 UpdateSNMPtrapCfg()                                               
{               
    rm "${SnmptrapConfigfile}"           
    config_load "$SNMPUtilityDeviceconfigureFile"
    config_foreach SNMPUtilityDeviceConfigUpdate snmptrapconfig
    #echo "NoGeneric_SNMP_Device=$NoOfSnmpDeviceCount" >> "${ModbusRs485UtilityConfigfile}"
   # echo "#Number of meters to read" >> "${ModbusRs485UtilityConfigfile}"
    {
	    echo "End"
    } >> "${SnmptrapConfigfile}"     
} 
UpdateSNMPtrapCfg  
