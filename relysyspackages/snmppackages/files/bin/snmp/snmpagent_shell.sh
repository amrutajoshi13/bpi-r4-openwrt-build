#!/bin/sh

# Paths to configuration files
snmpconfig_file="/etc/config/snmpconfig"
snmpdconf_file="/etc/snmp/snmpd.conf"

/bin/modem.sh
/etc/snmp/systeminfo.sh

# For SNMPv3, remove the old username and password because a new password is used.
#After this new username and password is reload ...
/etc/init.d/snmpd stop
sed -i '/usmUser/d' /usr/lib/snmp/snmpd.conf
/etc/init.d/snmpd start

line_to_add() {
        line_to_add="pass .1.3.6.1.4.1.38151 /bin/sh /etc/snmp/OID_QUERY.sh"                                                 
        if ! line_exists "$line_to_add" "$snmpdconf_file"; then                                                              
                echo "$line_to_add" >> "$snmpdconf_file"                                                                     
        else                                                                                                                 
                echo "Line already exists in $snmpdconf_file. Skipping addition."                                            
        fi  
        
        # Update /etc/config/snmpd file
		uci set snmpd.@oid[0].pass='.1.3.6.1.4.1.38151 /bin/sh /etc/snmp/OID_QUERY.sh'
		uci commit snmpd	 
}

line_removenoauth() {
# Check if the file exists
if [ -f "$snmpdconf_file" ]; then
	sed -i '/createUser\|rouser/d' "$snmpdconf_file"
    echo "Lines removed successfully."
    
    ## Update /etc/config/snmpd file
    uci delete snmpd.@oidv3[0].createUser
    uci delete snmpd.@oidv3[0].rouser
    uci delete snmpd.@oidv3[0].rwuser
    uci commit snmpd
fi
}

line_remove() {
# Check if the file exists
if [ -f "$snmpdconf_file" ]; then
	sed -i '/createUser\|rwuser/d' "$snmpdconf_file"
    echo "Lines removed successfully."
fi
}

line_remove_pass() {
# Check if the file exists
if [ -f "$snmpdconf_file" ]; then
        sed -i '/pass/d' "$snmpdconf_file"
    echo "Lines removed successfully."
    
    # Update /etc/config/snmpd file
    uci delete snmpd.@oid[0].pass
    uci commit snmpd
fi
}

# Function to check if a line exists in a file
line_exists() {
    local line="$1"
    grep -qF "$line" "$2"
}

# Function to generate createUser and rouser lines for SNMPv3 and append to snmpd.conf
generate_snmpv3_noauth() {
    local username="$1"
    line_remove	
    line_remove_pass
    line_removenoauth
    snmpv3_config_exists="false"
    if line_exists "createUser $username $auth_protocol $auth_password $priv_protocol $priv_password" "$snmpdconf_file"; then
        snmpv3_config_exists="true"
    fi
    if ! "$snmpv3_config_exists"; then

	# Add SNMPv3 configuration lines
	echo "createUser $username " >> "$snmpdconf_file"
	echo "rouser $username noauth 1.3.6.1.4.1.38151" >> "$snmpdconf_file"
	
	# Update /etc/config/snmpd file
	uci set snmpd.@oidv3[0].createUser="$username"
	uci set snmpd.@oidv3[0].rouser="$username noauth 1.3.6.1.4.1.38151"
	uci commit snmpd
		
	line_to_add
    fi
}

# Function to generate createUser and rouser lines for SNMPv3 and append to snmpd.conf
generate_snmpv3_authnopriv() {
    local username="$1"
    local auth_protocol="$2"
    local auth_password="$3"
    line_remove	
    line_remove_pass
    line_removenoauth
    snmpv3_config_exists="false"
    if line_exists "createUser $username $auth_protocol $auth_password $priv_protocol $priv_password" "$snmpdconf_file"; then
        snmpv3_config_exists="true"
    fi
    if ! "$snmpv3_config_exists"; then

	# Add SNMPv3 configuration lines
	echo "createUser $username $auth_protocol $auth_password" >> "$snmpdconf_file"
	echo "rwuser $username auth 1.3.6.1.4.1.38151" >> "$snmpdconf_file"
	
	# Update /etc/config/snmpd file
	uci set snmpd.@oidv3[0].createUser="$username $auth_protocol $auth_password"
	uci set snmpd.@oidv3[0].rwuser="$username auth 1.3.6.1.4.1.38151"
	uci commit snmpd
	line_to_add
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
    line_remove_pass
    line_removenoauth
    snmpv3_config_exists="false"
    if line_exists "createUser $username $auth_protocol $auth_password $priv_protocol $priv_password" "$snmpdconf_file"; then
        snmpv3_config_exists="true"
    fi
    if ! "$snmpv3_config_exists"; then

	# Add SNMPv3 configuration lines
	echo "createUser $username $auth_protocol $auth_password $priv_protocol $priv_password" >> "$snmpdconf_file"
	echo "rwuser $username priv 1.3.6.1.4.1.38151" >> "$snmpdconf_file"
	
	# Update /etc/config/snmpd file
	uci set snmpd.@oidv3[0].createUser="$username $auth_protocol $auth_password $priv_protocol $priv_password"
	uci set snmpd.@oidv3[0].rwuser="$username priv 1.3.6.1.4.1.38151"
	uci commit snmpd
	
	line_to_add
    fi
}

# Function to get a configuration value
config_get() {
    local key="$1"
    local value=$(sed -n "/\($key\)/ s/.*'\([^']*\)'.*/\1/p" "/etc/config/snmpconfig")
    echo "$value"
}

# Function to set a configuration value in snmpd.conf
config_set() {
    local key="$1"
    local value="$2"
    sed -i "s/^$key .*/$key $value/" "$snmpdconf_file"
}

get_set_func() {
# Read values from snmpconfig file
sysName=$(config_get "option name")
sysLocation=$(config_get "option location")
sysContact=$(config_get "option contact")
version1=$(config_get "option version1")
version2=$(config_get "option version2")
version3=$(config_get "option version3")
security=$(config_get "option snmpsecurity")
username=$(config_get "option username")
authenticationpassword=$(config_get "option authenticationpassword")
privacypassword=$(config_get "option privacypassword")

 # Update snmpd.conf file with the new values
    config_set "sysName" "$sysName"
    config_set "sysLocation" "$sysLocation"
    config_set "sysContact" "$sysContact"
 
 # Update /etc/config/snmpd file with the new values
	
	uci set snmpd.@system[0].sysName="$sysName"
	uci set snmpd.@system[0].sysLocation="$sysLocation"
	uci set snmpd.@system[0].sysContact="$sysContact"
	
	uci commit snmpd
	
    if [ $version1 = 0 ] && [ $version2 = 0 ] && [ $version3 = 0 ]; then                                                   
        line_remove  
	line_remove_pass
   	line_removenoauth
    elif [ $version1 = 1 ] && [ $version2 = 1 ] && [ $version3 = 0 ]; then
	line_remove
	line_to_add
	line_removenoauth
    elif [ $version1 = 1 ] && [ $version2 = 0 ] && [ $version3 = 0 ]; then                                                                   
        line_remove                                                                                                                          
        line_to_add  
	line_removenoauth
    elif [ $version1 = 0 ] && [ $version2 = 1 ] && [ $version3 = 0 ]; then
	line_remove
	line_to_add
	line_removenoauth
    elif [ $version3 = 1 ]; then
		if [ "$security" == 'NoAuthNoPriv' ]; then
				snmpv3_user="$username"
				generate_snmpv3_noauth "$snmpv3_user"
				echo "SNMPv3 NoAuthNoPriv have been added to $snmpdconf_file"
				echo "SNMP NoAuthNoPriv updated successfully."
		elif [ "$security" == 'AuthNoPriv' ]; then
				snmpv3_user="$username"
				snmpv3_auth_protocol="MD5"
				snmpv3_auth_password="$authenticationpassword"
				generate_snmpv3_authnopriv "$snmpv3_user" "$snmpv3_auth_protocol" "$snmpv3_auth_password"
				echo "SNMPv3 AuthNoPriv have been added to $snmpdconf_file"
				echo "SNMP AuthNoPriv updated successfully."
		elif [ "$security" == 'AuthPriv' ]; then 
			# Specify the SNMPv3 user credentials
			snmpv3_user="$username"
			snmpv3_auth_protocol="MD5"
			snmpv3_auth_password="$authenticationpassword"
			snmpv3_priv_protocol="DES"
			snmpv3_priv_password="$privacypassword"
			# Generate SNMPv3 configuration lines
			generate_snmpv3_authpriv "$snmpv3_user" "$snmpv3_auth_protocol" "$snmpv3_auth_password" "$snmpv3_priv_protocol" "$snmpv3_priv_password"	
			echo "SNMPv3 configuration lines have been added to $snmpdconf_file"
			echo "SNMP configuration updated successfully."
		fi
	fi
	# Restart SNMP service (replace with the appropriate command for your system)
    	/etc/init.d/snmpd restart
}

# Specify the source path where GET-METER-SIGNALS-MIB.txt is located
source_path="/etc/snmp"

# Specify the destination path where you want to check and copy the file
destination_path="/usr/share/snmp/mibs"

# Check if the file exists in the destination directory
if [ -e "$destination_path/INVENDIS-DEVICES-INFO-MIB.txt" ]; then
    echo "File exists in the destination directory."
else
    # If the file doesn't exist, copy it from the source directory
    if [ -e "$source_path/INVENDIS-DEVICES-INFO-MIB.txt" ]; then
 	mkdir -p /home/invendis/.snmp/mibs
 	mkdir -p /usr/local/share/snmp/mibs
        cp "$source_path/INVENDIS-DEVICES-INFO-MIB.txt" "$destination_path/"
 	cp -r /usr/share/snmp/mibs/INVENDIS-DEVICES-INFO-MIB.txt /home/invendis/.snmp/mibs/
 	cp -r /usr/share/snmp/mibs/INVENDIS-DEVICES-INFO-MIB.txt /usr/local/share/snmp/mibs/
        echo "File copied successfully."
    else
        echo "Error: Source file not found in the specified path."
    fi
fi

# Check if the snmpconfig file exists                                                 
if [ ! -f "$snmpconfig_file" ]; then                  
    echo "Error: snmpconfig file not found."                                          
    exit 1                                                                                                           
else                                                
    echo "Files presented here"                       
    get_set_func                                    
fi
