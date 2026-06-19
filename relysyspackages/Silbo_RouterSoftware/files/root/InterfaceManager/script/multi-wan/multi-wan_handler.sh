#!/bin/sh

. /lib/functions.sh

ReadPriority()
{
  config=$1
  config_get WanPriority "$config" wanpriority 
  echo $WanPriority >> /bin/wanpriorities.txt
}

# Read the old config and update the mwan3config.
/root/InterfaceManager/script/multi-wan/UpdateWanConfig.sh

# validate if the wan priorities are not same.
rm -rf /bin/wanpriorities.txt
touch /bin/wanpriorities.txt
chmod 0777 /bin/wanpriorities.txt

rm -rf /bin/priorityvalidationoutput.txt
touch  /bin/priorityvalidationoutput.txt
chmod 0777 /bin/priorityvalidationoutput.txt

config_load "/etc/config/mwan3config" 
config_foreach ReadPriority redirect

policy_type=$(uci get mwan3config.general.select)

if [ "$policy_type" = "failover" ] 
then
	# Sort the priorities in order.
	output=$(sort /bin/wanpriorities.txt)

	# Now using the loop below, check if any priorities match. If they do, display a text and exit the script.
	prev=""
	for val in $output; do
		if [ "$val" = "$prev" ]; then
			# This below response is then displayed using rpcd file.
			echo "Same priorities, can not update the configuration." > /bin/priorityvalidationoutput.txt
			exit 1
		fi
		prev="$val"
	done
fi

#Update the below response, if the priorities are different.
echo "Updating configuration." > /bin/priorityvalidationoutput.txt

/root/InterfaceManager/script/multi-wan/multi-wan_settings.sh &

exit 0
