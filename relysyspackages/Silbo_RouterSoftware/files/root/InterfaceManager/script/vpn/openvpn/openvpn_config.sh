#!/bin/sh

. /lib/functions.sh

OpenvpnUCIPath=/etc/config/openvpn

ReadOpenvpnUCIConfig() {
    config_load "$OpenvpnUCIPath"
    config_foreach OpenvpnConfigParameters openvpn1
}
OpenvpnConfigParameters() {
    local OpenvpnConfigSection="$1"
    config_get Name "$OpenvpnConfigSection" name
    config_get Enabled "$OpenvpnConfigSection" enabled
    config_get Config "$OpenvpnConfigSection" config

    
	if [ -f "$Config" ]; then
		
		#Removes ^m from .ovpn certificate
        sed -i 's/\r//g' "$Config"

		Role=$(grep -F 'client' "$Config" | sed -n '/^[^#;]/{p;q}' | awk '{print toupper($0)}')

		if [ "$Role" != "CLIENT" ]; then
			Role="SERVER"
		fi

		echo "Role: $Role"

		if [ "$Role" == "CLIENT" ]; then
			Mode=$(grep -F 'dev' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Proto=$(grep -F 'proto' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Subject=$(grep -F 'Subject: CN' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d "=" -f 2 -s)
			Port=$(grep -F 'remote' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 3 -s)
			auth_pass=$(grep -F 'auth-user-pass' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
			ask_pass=$(grep -F 'askpass' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
			
			if [ -n "$Port" ]; then
				echo "port"
			else
				Port=$(grep -F 'port' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
			fi

		
		elif [ "$Role" == "SERVER" ]; then
			Mode=$(grep -F 'dev' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Proto=$(grep -F 'proto' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Subject=$(grep -F 'Subject: CN' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d "=" -f 2 -s)
			Port=$(grep -F 'port' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
			auth_pass=$(grep -F 'auth-user-pass' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
			ask_pass=$(grep -F 'askpass' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
		fi
		
		uci set openvpn.$Name.role=$Role                                                                                
		uci set openvpn.$Name.mode=$Mode                                                                                
		uci set openvpn.$Name.proto=$Proto                                                                              
		uci set openvpn.$Name.port=$Port
		# Set sub value
		if [ -n "$Subject" ]; then
			uci set openvpn.$Name.sub="$Subject"
		else
			uci set openvpn.$Name.sub="--NA--"
		fi

		# Set auth_pass value
		if [ -n "$auth_pass" ]; then
			uci set openvpn.$Name.auth_pass="$auth_pass"
		else
			uci set openvpn.$Name.auth_pass="--NA--"
		fi

		# Set ask_pass value
		if [ -n "$ask_pass" ]; then
			uci set openvpn.$Name.ask_pass="$ask_pass"
		else
			uci set openvpn.$Name.ask_pass="--NA--"
		fi


		echo "Mode: $Mode"
		echo "Proto: $Proto"
		echo "Port: $Port"
	else
		echo "Config file not found"
	fi
} 

ReadOpenvpnUCIConfig 

uci commit openvpn
