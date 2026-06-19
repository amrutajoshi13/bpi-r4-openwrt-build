#!/bin/sh

LOCKFILE="/tmp/iptables_firewall_policy.lock"
MAX_WAIT=30  # Maximum time to wait for another instance (in seconds)

# Function to acquire a lock
acquire_lock() {
    local waited=0

    while [ -e "$LOCKFILE" ]; do
        logger -t firewall "<Iptables Firewall policy> Waiting for another instance of iptables_firewall_policy.sh to finish..."
        sleep 1
        waited=$((waited + 1))
        if [ "$waited" -ge "$MAX_WAIT" ]; then
            logger -t firewall "<Iptables Firewall policy> Another instance is still running after $MAX_WAIT seconds. Exiting."
            exit 1
        fi
    done

    # Create the lock file
    touch "$LOCKFILE"
    logger -t firewall "<Iptables Firewall policy> Lock acquired. Proceeding with execution."
}

# Function to release the lock
release_lock() {
    [ -e "$LOCKFILE" ] && rm -f "$LOCKFILE"
    logger -t firewall "<Iptables Firewall policy> Lock released."
}

# Trap to release the lock on script exit.
#Automatically releases the lock when the script exits (even on errors).
trap release_lock EXIT

# Acquire lock
acquire_lock

# Fetch configurations
enablecellular=$(uci get sysconfig.sysconfig.enablecellular)
CellularOperationModelocal=$(uci get sysconfig.sysconfig.CellularOperationMode)
IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)

# Exit if Cellular is not enabled.
if [ "$enablecellular" = "0" ]; then
    exit 0
fi

# Determine modem names based on the Cellular Operation Mode
if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]; then
    modem1=CWAN1
    modem2=CWAN2
elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]; then
    modem1=CWAN1_0
    modem2=CWAN1_1
else
    modem1=CWAN1
    modem2=""
fi

reload_firewall="0"

# Function to manage iptables rules for a given interface
firewall_policy() {
    local ModemName="$1"
    local status_file="/tmp/${ModemName}networkstatus"
	
	if [ "$ModemName" = "CWAN1_0" ]; then
		InterfaceName="cwan1_0"
	elif [ "$ModemName" = "CWAN1_1" ]; then
		InterfaceName="cwan1_1"
	elif [ "$ModemName" = "CWAN1" ]; then
		InterfaceName="cwan1"
	elif [ "$ModemName" = "CWAN2" ]; then
		InterfaceName="cwan2"
	fi
	
    if [ "$InterfaceName" = "cwan1_0" ] || [ "$InterfaceName" = "cwan1" ]; then
        IPV6InterfaceName="wan6c1"
    elif [ "$InterfaceName" = "cwan1_1" ] || [ "$InterfaceName" = "cwan2" ]; then
        IPV6InterfaceName="wan6c2"
    fi
	
	# Either the status file isn't there, or it is and contains “0”
	if [ ! -f "$status_file" ] || [ "$(cat "$status_file")" = "0" ]; then
    #if [ -f "$status_file" ] && [ "$(cat "$status_file")" = "0" ]; then
        logger -t firewall "<Iptables Firewall policy> Network status for ${InterfaceName} is 0."
        logger -t firewall "<Iptables Firewall policy> Proceeding with deletion for ${InterfaceName} and ${IPV6InterfaceName}."

        uci delete firewall.$InterfaceName.extra_src
        uci delete firewall.$InterfaceName.extra_dest
        uci delete firewall.$IPV6InterfaceName.extra_src
        uci delete firewall.$IPV6InterfaceName.extra_dest

    elif [ -f "$status_file" ] && [ "$(cat "$status_file")" = "1" ]; then
		if [ "$IpsecEnable" = "1" ] ; then
			logger -t firewall "<Iptables Firewall policy> Network status for ${InterfaceName} is 1."
			logger -t firewall "<Iptables Firewall policy> Adding back the policies for ${InterfaceName} and ${IPV6InterfaceName}."

			uci set firewall.$InterfaceName.extra_src='-m policy --dir in --pol none'
			uci set firewall.$InterfaceName.extra_dest='-m policy --dir out --pol none'
			uci set firewall.$IPV6InterfaceName.extra_src='-m policy --dir in --pol none'
			uci set firewall.$IPV6InterfaceName.extra_dest='-m policy --dir out --pol none'
		fi
    fi

    uci commit firewall
    reload_firewall="1"
}

# Process modems
firewall_policy "$modem1"
[ -n "$modem2" ] && firewall_policy "$modem2"

# Reload firewall if changes were made.
# DO NOT restart; this will cause errors in mwan3.
if [ "$reload_firewall" = "1" ]; then
    /etc/init.d/firewall reload
fi

# Release lock (handled by trap)
