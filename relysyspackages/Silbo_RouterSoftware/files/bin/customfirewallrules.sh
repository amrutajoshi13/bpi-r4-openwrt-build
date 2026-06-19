#!/bin/sh

. /lib/functions.sh

FirewallUCIPath=/etc/config/customfirewall
firewalluserfilepath=/etc/firewall.user
NoOfSectionCount=0
res=0
ReadFirewallUCIConfig()
{
	config_load "$FirewallUCIPath"
	config_foreach FirewallConfigParameters redirect
}

FirewallConfigParameters()
{
    local FirewallConfigSection="$1"
    NoOfSectionCount=$((NoOfSectionCount + 1))
    config_get proto      "$FirewallConfigSection"   proto
    config_get src        "$FirewallConfigSection"   src
    config_get src_ip     "$FirewallConfigSection"   src_ip
    config_get src_port   "$FirewallConfigSection"   src_port
    config_get dest_ip    "$FirewallConfigSection"   dest_ip
    config_get dest_port  "$FirewallConfigSection"   dest_port
    config_get IP         "$FirewallConfigSection"   IP
    config_get port       "$FirewallConfigSection"   port
    config_get action     "$FirewallConfigSection"   action
   ForwardIPcameraInterface

}


ForwardIPcameraInterface()
{
  ###################################DNAT cases#######################################################################
        if [ "$action" = "dnat" ]
		then
		{
			# dest_ip and dest_port are present -- src_ip and src_port not present
			if [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ -z "$src_ip" ] && [ -z "$src_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
			        then
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP:$port"				    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
					then
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP"
					else
						res=1    
				    fi
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
			        then
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --dport $dest_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
					then
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --dport $dest_port -j DNAT --to-destination $IP"
					else
						res=1		
					fi

  				fi #end of tcpudp
  			# dest_ip and dest_port are present -- src_ip  present and src_port not present
  			elif [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ -z "$src_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
			        then
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP:$port"				    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
					then
					   echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP"
					   echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP"
					else
						 res=1
					fi  
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
			        then
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --dport $dest_port -j DNAT --to-destination $IP:$port"
  				    elif [ ! -z "$IP" ] && [ -z "$port" ]
					then
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --dport $dest_port -j DNAT --to-destination $IP"
  				    else
	  				    res=1
  				    fi
  				fi #end of tcpudp
  				
  			# dest_ip and dest_port are present -- src_ip not present and src_port present
  			elif [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ -z "$src_ip" ] && [ ! -z "$src_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
			        then
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"				    
				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
 						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
				    else
					    res=1
				    fi
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
			        then
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
  				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				       echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
				    else
				         res=1
				    fi
  				fi
  				
  				
	        # dest_ip and dest_port are present -- src_ip present and src_port present
			elif [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] 
		    then
			if [ "$proto" = "tcp udp" ]
		    then
		        Protocoltcp="tcp"
		        Protocoludp="udp"
		        if [ ! -z "$IP" ] && [ ! -z "$port" ]
			    then		        
					echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
				    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"				    
			  	elif [ ! -z "$IP" ] && [ -z "$port" ]
				then
				    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
				    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"				    
				else
					res=1
			    fi
			
			else
				 if [ ! -z "$IP" ] && [ ! -z "$port" ]
			    then		        
					echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
				elif [ ! -z "$IP" ] && [ -z "$port" ]
				then
					echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
				else
					res=1				
				fi
			fi
			
########################################################################################################################			
			# dest_ip and dest_port are not present	-- src_ip and src_port not present				
		    elif [ -z "$dest_ip" ] && [ -z "$dest_port" ] && [ -z "$src_ip" ] && [ -z "$src_port" ] 
			then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then		         
			        	echo "iptables -t nat -A PREROUTING -p $Protocoltcp -j DNAT --to-destination $IP:$port"
				        echo "iptables -t nat -A PREROUTING -p $Protocoludp -j DNAT --to-destination $IP:$port"				    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -p $Protocoltcp -j DNAT --to-destination $IP"
				        echo "iptables -t nat -A PREROUTING -p $Protocoludp -j DNAT --to-destination $IP"
				    else
					    res=1    
				    fi				
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then 				
						echo "iptables -t nat -A PREROUTING -p $proto -j DNAT --to-destination $IP:$port"
				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				    	echo "iptables -t nat -A PREROUTING -p $proto -j DNAT --to-destination $IP"
				    else
				    	res=1				    
  				    fi
  				fi
	  	   
	  	   # dest_ip and dest_port are not present	-- src_ip present and src_port not present				
		    elif [ -z "$dest_ip" ] && [ -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ -z "$src_port" ] 
			then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then 				
			        	echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp -j DNAT --to-destination $IP:$port"				    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp -j DNAT --to-destination $IP"
					 else
					 res=1   
				   fi
				
				else
				   if [ ! -z "$IP" ] && [ ! -z "$port" ]
				   then 				
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto -j DNAT --to-destination $IP:$port"
  				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto -j DNAT --to-destination $IP" 
				    else
				    res=1
				    fi  				
  				fi
	  	 
	  	    # dest_ip and dest_port are not present	-- src_ip not present and src_port present				
		    elif [ -z "$dest_ip" ] && [ -z "$dest_port" ] && [ -z "$src_ip" ] && [ ! -z "$src_port" ] 
			then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then 			        
						echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP:$port"				    
					  elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
				    	echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP" 
					    else
					    res=1
				   fi
				else
					 if [ ! -z "$IP" ] && [ ! -z "$port" ]
				     then 			        
						echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port -j DNAT --to-destination $IP:$port"
					 elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
						echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port -j DNAT --to-destination $IP"
				    else
					    res=1
				    fi							
  				fi
	  	   
	  	    # dest_ip and dest_port are not present	-- src_ip present and src_port present				
		    elif [ -z "$dest_ip" ] && [ -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] 
			then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then
			        	echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP:$port"				    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
				       echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP"
					   echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP"
					   else
					   res=1
				    fi
				else
					 if [ ! -z "$IP" ] && [ ! -z "$port" ]
				     then
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port -j DNAT --to-destination $IP"
				   else
					   res=1
				    fi		
  				fi
	  	   
#####################################################################################################################	 
	  	   #dest_ip present and dest_port not present	-- src_ip and src_port not present
	  		 elif [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] && [ -z "$src_ip" ] && [ -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then
			      		echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp -j DNAT --to-destination $IP:$port"		    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp -j DNAT --to-destination $IP" 
					else
						res=1      
					fi
				
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
				    	echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto -j DNAT --to-destination $IP"
				    else
					    res=1	
					fi
  				fi
	  		
	  	      #dest_ip present and dest_port not present	-- src_ip present and src_port not present
	  		 elif [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp -j DNAT --to-destination $IP:$port"		    
				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp -j DNAT --to-destination $IP"
					 else
						 res=1   
				    fi
				else
					 if [ ! -z "$IP" ] && [ ! -z "$port" ]
					 then
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto -j DNAT --to-destination $IP:$port"
					 elif [ ! -z "$IP" ] && [ -z "$port" ]
				     then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto -j DNAT --to-destination $IP" 	
					 else
						 res=1   
				     fi		
  				fi
	  		
	  		 #dest_ip present and dest_port not present	-- src_ip not present and src_port present
	  		 elif [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] && [ -z "$src_ip" ] && [ ! -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP:$port"		    
					 elif [ ! -z "$IP" ] && [ -z "$port" ]
				     then
				        echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP" 
					 else
						 res=1   
					fi
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --sport $src_port -j DNAT --to-destination $IP:$port"
				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				     then
				     echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --sport $src_port -j DNAT --to-destination $IP"
				    else
					    res=1 
				    fi		
  				fi
	  		
	  		 #dest_ip present and dest_port not present	-- src_ip present and src_port present
	  		 elif [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP:$port"		    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port -j DNAT --to-destination $IP"  
					 else
						 res=1   
				   fi
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port -j DNAT --to-destination $IP"
					else
						res=1    
					fi
  				fi
	  		
###################################################################################################################	  		
	  		#dest_ip not present and dest_port present	-- src_ip and src_port not present	
	  		 elif [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ -z "$src_ip" ] && [ -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP:$port"	    
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
				       	echo "iptables -t nat -A PREROUTING -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP" 
					else
						res=1    
				   fi
				else
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -p $proto --dport $dest_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -p $proto --dport $dest_port -j DNAT --to-destination $IP"
				    else
					    res=1
					fi
  				fi
	  			
	  		#dest_ip not present and dest_port present	-- src_ip present and src_port not present	
	  		 elif [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP:$port"	    
				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --dport $dest_port -j DNAT --to-destination $IP"
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --dport $dest_port -j DNAT --to-destination $IP"
				    else
					    res=1
				    fi
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --dport $dest_port -j DNAT --to-destination $IP:$port"
				    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --dport $dest_port -j DNAT --to-destination $IP"
				    else
					    res=1
				    fi		
  				fi
	  		
	  		#dest_ip not present and dest_port present	-- src_ip not present and src_port present	
	  		 elif [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ -z "$src_ip" ] && [ ! -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
			        	echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
					    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
				       echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
					   echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP" 
				   else
					   res=1
				    fi
				    
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP" 
				    else
					    res=1
					fi	
  				fi
	#*******************************************************************************************************  			
	  		#dest_ip not present and dest_port present	-- src_ip present and src_port present	
	  		 elif [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] && [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] 
			 then
			    if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"

					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then 
				        echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port --dport $dest_port -j DNAT --to-destination $IP"
					else
						res=1	
				    fi
				else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port --dport $dest_port -j DNAT --to-destination $IP" 
				    else
					    res=1	
					fi
  				fi
	  	   					    
		    fi 
		} >> "${firewalluserfilepath}"    
        fi
        
####################################### SNAT cases #############################################
        
        if [ "$action" = "snat" ]
        then
        {
			# src_ip and src_port are present -- dest_ip and dest_port not present
        	if [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] && [ -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port -j SNAT --to-source $IP:$port"
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then  
					     echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port -j SNAT --to-source $IP"
	                else
		                res=1    
	                fi 			   
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then  
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port -j SNAT --to-source $IP"  
				    else
					    res=1				   
				    fi		
			    fi			    
			    
			
			# src_ip and src_port are present -- dest_ip present and dest_port not present
        	elif [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port -j SNAT --to-source $IP"     
	                 else
		                 res=1   
                    fi
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port -j SNAT --to-source $IP"  
				    else
					    res=1	
					fi
			    fi
			
		    # src_ip and src_port are present -- dest_ip not present and dest_port present
        	elif [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] && [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then     
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
	                else
		                res=1    
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then     
				    	echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP"  
				    else
					    res=1	
					fi	
			    fi
			
			 # src_ip and src_port are present -- dest_ip present and dest_port present
        	elif [ ! -z "$src_ip" ] && [ ! -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then     
					     echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"   
	                else
		                res=1    
                    fi
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then     
				    	echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP"  
				    else
					    res=1	
					fi
			    fi
			
#####################################################################################################################			
			# src_ip and src_port are not present -- dest_ip and dest_port not present
			elif [ -z "$src_ip" ] && [ -z "$src_port" ] && [ -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -p $Protocoltcp -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp -j SNAT --to-source $IP:$port"
                    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then     
					    echo "iptables -t nat -A PREROUTING -p $Protocoltcp -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp -j SNAT --to-source $IP"
				    else
					    res=1
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -p $proto -j SNAT --to-source $IP:$port" 
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -p $proto -j SNAT --to-source $IP" 
				    else
					    res=1				    	 
				    fi		
			    fi
			
			# src_ip and src_port are not present -- dest_ip present and dest_port not present
			elif [ -z "$src_ip" ] && [ -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp -j SNAT --to-source $IP:$port"
                    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					     echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp -j SNAT --to-source $IP"
	                     echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp -j SNAT --to-source $IP"
                    else
	                    res=1
	                fi    
			   	else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto -j SNAT --to-source $IP"
				    else
					    res=1  
				    fi		
			    fi
			
			# src_ip and src_port are not present -- dest_ip not present and dest_port present
			elif [ -z "$src_ip" ] && [ -z "$src_port" ] && [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP"
                    else
	                    res=1
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -p $proto --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -p $proto --dport $dest_port -j SNAT --to-source $IP"
				    else
					    res=1  
					fi	
			    fi
			
			# src_ip and src_port are not present -- dest_ip present and dest_port present
			elif [ -z "$src_ip" ] && [ -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
		        	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					     echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP"
		                 echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP"
		            else
			            res=1     
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
					then 
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				    	echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --dport $dest_port -j SNAT --to-source $IP"  
			    	else
				    	res=1
					fi
			    fi
				
#################################################################################################################			
			# src_ip present and src_port not present  -- dest_ip and dest_port not present 
			elif [ ! -z "$src_ip" ] && [ -z "$src_port" ] && [ -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
				    if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then  
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				        echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp -j SNAT --to-source $IP"
					else
	                    res=1
                    fi
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then  
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto -j SNAT --to-source $IP:$port" 
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto -j SNAT --to-source $IP" 	
				    else
					   res=1
					fi 
			    fi
			
			# src_ip present and src_port not present  -- dest_ip present and dest_port not present 
			elif [ ! -z "$src_ip" ] && [ -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
				    if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp -j SNAT --to-source $IP" 
	                else
		                 res=1   
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				    		echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto -j SNAT --to-source $IP"  
		    		else
		    		res=1
					fi		
			    fi
		    
		    # src_ip present and src_port not present  -- dest_ip not present and dest_port present 
			elif [ ! -z "$src_ip" ] && [ -z "$src_port" ] && [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
		        	if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP"
                    else
	                    res=1
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				    	echo "iptables -t nat -A PREROUTING -s $src_ip -p $proto --dport $dest_port -j SNAT --to-source $IP"
			    	else
				    	res=1  
					fi
			    fi
				
			 # src_ip present and src_port not present  -- dest_ip present and dest_port present 
			elif [ ! -z "$src_ip" ] && [ -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				        echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoltcp --dport $dest_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $Protocoludp --dport $dest_port -j SNAT --to-source $IP"
	                else
		                res=1    
	                fi    
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -s $src_ip -d $dest_ip -p $proto --dport $dest_port -j SNAT --to-source $IP"  
					else
						res=1    
					fi			
			    fi
			
###################################################################################################################			
			# src_ip not present and src_port present  -- dest_ip and dest_port not present     
			elif [  -z "$src_ip" ] && [ ! -z "$src_port" ] && [ -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port -j SNAT --to-source $IP:$port"
                    elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
						echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port -j SNAT --to-source $IP"
                    else
	                    res=1
                    fi
			   	else
				   	if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port -j SNAT --to-source $IP"
				    else
					    res=1					     
					fi
			    fi
		  
		  # src_ip not present and src_port present  -- dest_ip present and dest_port not present     
			elif [  -z "$src_ip" ] && [ ! -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port -j SNAT --to-source $IP"  
	                else
		                res=1    
	                fi    
			   	else
					if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --sport $src_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --sport $src_port -j SNAT --to-source $IP"  	
				    else
					    res=1
					fi
			    fi
			    
		    # src_ip not present and src_port present  -- dest_ip not present and dest_port present     
			elif [  -z "$src_ip" ] && [ ! -z "$src_port" ] && [ -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				        echo "iptables -t nat -A PREROUTING -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
	                    echo "iptables -t nat -A PREROUTING -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
                    else
	                    res=1
                    fi
			   	else
			   	    if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"  
					elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP"  
				    else
					    res=1
					fi
			    fi
			    
			    # src_ip not present and src_port present  -- dest_ip present and dest_port present     
			elif [  -z "$src_ip" ] && [ ! -z "$src_port" ] && [ ! -z "$dest_ip" ] && [ ! -z "$dest_port" ] 
			then
				if [ "$proto" = "tcp udp" ]
			    then
			        Protocoltcp="tcp"
			        Protocoludp="udp"
			        if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"
	                elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
				       echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoltcp --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
	                   echo "iptables -t nat -A PREROUTING -d $dest_ip -p $Protocoludp --sport $src_port --dport $dest_port -j SNAT --to-source $IP" 
                   else
	                   res=1
                    fi
			   	else
				   	 if [ ! -z "$IP" ] && [ ! -z "$port" ]
				    then    
						echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP:$port"  
						elif [ ! -z "$IP" ] && [ -z "$port" ]
				    then
					    echo "iptables -t nat -A PREROUTING -d $dest_ip -p $proto --sport $src_port --dport $dest_port -j SNAT --to-source $IP"
				    else
					    res=1  
					fi
			    fi
			     	    			    
		   fi		    
		} >> "${firewalluserfilepath}"    
        fi
        
        
         
}

UpdatePortForwardingRules()
{
    ReadFirewallUCIConfig
}


sed -i '/iptables/d' "${firewalluserfilepath}"
UpdatePortForwardingRules

if [ "$res" -ne 0  ]
then
    echo "Failure : Custom firewall rule update" > /tmp/customfirewallres.txt
else
    echo "Success : Custom firewall rule update" > /tmp/customfirewallres.txt
fi  
 /etc/init.d/firewall restart 
 logger -t config -p customs.info "firewall configuration changed"

exit 0
