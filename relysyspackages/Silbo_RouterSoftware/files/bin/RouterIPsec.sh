#!/bin/sh

. /lib/functions.sh

IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)

   interfac=$(route -n | awk NR==3 | awk '{print $8}')                                                                                
   if [ "$interfac" = "eth0.4" ]                                                                                                    
   then                                                                                                                            
     uci set ipsec.general.interface="EWAN1"                                                                                        
   elif [ "$interfac" = "eth0.5" ]                                                                                                  
   then                                                                                                                            
      uci set ipsec.general.interface="EWAN2"                                                                                      
   elif [ "$interfac" = "3g-CWAN1" ]                                                                                                
   then                                                                                                                            
      uci set ipsec.general.interface="CWAN1"                                                                                      
   elif [ "$interfac" = "3g-CWAN2" ]                                                                                                
   then                                                                                                                            
      uci set ipsec.general.interface="CWAN2"                                                                                      
   elif [ "$interfac" = "3g-CWAN1_0" ]                                                                                              
   then                                                                                                                            
      uci set ipsec.general.interface="CWAN1_0"                                                                                    
   elif [ "$interfac" = "3g-CWAN1_1" ]                                                                                              
   then                                                                                                                            
      uci set ipsec.general.interface="CWAN1_1"                                                                                    
   elif [ "$interfac" = "usb0" ]                                                                                                    
   then                                                                                                                            
       if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]                                                            
       then                                                                                                                        
           uci set ipsec.general.interface="CWAN1"                                                                                  
       else                                                                                                                        
           simnum=$(cat /tmp/simnumfile)                                                                                            
           if [ "$simnum" = "1" ]                                                                                                  
           then                                                                                                                    
             uci set ipsec.general.interface="CWAN1_0"                                                                              
           else                                                                                                                    
             uci set ipsec.general.interface="CWAN1_1"                                                                              
           fi                                                                                                                      
       fi                                                                                                                          
   else                                                                                                                            
       if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]                                                            
       then                                                                                                                        
           uci set ipsec.general.interface="CWAN1"                                                                                  
       else                                                                                                                        
           simnum=$(cat /tmp/simnumfile)                                                                                            
           if [ "$simnum" = "1" ]                                                                                                  
           then                                                                                                                    
             uci set ipsec.general.interface="CWAN1_0"                                                                              
           else                                                                                                                    
             uci set ipsec.general.interface="CWAN1_1"                                                                              
           fi                                                                                                                      
         fi    
    fi                                                                                                                              
    uci commit ipsec                                                                                                                
    if [ "$IpsecEnable" = "1" ] ; then
   /etc/init.d/ipsec stop
   /bin/sleep 2                                                                                              
   /etc/init.d/ipsec start                                                                                                          
   /bin/sleep 4                                                                                                                    
   /usr/sbin/ipsec restart                                                                                                          
   fi  
exit 0
