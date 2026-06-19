#!/bin/sh
. /lib/functions.sh

. /usr/local/bin/Testscripts/testscriptconfig.cfg
. /root/RS485UtilityComponent/etc/Config/RS485utilityConfigTestScript.cfg

IEEE754Conversion()
{
    
	value=$1   
    sign=$(( (value >> 31) & 1))
    val=0
    num=0

    base=1
    for i in $(seq 23 30)
    do
		val=$(((value >> $i) & 1))
		num=$(($num+($val*$base)))
		base=$(($base*2))
	done
	
	base=0.5
	
	for i in $(seq 22 -1 0)
	do
		val=$(((value >> $i) & 1))

		mant=$(awk "BEGIN {printf \"%.10f\", $mant + ($val * $base)}")
        base=$(awk "BEGIN {printf \"%.10f\", $base * 0.5}")		
	
	done
	
		
	exp=$(($num-127))
	result=1
	result=$(echo "(1.0 + $mant) * (2 ^ $exp)" | bc -l)
	if [ "$sign" -eq 1 ]; then
		 result=$(echo "scale=10; $result * -1" | bc)
	fi
	#echo "result:$result"
	if [ $(echo "$result > $rs485minvolt" | bc -l) -eq 1 ] && [ $(echo "$result < $rs485maxvolt" | bc -l) -eq 1 ]; then
		echo "$result"
	else
		echo "$result is not in the given range"
	fi
 }

retry_count=0
 
while [ "$retry_count" -lt 5 ]; do

    rs485_out=$(/root/RS485UtilityComponent/RS485UtilityTestScript "$slaveid_rs485")
	sleep 1
    if echo "$rs485_out" | grep -q "RS485 Modbus read failed"; then

        retry_count=$((retry_count + 1))

        if [ "$retry_count" -eq 5 ]; then
            echo "Reached maximum retries. Exiting loop."
            break
        fi

        sleep 1
    else
        reg_output=$(echo "$rs485_out" | grep -E "Register [0-9]+\s*=\s*[0-9a-fA-F]+" | sed 's/^[[:space:]]*//')

        echo "$reg_output"
        parsedOut=$(echo "$reg_output" | awk '/Register [0-9]+\s*=\s*[0-9a-fA-F]+/ {gsub(/^[ \t]+|[ \t]+$/, "", $NF); printf "%s,",$NF} END {if (NR) {print ""} else print ""}')      
        numValues=$(echo "$parsedOut" | tr -cd ',' | wc -c)
 
        if [ "$numValues" -gt 1 ]; then

            break
        fi
    fi

done
echo "parsedOut: $parsedOut"

for i in $(seq 1 2 $NumberOfRegisters)
do
	reg=$(echo "$parsedOut" | cut -d "," -f $i)
	length1=$(echo -n "$reg" | wc -c)
	echo "length1:$length1"
	if [ $length1 -lt 4 ]; then
		zeros_to_add1=$((4 - length1))
		reg="${reg}$(printf '0%.0s' $(seq 1 $zeros_to_add1))"
	fi
	echo "element1:$reg"
	i=$((i+1))
	
	val1=$(echo "$parsedOut" | cut -d "," -f $i)
	length=$(echo -n "$val1" | wc -c)
	echo "length:$length"
	if [ $length -lt 4 ]; then
		zeros_to_add=$((4 - length))
		val1="${val1}$(printf '0%.0s' $(seq 1 $zeros_to_add))"
	fi
	echo "element2:$val1"
	
	if [ -n "$val1" ];then	
		merged_hex="${reg}${val1}"	 
	else		
		merged_hex=$reg
	fi

	echo "merged value:$merged_hex"
	merged_dec=$(printf "%d\n" 0x${merged_hex})	
	IEEE754Value=$(IEEE754Conversion "$merged_dec")
	echo "IEEE 754 Value:$IEEE754Value"
	
done

