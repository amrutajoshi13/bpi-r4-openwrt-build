#!/bin/sh
. /lib/functions.sh


#board_name=$(cat /tmp/sysinfo/board_name)

# Read 1 byte from flash offset 0xF020
	flash_val=$(dd if=/dev/mtd2 bs=1 skip=$((0xF020)) count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
	 
	# If nothing read, treat as FF
	[ -z "$flash_val" ] && flash_val="FF"
	 
	case "$flash_val" in
	    0B)
	        board_name="IDB54-C-GW"
	        ;;
	    0F)
	        board_name="IDF54-C-GW"
	        ;;
	    FF)
	        board_name=$(cat /tmp/sysinfo/board_name)
	        ;;
	    *)
	        # Safety fallback
	        board_name=$(cat /tmp/sysinfo/board_name)
	        ;;
	esac

source /root/ReadDIAppComponent/etc/Config/ReadDIAppConfig.cfg


if echo "$board_name" | grep -qE "(ID)";
	then
		for i in 392 393 394 395
		do
			echo "$i" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio${i}/direction
			echo "0" > /sys/class/gpio/gpio${i}/value
		done
		

		

			# Extract only DIOMode1
		diomode1=$DIOMode1
		diomode2=$DIOMode2
		diomode3=$DIOMode3
		diomode4=$DIOMode3
		echo "diomode1=$diomode1"
		echo "diomode2=$diomode2"
		echo "diomode3=$diomode3"
		echo "diomode4=$diomode4"

		if [ "$diomode1" = "1" ]; then
			echo "388" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio388/direction
			echo "1" > /sys/class/gpio/gpio392/value
		fi
			
		if [ "$diomode2" = "1" ]; then                      
				echo "389" > /sys/class/gpio/export
				echo "out" > /sys/class/gpio/gpio389/direction
				
				echo "1" > /sys/class/gpio/gpio393/value
		fi
		
		if [ "$diomode3" = "1" ]; then                                                                   
		                     
				echo "390" > /sys/class/gpio/export
				echo "out" > /sys/class/gpio/gpio390/direction
				
				echo "1" > /sys/class/gpio/gpio394/value
		fi
		
		if [ "$diomode4" = "1" ]; then                                                                   
		                    
				echo "391" > /sys/class/gpio/export
				echo "out" > /sys/class/gpio/gpio391/direction
				
				echo "1" > /sys/class/gpio/gpio395/value
		fi
		sh /etc/init.d/initGPIO.sh start
		
elif echo "$board_name" | grep -qE "(IE44)"; then
	for i in 1 2
		do
					dioselect=$DIOSelect
					DIOMode=$DIOMode
			
			        di=$($di${i})
			        do=$(do${i})
					if [ "$DIOMode" = "0" ]
					then
								if [ ! -d "/sys/class/gpio/gpio${dioselect}" ]
						         then
							
										echo "$dioselect" > /sys/class/gpio/export
										#echo "out" > /sys/class/gpio/gpio${dioselect}/direction
										#echo "0" > /sys/class/gpio/gpio${dioselect}/value
								fi	
										echo "out" > /sys/class/gpio/gpio${dioselect}/direction
										echo "0" > /sys/class/gpio/gpio${dioselect}/value
								if [ ! -d "/sys/class/gpio/gpio${di}" ]
						         then	
										echo "$di" > /sys/class/gpio/export
										#echo "in" > /sys/class/gpio/gpio${di}/direction
								fi		
										echo "in" > /sys/class/gpio/gpio${di}/direction
							#fi		
						elif [ "$DIOMode" = "1" ]
						then
							if [ ! -d "/sys/class/gpio/gpio${dioselect}" ]
					         then
									echo "$dioselect" > /sys/class/gpio/export
									#echo "out" > /sys/class/gpio/gpio${dioselect}/direction
									#echo "1" > /sys/class/gpio/gpio${dioselect}/value
							fi
									echo "out" > /sys/class/gpio/gpio${dioselect}/direction
									echo "1" > /sys/class/gpio/gpio${dioselect}/value
							if [ ! -d "/sys/class/gpio/gpio${do}" ]
						    then	
								echo "$do" > /sys/class/gpio/export
								#echo "out" > /sys/class/gpio/gpio${do}/direction
							fi
								echo "out" > /sys/class/gpio/gpio${do}/direction
							
						fi
		done
		
		 /etc/init.d/initGPIO.sh start
		
		
else
	
	echo "DIOMode1=$DIOMode1"
	echo "DIOMode2=$DIOMode2"
	for i in 490 491 492 493
	do
		echo "$i" > /sys/class/gpio/export
		echo "out" > /sys/class/gpio/gpio${i}/direction
		echo "0" > /sys/class/gpio/gpio${i}/value
	done
		
	if [ "$DIOMode1" = "1" ]                                                                    
	then                      
			echo "484" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio484/direction
			
			echo "1" > /sys/class/gpio/gpio490/value
	fi
	
	if [ "$DIOMode2" = "1" ]                                                                    
	then                      
			echo "485" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio485/direction
			
			echo "1" > /sys/class/gpio/gpio491/value
	fi
	
	if [ "$DIOMode3" = "1" ]                                                                    
	then                      
			echo "486" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio486/direction
			
			echo "1" > /sys/class/gpio/gpio492/value
	fi
	
	if [ "$DIOMode4" = "1" ]                                                                    
	then                      
			echo "487" > /sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio487/direction
			
			echo "1" > /sys/class/gpio/gpio493/value
	fi
fi
			
	
	
	
	
	
	
	
	
	
	
	
	
