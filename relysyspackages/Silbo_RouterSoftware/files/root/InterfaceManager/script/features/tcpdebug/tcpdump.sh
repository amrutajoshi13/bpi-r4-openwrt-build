#!/bin/sh

. /lib/functions.sh

tcpdumpconfigfile="/etc/config/tcpdumpconfig"

tcp_dump() {
  tcpread="$1"

  
  config_get Customtcp_command "$tcpread" customtcp_command
  config_get Timeout "$tcpread" timeout
  config_get Storage "$tcpread" tcp_mount
  config_get Tcpdump_mode "$tcpread" tcpdump_mode

  # echo The value of $Tcpdump_mode

  # Remove 'tcpdump' from the customtcp_command variable (if present)
  # If the command is passed in with embedded quotes, use the correct escaping
  #Customtcp_command=$(echo "$Customtcp_command" | sed "s/'/\\'/g")

  Customtcp_command=$(echo "$Customtcp_command" | sed 's/^tcpdump\s*//')

  # Start the tcpdump process with manual command
  [ "$Tcpdump_mode" = 'customenabled' ] && timeout "$Timeout" /usr/sbin/tcpdump $Customtcp_command -w "$Storage"/tcpdebug.pcap


  # Proceed only if Tcpdump_mode is 'enabled'
  [ "$Tcpdump_mode" != "enabled" ] && return
    

  config_get Interface "$tcpread" interface
  config_get Proto "$tcpread" proto
  #Set the proto as empty, if any is selected.
  if [ "$Proto" = "all" ]; then
    Proto=""
    uci set tcpdumpconfig.tcpdump.proto=$Proto
    uci commit tcpdumpconfig
  fi

  config_get Port "$tcpread" port
  config_get Direction "$tcpread" tcp_inout
  config_get Timeout "$tcpread" timeout
  config_get Ipaddress "$tcpread" ipaddress
  config_get Tcp_subnet "$tcpread" tcp_subnet
  config_get Host "$tcpread" tcp_host

  if [ "$Ipaddress" = "none" ]; then
    echo "The value of 1st & 2nd $Ipaddress"
    uci delete tcpdumpconfig.tcpdump.tcp_subnet
    uci delete tcpdumpconfig.tcpdump.tcp_host
    Host=""
    Tcp_subnet=""
    uci commit tcpdumpconfig
  fi

  if [ "$Ipaddress" = "hostip" ]; then
    echo "The value of 1st $Ipaddress"
    uci delete tcpdumpconfig.tcpdump.tcp_subnet
    Tcp_subnet=""
    uci commit tcpdumpconfig
  fi

  if [ "$Ipaddress" = "subnetip" ]; then
    echo "The value of 2nd means $Ipaddress"
    uci delete tcpdumpconfig.tcpdump.tcp_host
    Host=""
    uci commit tcpdumpconfig
  fi

  # Start building options
  options="-nvv"

  # Interface
  [ "$Interface" != "" ] && options="$options -i $Interface"

  # Direction
  [ "$Direction" != "" ] && options="$options -Q $Direction"

  # Protocol
  #[ "$Proto" != "" ] && options="$options $Proto"
  # Protocol
  if [ "$Proto" != "" ]; then
    # If Proto is not empty
    options="$options $Proto"

    # Port
    [ "$Port" != "" ] && options="$options port $Port"

    # Host
    [ "$Host" != "" ] && options="$options and host $Host"

    # Subnet
    [ "$Tcp_subnet" != "" ] && options="$options and net $Tcp_subnet"
  else
    # If Proto is empty, adjust logic accordingly

    # Port
    [ "$Port" != "" ] && options="$options port $Port"

    # Host
    [ "$Host" != "" ] && options="$options host $Host"

    # Subnet
    [ "$Tcp_subnet" != "" ] && options="$options net $Tcp_subnet"
  fi

  echo tcpdump $options

  # Start the tcpdump process
  timeout "$Timeout" /usr/sbin/tcpdump $options -w "$Storage"/tcpdebug.pcap

}

config_load "$tcpdumpconfigfile"
config_foreach tcp_dump tcpdump

exit 0
