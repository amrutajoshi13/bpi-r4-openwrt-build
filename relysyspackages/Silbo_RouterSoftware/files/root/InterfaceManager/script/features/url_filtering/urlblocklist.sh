#!/bin/sh

. /lib/functions.sh

UrlUCIPath="/etc/config/urlipconfig"
UrlBlockUCIPath="/etc/config/block"

lanCount=$(cat /etc/internetoverlan.txt | wc -l)

Accesspolicy_access=$(uci get urlipconfig.@Mode[0].Accesspolicy)

whitelist_found=false
url_file_path=""

ReadUrlUCIConfig() {
    config_load "$UrlUCIPath"
    config_foreach UrlConfigParameters urlipconfig
}

ReadUrlBlockUCIConfig() {
    config_load "$UrlBlockUCIPath"
    config_foreach UrlConfigParameters1 block
}

UrlConfigParameters() {
    local UrlConfigSection="$1"
    NoOfSectionCount=$((NoOfSectionCount + 1))

    config_get urlblock "$UrlConfigSection" RS485ConfigSectionName
    config_get Enable "$UrlConfigSection" UrlfilteringSwitch
    config_get Mode "$UrlConfigSection" Accesspolicy

    echo "Processing section: $UrlConfigSection"
    echo "urlblock: $urlblock, Enable: $Enable, Mode: $Mode"

    urlblock=$(echo "$urlblock" | sed 's/\*//g')
    #echo The value of $urlblock
    if [ "$Enable" = "1" ]; then
        if [ "$Mode" = "Whitelist" ]; then
            if [[ -n "$urlblock" ]]; then
                # Apply sed commands for URL formatting
                urlblock=$(echo "$urlblock" | sed 's/\r$//' | sed -E 's~(https?://)?(www\.)?([^/]+).*~\3~')
                uci add_list dhcp.@dnsmasq[0].server="/$urlblock/#"
                uci add_list dhcp.@dnsmasq[0].server="/$urlblock/::"
                whitelist_found=true
            fi
        elif [ "$Mode" = "Blacklist" ]; then
            if [[ -n "$urlblock" ]]; then
                # Apply sed commands for URL formatting
                urlblock=$(echo "$urlblock" | sed 's/\r$//' | sed -E 's~(https?://)?(www\.)?([^/]+).*~\3~')
                uci add_list dhcp.@dnsmasq[0].server="/$urlblock/"
            fi
        fi
    fi
}

UrlConfigParameters1() {
    local UrlConfigSection1="$1"
    NoOfSectionCount=$((NoOfSectionCount + 1))
    config_get path "$UrlConfigSection1" config
    url_file_path="$path"
    echo "The value of path is $url_file_path"
    # Fetch .txt file path only once
    if [ -n "$url_file_path" ]; then
        AddEntriesFromFile "$url_file_path"
    fi
}

AddEntriesFromFile() {
    local filepath="$1"
    echo "Reading entries from file: $filepath"
    if [ -f "$filepath" ]; then
        while IFS= read -r line; do
            echo "Processing line: $line"
            if [[ -n "$line" ]]; then
                uci add urlipconfig urlipconfig
                # Get the last added section's index using awk
                last_index=$(uci show urlipconfig | grep -E "^urlipconfig\.@urlipconfig\[[0-9]+\]=" | tail -n 1 | cut -d '[' -f2 | cut -d ']' -f1)
                # Set the options for the last added section
                uci set urlipconfig.@urlipconfig[$last_index].RS485ConfigSectionName="$line"
                #uci set urlipconfig.@urlipconfig[$last_index].EEnable='1'
                uci set urlipconfig.@urlipconfig[$last_index].UrlfilteringSwitch='1'
                if [ "$Accesspolicy_access" = "Whitelist" ]; then
					uci set urlipconfig.@urlipconfig[$last_index].Accesspolicy='Whitelist'
                elif [ "$Accesspolicy_access" = "Blacklist" ]; then
					uci set urlipconfig.@urlipconfig[$last_index].Accesspolicy='Blacklist'
				fi
            fi
        done <"$filepath"
        # Remove the file after processing
        rm "$filepath"
        # Call ReadUrlUCIConfig after processing the file
        uci commit urlipconfig
        
        #Clear DHCP servers when the file is uploaded before calling ReadUrlUCIConfig.
        #This is to avoid replication of the URLs in dhcp config file.
        uci delete dhcp.@dnsmasq[0].server
		uci commit dhcp
        
        ReadUrlUCIConfig
    fi
}

# Clear DHCP servers before adding new ones for Both whitelist & Blaclist
uci delete dhcp.@dnsmasq[0].server
uci delete dhcp.@dnsmasq[0].address
uci commit dhcp

ReadUrlUCIConfig
ReadUrlBlockUCIConfig

if [ "$whitelist_found" = true ]; then
    #For dnsmasq version less than 2.89. Tested in 2.85.
    #uci add_list dhcp.@dnsmasq[0].server="/#/"
    #For dnsmasq version greater/equal to 2.89. Tested in 2.89.
    uci add_list dhcp.@dnsmasq[0].address="/#/0.0.0.0"
    uci add_list dhcp.@dnsmasq[0].address="/#/::"
fi

uci commit urlipconfig
uci commit dhcp
logger -t config -p customs.info "dhcp configuration changed"

for j in $(seq 1 ${lanCount}); do
    lan=$(cat /etc/internetoverlan.txt | head -${j} | tail -1)
    lan=$(uci get networkinterfaces.${lan}.ifname)

    ifconfig ${lan} down

done
ifconfig wlan0 down
ifconfig wlan1 down
ifconfig ra0 down
ifconfig ra1 down

sleep 3


for j in $(seq 1 ${lanCount}); do
    lan=$(cat /etc/internetoverlan.txt | head -${j} | tail -1)
    lan=$(uci get networkinterfaces.${lan}.ifname)

    ifconfig ${lan} up

done

ifconfig wlan0 up
ifconfig wlan1 up
ifconfig ra0 up
ifconfig ra1 up

/etc/init.d/dnsmasq restart
