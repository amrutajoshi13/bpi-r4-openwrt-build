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

                sed -i 's/\r//g' "$Config"

		Role=$(grep -F 'client' "$Config" | sed -n '/^[^#;]/{p;q}' | awk '{print toupper($0)}')

		if [ "$Role" != "CLIENT" ]; then
			Role="SERVER"
		fi

		echo "Role: $Role"

		if [ "$Role" == "CLIENT" ]; then
			Mode=$(grep -F 'dev' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Proto=$(grep -F 'proto' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Port=$(grep -F 'remote' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 3 -s)
                          if [ -n "$Port" ]; then
                            echo "port"
                          else
                            Port=$(grep -F 'port' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
                          fi

		
		elif [ "$Role" == "SERVER" ]; then
			Mode=$(grep -F 'dev' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Proto=$(grep -F 'proto' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s | awk '{print toupper($0)}')
			Port=$(grep -F 'port' "$Config" | sed -n '/^[^#;]/{p;q}' | cut -d " " -f 2 -s)
	        fi
		uci set openvpn.$Name.role=$Role                                                                                
		uci set openvpn.$Name.mode=$Mode                                                                                
		uci set openvpn.$Name.proto=$Proto                                                                              
		uci set openvpn.$Name.port=$Port 

		echo "Mode: $Mode"
		echo "Proto: $Proto"
		echo "Port: $Port"
else
    echo "Config file not found"
fi
} 

ReadOpenvpnUCIConfig 

uci commit openvpn
