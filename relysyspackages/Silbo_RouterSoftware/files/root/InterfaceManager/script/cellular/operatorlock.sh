#!/bin/sh                                                                                                                                   

   . /lib/functions.sh

echo "$1"
ComPort="$1"

Operatorlockenable=$(uci get sysconfig.bandlock.operatorlockenable)

Enableoperator=$(uci get sysconfig.bandlock.enableoperator)

code=$(uci get sysconfig.bandlock.Code)

	x=0 
	c=0

if [ "$Operatorlockenable" = "auto" ] && [ "$Enableoperator" = "1" ]
then
 
  	c=0
  	x=0   
                                                                      
elif [ "$Operatorlockenable" = "manual" ] && [ "$Enableoperator" = "1" ]
then
 
  	c=2
  	x=1
 
elif [ "$Operatorlockenable" = "manual-auto" ] && [ "$Enableoperator" = "1" ]
then

       c=2
       x=4
fi



Setoperatorlock="/etc/gcom/setoperatorlock.gcom" 
                                                                                                                                                                                                                                                                                                                                                                                                                  
{                                                                                                                                                                                                                                                                                                                                                                                                                           
		echo "opengt"                                                                                                                                                                                                                                                                                                                                                                                                             
		echo -e "\tset com 115200n81"                                                                                                                                                                                                                                                                                                                                                                                             
		echo -e "\tset comecho off"                                                                                                                                                                                                                                                                                                                                                                                               
		echo -e "\tset senddelay 0.02"                                                                                                                                                                                                                                                                                                                                                                                            
		echo -e "\twaitquiet 0.2"                                                                                                                                                                                                                                                                                                                                                                                             
		echo -e "\tflash 0.1"                                                                                                                                                                                                                                                                                                                                                                                                     
		echo -e "\n"                                                                                                                                                                                                                                                                                                                                                                                                              
		echo ":start"                                                                                                                                                                                                                                                                                                                                                                                                             
		echo -e "\tsend \"at+cops=$x,$c,$code^m\""      
		echo -e "\tset senddelay 0.10"    
		echo -e "\tget 1 \"\" \$s"                                                                                                                                                                                                                                                                                                                                                                                                 
		echo -e "\tprint \$s"                                                                                                                                                                                                                                                                                                                                                                                                     
		echo -e "\n"                                                                                                                                                                                                                                                                                                                                                                                                              
		echo ":continue"                                                                                                                                                                                                                                                                                                                                                                                                          
		echo -e "\texit 0"                                                                                                                                                                                                                                                                                                                                                                                                        
		} > ${Setoperatorlock}                                                                                                                                                                                                                                                                                                                                                                                                          
		sleep 2                                                                                                                                                                                                                                                                                                                                                                                                                     

for i in 1 2 3                                                                                                                                                                                                                                                                                                                                                                                                              
do
Status=$(/usr/bin/gcom -d "$ComPort" -s /etc/gcom/setoperatorlock.gcom | tail -1)
Status=${Status:0:2}                                                  

if [ "$Status" = "OK" ]                                                                                                                       
then
echo "break"
break
else
echo "continue"
continue
fi
                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
done

