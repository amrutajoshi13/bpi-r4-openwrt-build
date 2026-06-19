#!/bin/sh
. /lib/functions.sh

#HTTP Server Configuration
HTTPCfgDirPath="/root/SenderAppComponent/etc/Config"
HTTPconfigureCfgPath="${HTTPCfgDirPath}/HTTPSenderServerClientConfig"
HTTPTopicsCfgPath="${HTTPCfgDirPath}/HTTPSenderMosquittoClient"
httpEventfile="cloudconfig"
httpconfigureEventSection="cloudconfig"

#MQTT Configuration

MQTTCfgDirPath="/root/SenderAppComponent/etc/Config"
MQTTconfigureCfgPath="${MQTTCfgDirPath}/externalBrokerConfig"
MQTTExternalPath="${MQTTCfgDirPath}/externalTopics"
MQTTEventfile="cloudconfig"
MQTTconfigureEventSection="cloudconfig"
MQTTInternalTopics="${MQTTCfgDirPath}/internalTopics.cfg"
    rm -rf "${HTTPconfigureCfgPath}.cfg"	


UpdateHTTPCfg()
{
	
	HTTPEnable=$(uci get cloudconfig.cloudconfig.cloudprotocol)
	HTTPEnable1=$(uci get cloudconfig.cloudconfig.cloudprotocol2)
	EnableMQTTCommand=$(uci get cloudconfig.cloudconfig.EnableMQTTCommand)

   
	     httpenable=1
	     httpenable1=1
		echo "Updating HTTP application configuration "
	    echo "Updating '${HTTPconfigureCfgPath}.cfg' configuration"
	    config_load "$httpEventfile"
	    config_get  HTTPServerURL         		  "$httpconfigureEventSection"    HTTPServerURL
	    config_get  HTTPServerPort        		  "$httpconfigureEventSection"    HTTPServerPort
	    config_get httpauthenable        		  "$httpconfigureEventSection" httpauthenable
	    config_get  username              		  "$httpconfigureEventSection"    username
	    config_get  password              		  "$httpconfigureEventSection"    password
	    config_get serverresponsevalidationenable "$httpconfigureEventSection" serverresponsevalidationenable
	    config_get serverresponsestring 		  "$httpconfigureEventSection" serverresponsestring
	    config_get HTTPMethod 					  "$httpconfigureEventSection" HTTPMethod
	    config_get EnableSecondaryServer 		  "$httpconfigureEventSection" EnableSecondaryServer
	    config_get entertoken					  "$httpconfigureEventSection" entertoken
	    config_get ContentType 					  "$httpconfigureEventSection" ContentType
	    config_get EnableBoolString               "$httpconfigureEventSection" EnableBoolString
	    config_get EnableCustomChar               "$httpconfigureEventSection" EnableCustomChar
	    config_get contentType               	  "$httpconfigureEventSection" contentType
	  
	    config_get  HTTPServerURL2         		  "$httpconfigureEventSection"    HTTPServerURL2
	    config_get  HTTPServerPort2        		  "$httpconfigureEventSection"    HTTPServerPort2
	    config_get httpauthenable2       		  "$httpconfigureEventSection" httpauthenable2
	    config_get  username2              		  "$httpconfigureEventSection"    username2
	    config_get  password2              		  "$httpconfigureEventSection"    password2
	    config_get serverresponsevalidationenable2 "$httpconfigureEventSection" serverresponsevalidationenable2
	    config_get serverresponsestring2 		  "$httpconfigureEventSection" serverresponsestring2
	    config_get HTTPMethod2 					  "$httpconfigureEventSection" HTTPMethod2
	    config_get EnableSecondaryServer2 		  "$httpconfigureEventSection" EnableSecondaryServer2
	    config_get entertoken2					  "$httpconfigureEventSection" entertoken2
	    config_get ContentType 					  "$httpconfigureEventSection" ContentType
	    config_get EnableBoolString               "$httpconfigureEventSection" EnableBoolString
	    config_get EnableCustomChar               "$httpconfigureEventSection" EnableCustomChar
	    config_get contentType2                   "$httpconfigureEventSection" contentType2
	    EnableJson=$(uci get Jsonconfig.Type.configType)
	    
	   
	     
	     {
	if [ "$HTTPEnable" = "http" ] && [ "$HTTPEnable1" = "http" ]; then
          echo "httpenable_1=$httpenable"
	        if [[ -z "$HTTPServerPort" ]]; then
	             echo "HTTPServerURL_1=\"$HTTPServerURL\""
	        else
		        echo "HTTPServerURL_1=\"$HTTPServerURL:$HTTPServerPort\""
	        fi
	        echo "httpauthenable_1=$httpauthenable"
	       
	        echo "ContentType_1=\"$contentType\""
	        
	        if [ "$httpauthenable" = "1" ]                                                                       
	        then 
		        echo "username_1=\"$username\""
		        echo "password_1=\"$password\""
	        fi
	        if [ "$httpauthenable" = "2" ]                                                                       
	        then 
		        echo "BearerToken_1=\"$entertoken\""     
	        fi
	    
	        echo "serverresponsevalidationenable_1=$serverresponsevalidationenable"
	        if [ "$serverresponsevalidationenable" = "1" ]                                                                       
	        then 
	            #rm  /root/serverresponsestring
		        echo "serverresponsestring=\"$serverresponsestring\""  
		    fi
		   
		    echo "HTTPMethod_1=$HTTPMethod"
		    echo "EnableSecondaryServer_1=$EnableSecondaryServer"
		    echo "ServerDNSLookupTime_1=60"
		    echo "ServerMaximumTransferTimeout_1=60"
	        
	    
	    
	        echo "httpenable_3=$httpenable1"
	        if [[ -z "$HTTPServerPort2" ]]; then
	             echo "HTTPServerURL_3=\"$HTTPServerURL2\""
	        else
		        echo "HTTPServerURL_3=\"$HTTPServerURL2:$HTTPServerPort2\""
	        fi
	        echo "httpauthenable_3=$httpauthenable2"

	        echo "ContentType_3=\"$contentType2\""

	        
	        if [ "$httpauthenable2" = "1" ]                                                                       
	        then 
		        echo "username_3=\"$username2\""
		        echo "password_3=\"$password2\""
	        fi
	        if [ "$httpauthenable2" = "2" ]                                                                       
	        then 
		        echo "BearerToken_3=\"$entertoken2\""     
	        fi
	    
	        echo "serverresponsevalidationenable_3=$serverresponsevalidationenable2"
	        if [ "$serverresponsevalidationenable2" = "1" ]                                                                       
	        then 
	            #rm  /root/serverresponsestring
		        echo "serverresponsestring2=\"$serverresponsestring2\"" 
		    fi
		   
		    echo "HTTPMethod_3=$HTTPMethod"
		    echo "EnableSecondaryServer_3=$EnableSecondaryServer"
		    echo "ServerDNSLookupTime_3=60"
		    echo "ServerMaximumTransferTimeout_3=60"
		  	    

elif [ "$HTTPEnable" = "http" ]; then

        echo "httpenable_1=$httpenable"
	        if [[ -z "$HTTPServerPort" ]]; then
	             echo "HTTPServerURL_1=\"$HTTPServerURL\""
	        else
		        echo "HTTPServerURL_1=\"$HTTPServerURL:$HTTPServerPort\""
	        fi
	        echo "httpauthenable_1=$httpauthenable"

	        echo "ContentType_1=\"$contentType\""
	        
	        if [ "$httpauthenable" = "1" ]                                                                       
	        then 
		        echo "username_1=\"$username\""
		        echo "password_1=\"$password\""
	        fi
	        if [ "$httpauthenable" = "2" ]                                                                       
	        then 
		        echo "BearerToken_1=\"$entertoken\""     
	        fi
	    
	        echo "serverresponsevalidationenable_1=$serverresponsevalidationenable"
	        if [ "$serverresponsevalidationenable" = "1" ]                                                                       
	        then 
	            #rm  /root/serverresponsestring
		        #echo "$serverresponsestring=\"$serverresponsestring\""  >> /root/serverresponsestring
		        echo "serverresponsestring=\"$serverresponsestring\"" 
		          
		    fi
		   
		    echo "HTTPMethod_1=$HTTPMethod"
		    echo "EnableSecondaryServer_1=$EnableSecondaryServer"
		    echo "ServerDNSLookupTime_1=60"
		    echo "ServerMaximumTransferTimeout_1=60"
	
elif [ "$HTTPEnable1" = "http" ]; then
 
	        echo "httpenable_3=$httpenable1"
	        if [[ -z "$HTTPServerPort2" ]]; then
	             echo "HTTPServerURL_3=\"$HTTPServerURL2\""
	        else
		        echo "HTTPServerURL_3=\"$HTTPServerURL2:$HTTPServerPort2\""
	        fi
	        echo "httpauthenable_3=$httpauthenable2"
	        echo "ContentType_3=\"$contentType2\""
	        
	        if [ "$httpauthenable2" = "1" ]                                                                       
	        then 
		        echo "username_3=\"$username2\""
		        echo "password_3=\"$password2\""
	        fi
	        if [ "$httpauthenable2" = "2" ]                                                                       
	        then 
		        echo "BearerToken_3=\"$entertoken2\""     
	        fi
	    
	        echo "serverresponsevalidationenable_3=$serverresponsevalidationenable2"
	        if [ "$serverresponsevalidationenable2" = "1" ]                                                                       
	        then 
	            #rm  /root/serverresponsestring
		        #echo "$serverresponsestring2"  >> /root/serverresponsestring
		        echo "serverresponsestring2=\"$serverresponsestring2\""  

		    fi
		   
		    echo "HTTPMethod_3=$HTTPMethod"
		    echo "EnableSecondaryServer_3=$EnableSecondaryServer"
		    echo "ServerDNSLookupTime_3=60"
		    echo "ServerMaximumTransferTimeout_3=60"
		
		else
			echo ""
		fi    
	    } > "${HTTPconfigureCfgPath}.cfg"   
	
		sed -i '/FirstServerdataMode/d' /root/SenderAppComponent/etc/Config/HTTPSenderMosquittoClient.cfg
		sed -i '/SecondServerDataMode/d' /root/SenderAppComponent/etc/Config/HTTPSenderMosquittoClient.cfg


	if [ "$HTTPEnable" = "http" ] ; then   
	     echo "FirstServerdataMode=1" >> "${HTTPTopicsCfgPath}.cfg"   
	     fi
	     
	if [ "$HTTPEnable1" = "http" ] ; then   
	     echo "SecondServerDataMode=1" >> "${HTTPTopicsCfgPath}.cfg"   
	     fi
	     
	if [ "$HTTPEnable" = "mqtt" ] ; then   
	     echo "FirstServerdataMode=3" >> "${HTTPTopicsCfgPath}.cfg"   
	     fi
	     
	if [ "$HTTPEnable1" = "mqtt" ] ; then   
	
	     echo "SecondServerDataMode=3" >> "${HTTPTopicsCfgPath}.cfg"   
	     fi
	     

	    
	    #if [ "$EnableMQTTCommand" = "1" ]
	    #then
	        #sed -i 's/MQTT/HTTP/g' "$MQTTInternalTopics"
	    #else    
	        #sed -i 's/HTTP/MQTT/g' "$MQTTInternalTopics"
	           
	    #fi       

   
}




UpdateHTTPCfg
