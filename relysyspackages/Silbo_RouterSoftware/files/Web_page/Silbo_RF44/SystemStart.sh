#!/bin/sh

. /lib/functions.sh

swlaninterface="SW_LAN"
laninterface="LAN"
lan1interface="LAN1"
lan2interface="LAN2"
lan3interface="LAN3"
lan4interface="LAN4"
ethwaninterface="EWAN"
ethwan2interface="EWAN"
cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"
wifiap="ra0"
wifiap1="ra1"
wifista="WIFI_WAN"
lanifname="eth0"
wificonfigname="WIFI_WAN"

#InternetOverLAN="1" 
#InternetOverWifi="1"

#IPV6 Variables 
cellularwan6sim1interface="wan6c1"
cellularwan6sim2interface="wan6c2"

ReadSystemConfigFile()
{
        config_load "$SystemConfigFile"        
        config_get PortMode sysconfig portmode
        config_get EthernetProtocolPortlan sysconfig EthernetProtocolPortlan
        config_get EthernetServerDHCPIPPortlan sysconfig EthernetServerDHCPIPPortlan
        config_get EthernetServerDHCPrangePortlan sysconfig EthernetServerDHCPrangePortlan
        config_get EthernetServerDHCPlimitPortlan sysconfig EthernetServerDHCPlimitPortlan
        config_get EthernetServerStaticIPPortlan sysconfig EthernetServerStaticIPPortlan
        config_get PortInternetOverLan sysconfig portinternetoverlan
        config_get EthernetServerDHCPNetmaskPortLan sysconfig EthernetServerDHCPNetmaskPortlan
        config_get EthernetServerStaticNetmaskPortLan sysconfig EthernetServerStaticNetmaskPortlan
        config_get EthernetProtocolPortwan sysconfig   EthernetProtocolPortwan
        config_get EthernetClientDHCPGatewayPortwan sysconfig EthernetClientDHCPGatewayPortwan
        config_get EthernetClientStaticIPPortwan sysconfig EthernetClientStaticIPPortwan
        config_get EthernetClientStaticGatewayPortwan sysconfig EthernetClientStaticGatewayPortwan
        config_get EthernetClientnetmaskPortwan sysconfig EthernetClientnetmaskPortwan
        config_get EthernetServerStaticDnsServer sysconfig EthernetServerStaticDnsServer
        config_get EthernetServerStaticDnsServerNo1 sysconfig EthernetServerStaticDnsServerNo1
        config_get EthernetServerStaticDnsServerNo2 sysconfig EthernetServerStaticDnsServerNo2
		config_get EthernetClientPppoeUsername sysconfig EthernetClientPppoeUsername
		config_get EthernetClientPppoePassword sysconfig EthernetClientPppoePassword
		config_get EthernetClientPppoeAccessConcentrator sysconfig EthernetClientPppoeAccessConcentrator
		config_get EthernetClientPppoeServiceName sysconfig EthernetClientPppoeServiceName    
		config_get EthernetClientPptpServerAddress sysconfig EthernetClientPptpServerAddress
		config_get EthernetClientPptpUsername sysconfig EthernetClientPptpUsername
		config_get EthernetClientPptpPassword sysconfig EthernetClientPptpPassword
		config_get EthernetClientPptpMppeEncryption sysconfig EthernetClientPptpMppeEncryption
		config_get EthernetClientPptpDNSServerSource sysconfig EthernetClientPptpDNSServerSource
		config_get EthernetClientPptpNumberOfDNSServer sysconfig EthernetClientPptpNumberOfDNSServer
		config_get EthernetClientPptpDnsServerNo1 sysconfig EthernetClientPptpDnsServerNo1
		config_get EthernetClientPptpDnsServerNo2 sysconfig EthernetClientPptpDnsServerNo2
    
            
              
        config_get CellularOperationModelocal sysconfig CellularOperationMode
        config_get CellularModem1 sysconfig cellularmodem1
        config_get Protocol1EC20 sysconfig protocol1EC20
        config_get Manufacturerlocal1 sysconfig Manufacturer1
        config_get Model1 sysconfig model1
        config_get PortType1 sysconfig porttype1
        config_get VendorId1 sysconfig vendorid1
        config_get ProductId1 sysconfig productid1
        config_get DataPort1 sysconfig dataport1
        config_get ComPort1 sysconfig comport1
        config_get SmsPort1 sysconfig smsport1
        config_get SmsEnable1 sysconfig smsenable1
        config_get SmsCenterNumber1 sysconfig smscenternumber1
        config_get DeviceId1 sysconfig smsdeviceid
        config_get ApiKey1 sysconfig smsapikey
        config_get Manufacturerlocal2 sysconfig Manufacturer2
        config_get Model2 sysconfig model2
        config_get PortType2 sysconfig porttype2
        config_get VendorId2 sysconfig vendorid2
        config_get ProductId2 sysconfig productid2
        config_get DataPort2 sysconfig dataport2
        config_get ComPort2 sysconfig comport2
        config_get SmsPort2 sysconfig smsport2
        config_get SmsEnable2 sysconfig smsenable2
        config_get SmsCenterNumber2 sysconfig smscenternumber2
        config_get DeviceId2 sysconfig deviceid2
        config_get ApiKey2 sysconfig apikey2
        config_get MonitorEnable1 sysconfig monitorenable1
        config_get QueryModematAnalytics1 sysconfig querymodematanalytics1
        config_get DataTestEnable1 sysconfig datatestenable1
        config_get PingTestEnable1 sysconfig pingtestenable1
        config_get PingIp1 sysconfig pingip1
        config_get MonitorEnable2 sysconfig monitorenable2
        config_get QueryModematAnalytics2 sysconfig querymodematanalytics2
        config_get DataTestEnable2 sysconfig datatestenable2
        config_get PingTestEnable2 sysconfig pingtestenable2
        config_get PingIp2 sysconfig pingip2
        config_get DataEnable1 sysconfig dataenable
        config_get Cellular1 sysconfig cellular
        config_get Service1 sysconfig service
        config_get Apn1 sysconfig apn
        config_get Pdp1 sysconfig pdp
        config_get PinCode1 sysconfig pincode
        config_get UserName1 sysconfig username
        config_get Password1 sysconfig password
        config_get Auth1 sysconfig auth
        config_get DataEnable2 sysconfig dataenable2
        config_get Cellular2 sysconfig cellular2
        config_get Sim2Service sysconfig sim2service
        config_get Sim2Apn sysconfig sim2apn
        config_get Sim2Pdp sysconfig sim2pdp
        config_get Sim2PinCode sysconfig sim2pincode
        config_get Sim2UserName sysconfig sim2username
        config_get Sim2Password sysconfig sim2password
        config_get Sim2Auth sysconfig sim2auth
        config_get EnableCellular sysconfig enablecellular
        config_get UsbBusPath1 sysconfig usbbuspath1
        config_get UsbBusPath2 sysconfig usbbuspath2
        config_get ActionInterval1 sysconfig actioninterval1
        config_get ActionInterval2 sysconfig actioninterval2
        config_get Protocol1 sysconfig protocol1
        config_get Protocol2 sysconfig protocol2
       # config_get SmsResponseSenderEnable1 sysconfig smsresponsesenderenable1
      #  config_get SmsResponseSenderEnable2 sysconfig smsresponsesenderenable2
        config_get SmsResponseServerEnable1 sysconfig smsresponseserverenable
       # config_get SmsResponseServerEnable2 sysconfig smsresponseserverenable2
        config_get SmsServerNumber1 sysconfig smsservernumber1
        config_get SmsServerNumber2 sysconfig smsservernumber2
        config_get SmsServerNumber3 sysconfig smsservernumber3
        config_get SmsServerNumber4 sysconfig smsservernumber4
        config_get SmsServerNumber5 sysconfig smsservernumber5
        
        config_get WifiDevice sysconfig wifidevice
        config_get TxPower sysconfig TxPower
        config_get WifiDevicesChannel sysconfig wifideviceschannel
        config_get CountryCode sysconfig CountryCode
        config_get Wifi1Enable sysconfig wifi1enable
        config_get wifi1mode sysconfig wifi1mode
        config_get Radio0StationEnable sysconfig radio0stationenable
        config_get Wifi1Ssid sysconfig wifi1ssid
        config_get Wifi1Key sysconfig wifi1key
        config_get Wifi1Mode sysconfig wifi1mode
        config_get Wifi1StaMode sysconfig wifi1stamode
        config_get Wifi1Authentication sysconfig wifi1authentication
        config_get Wifi1Encryption sysconfig wifi1encryption
        config_get Wifi1StaSsid sysconfig wifi1stassid
        config_get Wifi1StaEncryption sysconfig wifi1staencryption
        config_get Wifi1StaKey sysconfig wifi1stakey
        config_get Wifi2Enable sysconfig wifi2enable
        config_get Wifi2Ssid sysconfig wifi2ssid
        config_get Wifi2Key sysconfig wifi2key
        config_get Wifi2Mode sysconfig wifi2mode
        config_get InternetOverWifi sysconfig internetoverwifi
        config_get LanWifiBridgeEnable sysconfig lanwifibridgeenable
        config_get Radio0DhcpIp sysconfig radio0dhcpip
        config_get Radio0DHCPRange sysconfig Radio0DHCPrange
        config_get Radio0DHCPLimit sysconfig Radio0DHCPlimit
        config_get ScheduledOnOff sysconfig ScheduledOnOff
        config_get channelwidth sysconfig channelwidth
		config_get guestwifissid sysconfig guestwifissid
		config_get guestwifiencryption sysconfig guestwifiencryption
		config_get guestwifikey sysconfig guestwifikey
		config_get guestwifi1authentication sysconfig guestwifi1authentication
		config_get guestwifi1encryption sysconfig guestwifi1encryption
		config_get guestradio0dhcpip sysconfig guestradio0dhcpip
		config_get guestRadio0DHCPrange sysconfig guestRadio0DHCPrange
		config_get guestRadio0DHCPlimit sysconfig guestRadio0DHCPlimit
		config_get wifi1authentication sysconfig wifi1authentication
		config_get wifi1encryption sysconfig wifi1encryption
		config_get guestwifienable sysconfig guestwifienable
		config_get wifi1authentication sysconfig wifi1authentication
		config_get wifi1encryption sysconfig wifi1encryption
		config_get guestwifi1authentication sysconfig guestwifi1authentication
		config_get guestwifi1encryption sysconfig guestwifi1encryption
		config_get wifiServerStaticDnsServer sysconfig wifiServerStaticDnsServer
		config_get WifiServerStaticDnsServerNo1 sysconfig WifiServerStaticDnsServerNo1
		config_get WifiServerStaticDnsServerNo2 sysconfig WifiServerStaticDnsServerNo2
		config_get SimSwitch sysconfig simswitch
		config_get PDP1 sysconfig pdp
		config_get PDP2 sysconfig sim2pdp
}

ReadMwanConfigFile()
{ 
   config_load "$MwanConfigFile"
   config_get NameEwan1 "$ethwaninterface" name
   config_get EwanPriority "$ethwaninterface" wanpriority
   config_get EwanTrackIp1 "$ethwaninterface" trackIp1
   config_get EwanTrackIp2 "$ethwaninterface" trackIp2
   config_get EwanTrackIp3 "$ethwaninterface" trackIp3
   config_get EwanTrackIp4 "$ethwaninterface" trackIp4
   config_get EwanReliability "$ethwaninterface" reliability 
   config_get EwanCount "$ethwaninterface" count
   config_get EwanUp "$ethwaninterface" up
   config_get EwanDown "$ethwaninterface" down
   config_get EwanValidtrackip "$ethwaninterface" validtrackip
	
   config_get NameCwan1 "$cellularwan1interface" name
   config_get Cwan1Priority "$cellularwan1interface" wanpriority
   config_get Cwan1TrackIp1 "$cellularwan1interface" trackIp1
   config_get Cwan1TrackIp2 "$cellularwan1interface" trackIp2
   config_get Cwan1TrackIp3 "$cellularwan1interface" trackIp3
   config_get Cwan1TrackIp4 "$cellularwan1interface" trackIp4
   config_get Cwan1Reliability "$cellularwan1interface" reliability
   config_get Cwan1Count "$cellularwan1interface" count
   config_get Cwan1Up "$cellularwan1interface" up
   config_get Cwan1Down "$cellularwan1interface" down
   config_get Cwan1validtrackip "$cellularwan1interface" validtrackip
   
   config_get NameCwan2 "$cellularwan2interface" name
   config_get Cwan2Priority "$cellularwan2interface" wanpriority
   config_get Cwan2TrackIp1 "$cellularwan2interface" trackIp1
   config_get Cwan2TrackIp2 "$cellularwan2interface" trackIp2
   config_get Cwan2TrackIp3 "$cellularwan2interface" trackIp3
   config_get Cwan2TrackIp4 "$cellularwan2interface" trackIp4
   
   config_get NameCwansim1 "$cellularwan1sim1interface" name
   config_get Cwan1sim1Priority "$cellularwan1sim1interface" wanpriority
   config_get Cwan1sim1TrackIp1 "$cellularwan1sim1interface" trackIp1
   config_get Cwan1sim1TrackIp2 "$cellularwan1sim1interface" trackIp2
   config_get Cwan1sim1TrackIp3 "$cellularwan1sim1interface" trackIp3
   config_get Cwan1sim1TrackIp4 "$cellularwan1sim1interface" trackIp4
   
   config_get NameCwansim2 "$cellularwan1sim2interface" name
   config_get Cwan1sim2Priority "$cellularwan1sim2interface" wanpriority
   config_get Cwan1sim2TrackIp1 "$cellularwan1sim2interface" trackIp1
   config_get Cwan1sim2TrackIp2 "$cellularwan1sim2interface" trackIp2
   config_get Cwan1sim2TrackIp3 "$cellularwan1sim2interface" trackIp3
   config_get Cwan1sim2TrackIp4 "$cellularwan1sim2interface" trackIp4
   
   	#IPV6 variables
	   config_get NameCwan6sim1 "$cellularwan6sim1interface" name
   config_get Cwan6sim1Priority "$cellularwan6sim1interface" wanpriority
   config_get Cwan6sim1TrackIp1 "$cellularwan6sim1interface" trackIp1
   config_get Cwan6sim1TrackIp2 "$cellularwan6sim1interface" trackIp2
   config_get Cwan6sim1TrackIp3 "$cellularwan6sim1interface" trackIp3
   config_get Cwan6sim1TrackIp4 "$cellularwan6sim1interface" trackIp4
   config_get Cwan6sim1Reliability "$cellularwan6sim1interface" reliability
   config_get Cwan6sim1Count "$cellularwan6sim1interface" count
   config_get Cwan6sim1Up "$cellularwan6sim1interface" up
   config_get Cwan6sim1Down "$cellularwan6sim1interface" down
   config_get Cwan6sim1validtrackip "$cellularwan6sim1interface" validtrackip
   
   config_get NameCwan6sim2 "$cellularwan6sim2interface" name
   config_get Cwan6sim2Priority "$cellularwan6sim2interface" wanpriority
   config_get Cwan6sim2TrackIp1 "$cellularwan6sim2interface" trackIp1
   config_get Cwan6sim2TrackIp2 "$cellularwan6sim2interface" trackIp2
   config_get Cwan6sim2TrackIp3 "$cellularwan6sim2interface" trackIp3
   config_get Cwan6sim2TrackIp4 "$cellularwan6sim2interface" trackIp4
   config_get Cwan6sim2Reliability "$cellularwan6sim2interface" reliability
   config_get Cwan6sim2Count "$cellularwan6sim2interface" count
   config_get Cwan6sim2Up "$cellularwan6sim2interface" up
   config_get Cwan6sim2Down "$cellularwan6sim2interface" down
   config_get Cwan6sim2validtrackip "$cellularwan6sim2interface" validtrackip
	  
		config_get NameWifiWan "$wifista" name
		config_get WifiWanPriority "$wifista" wanpriority
		config_get WifiWanTrackIp1 "$wifista" trackIp1
		config_get WifiWanTrackIp2 "$wifista" trackIp2
		config_get WifiWanTrackIp3 "$wifista" trackIp3
		config_get WifiWanTrackIp4 "$wifista" trackIp4
		config_get WifiWanReliability "$wifista" reliability
		config_get WifiWanCount "$wifista" count
		config_get WifiWanUp "$wifista" up
		config_get WifiWanDown "$wifista" down
		config_get check_quality "$wifista" check_quality
		config_get failure_latency "$wifista" failure_latency
		config_get recovery_latency "$wifista" recovery_latency
		config_get failure_loss "$wifista" failure_loss
		config_get recovery_loss "$wifista" recovery_loss
		config_get WifiWanvalidtrackip "$wifista" validtrackip
}

UpdateMwanConfig()
{
	uci delete mwan3."${ethwaninterface}" > /dev/null 2>&1
	uci delete mwan3."${ethwan2interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan1interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan2interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan3interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan1sim1interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan1sim2interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan6sim1interface}" > /dev/null 2>&1
	uci delete mwan3."${cellularwan6sim2interface}" > /dev/null 2>&1
	uci delete mwan3."${wifista}" > /dev/null 2>&1
	uci delete mwan3.ewan_only > /dev/null 2>&1
	uci delete mwan3.ewan2_only > /dev/null 2>&1
	uci delete mwan3.cwan1_only > /dev/null 2>&1
	uci delete mwan3.cwan2_only > /dev/null 2>&1
	uci delete mwan3.cwan3_only > /dev/null 2>&1
	uci delete mwan3.cwan1sim1_only > /dev/null 2>&1
	uci delete mwan3.cwan1sim2_only > /dev/null 2>&1
	uci delete mwan3.cwan6sim1_only > /dev/null 2>&1
	uci delete mwan3.cwan6sim2_only > /dev/null 2>&1
	uci delete mwan3.wifiwan_only > /dev/null 2>&1
	uci delete mwan3.balanced > /dev/null 2>&1
	uci delete mwan3.PPTP > /dev/null 2>&1
	uci delete mwan3.l2tp > /dev/null 2>&1
	uci set mwan3.balanced=policy
       
    if [ "$PortMode" = "EWAN" ]
	then
	   uci delete mwan3.ewan_m10_w1 > /dev/null 2>&1
	   
	   uci set mwan3."${ethwaninterface}"=interface
	   uci set mwan3."${ethwaninterface}".enabled="1"
	    if [ "$EwanValidtrackip" =  "1" ]
	   then 
	    uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp1"
	   fi
	    if [ "$EwanValidtrackip" =  "2" ]
	   then 
	    uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp1"
	    uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp2"
	   fi
	   if [ "$EwanValidtrackip" =  "3" ]
	   then 
	    uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp1"
	    uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp2"
	    uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp3"
	   fi
	   if [ "$EwanValidtrackip" =  "4" ]
	   then 
       uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp1"
       uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp2"
       uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp3"
       uci add_list mwan3."${ethwaninterface}".track_ip="$EwanTrackIp4"
       fi
       uci set mwan3."${ethwaninterface}".family="ipv4"
	   uci set mwan3."${ethwaninterface}".reliability="$EwanReliability"
	   uci set mwan3."${ethwaninterface}".count="$EwanCount"
	   uci set mwan3."${ethwaninterface}".timeout="2"
	   uci set mwan3."${ethwaninterface}".down="$EwanDown"
	   uci set mwan3."${ethwaninterface}".up="$EwanUp"
	   
	   uci set mwan3.ewan_m10_w1=member
	   uci set mwan3.ewan_m10_w1.interface="${ethwaninterface}"
	   uci set mwan3.ewan_m10_w1.metric="$EwanPriority"
	   uci set mwan3.ewan_m10_w1.weight="$EwanPriority"
	   
	   uci set mwan3.ewan_only=policy
	   uci add_list mwan3.ewan_only.use_member="ewan_m10_w1"
	   uci set mwan3.ewan_only.last_resort="default"
	   
	   uci add_list mwan3.balanced.use_member="ewan_m10_w1"
	   
	   if [ "$EthernetProtocolPortwan" = "pptp" ]
	    then
	        uci delete mwan3.pptp_m00_w0 > /dev/null 2>&1
			uci set mwan3.PPTP=interface
			uci set mwan3.PPTP.enabled="1"
			uci add_list mwan3.PPTP.track_ip="$EwanTrackIp1"
			uci add_list mwan3.PPTP.track_ip="$EwanTrackIp2"
			uci set mwan3.PPTP.family="ipv4"
			uci set mwan3.PPTP.reliability="2"
			uci set mwan3.PPTP.count="5"
			uci set mwan3.PPTP.timeout="2"
			uci set mwan3.PPTP.down="1"
			uci set mwan3.PPTP.up="1"
	   
			uci set mwan3.pptp_m00_w0=member
			uci set mwan3.pptp_m00_w0.interface="PPTP"
			uci set mwan3.pptp_m00_w0.metric="0"
			uci set mwan3.pptp_m00_w0.weight="0"
	     
			uci add_list mwan3.balanced.use_member="pptp_m00_w0"
		fi
		
		if [ "$EthernetProtocolPortwan" = "l2tp" ]
	    then
	    uci delete mwan3.l2tp_m00_w0 > /dev/null 2>&1
			uci set mwan3.l2tp=interface
			uci set mwan3.l2tp.enabled="1"
			uci add_list mwan3.l2tp.track_ip="$EwanTrackIp1"
			uci add_list mwan3.l2tp.track_ip="$EwanTrackIp2"
			uci set mwan3.l2tp.family="ipv4"
			uci set mwan3.l2tp.reliability="2"
			uci set mwan3.l2tp.count="5"
			uci set mwan3.l2tp.timeout="2"
			uci set mwan3.l2tp.down="1"
			uci set mwan3.l2tp.up="1"
	   
			uci set mwan3.l2tp_m00_w0=member
			uci set mwan3.l2tp_m00_w0.interface="l2tp"
			uci set mwan3.l2tp_m00_w0.metric="0"
			uci set mwan3.l2tp_m00_w0.weight="0"
	     
			uci add_list mwan3.balanced.use_member="l2tp_m00_w0"
		fi
	fi
		 
	 #~ else
	   #~ uci delete mwan3.ewan1_m10_w1 > /dev/null 2>&1
	   #~ uci delete mwan3.ewan2_m10_w1 > /dev/null 2>&1
	 #~ fi
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then
		   uci delete mwan3.cwan1sim1_m10_w1 > /dev/null 2>&1
		   uci delete mwan3.cwan1sim2_m10_w1 > /dev/null 2>&1
		   
		   uci set mwan3."${cellularwan1interface}"=interface
		   uci set mwan3."${cellularwan1interface}".enabled="1"
		   uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
		   uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
		   uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
		   uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp4"
		   uci set mwan3."${cellularwan1interface}".family="ipv4"
		   uci set mwan3."${cellularwan1interface}".reliability="2"
		   uci set mwan3."${cellularwan1interface}".count="5"
		   uci set mwan3."${cellularwan1interface}".timeout="1"
		   uci set mwan3."${cellularwan1interface}".interval="5"
		   uci set mwan3."${cellularwan1interface}".down="1"
		   uci set mwan3."${cellularwan1interface}".up="1"

		   uci set mwan3."${cellularwan2interface}"=interface
		   uci set mwan3."${cellularwan2interface}".enabled="1"
		   uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp1"
		   uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp2"
		   uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp3"
		   uci add_list mwan3."${cellularwan2interface}".track_ip="$Cwan2TrackIp4"      
		   uci set mwan3."${cellularwan2interface}".family="ipv4"
		   uci set mwan3."${cellularwan2interface}".reliability="2"
		   uci set mwan3."${cellularwan2interface}".count="5"
		   uci set mwan3."${cellularwan2interface}".timeout="2"
		   uci set mwan3."${cellularwan2interface}".interval="5"
		   uci set mwan3."${cellularwan2interface}".down="1"
		   uci set mwan3."${cellularwan2interface}".up="1"
		   
			uci set mwan3.cwan1_m10_w1=member
			uci set mwan3.cwan1_m10_w1.interface="${cellularwan1interface}"
			uci set mwan3.cwan1_m10_w1.metric="$Cwan1Priority"
			uci set mwan3.cwan1_m10_w1.weight="$Cwan1Priority"

			uci set mwan3.cwan2_m10_w1=member
			uci set mwan3.cwan2_m10_w1.interface="${cellularwan2interface}"
			uci set mwan3.cwan2_m10_w1.metric="$Cwan2Priority"
			uci set mwan3.cwan2_m10_w1.weight="$Cwan2Priority"
			
			uci set mwan3.cwan1_only=policy
			uci add_list mwan3.cwan1_only.use_member="cwan1_m10_w1"
			uci set mwan3.cwan1_only.last_resort="default"

			uci set mwan3.cwan2_only=policy
			uci add_list mwan3.cwan2_only.use_member="cwan2_m10_w1"
			uci set mwan3.cwan2_only.last_resort="default"

			uci add_list mwan3.balanced.use_member="cwan1_m10_w1"
			uci add_list mwan3.balanced.use_member="cwan2_m10_w1"
		elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci delete mwan3.cwan1_m10_w1 > /dev/null 2>&1
		   uci delete mwan3.cwan2_m10_w1 > /dev/null 2>&1
		   
		   uci set mwan3."${cellularwan1sim1interface}"=interface
		   uci set mwan3."${cellularwan1sim1interface}".enabled="1"
		   uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp1"
		   uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp2"
		   uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp3"
		   uci add_list mwan3."${cellularwan1sim1interface}".track_ip="$Cwan1sim1TrackIp4"
		   uci set mwan3."${cellularwan1sim1interface}".family="ipv4"
		   uci set mwan3."${cellularwan1sim1interface}".reliability="3"
		   uci set mwan3."${cellularwan1sim1interface}".count="3"
		   uci set mwan3."${cellularwan1sim1interface}".timeout="2"
		   uci set mwan3."${cellularwan1sim1interface}".interval="5"
		   uci set mwan3."${cellularwan1sim1interface}".down="1"
		   uci set mwan3."${cellularwan1sim1interface}".up="1"

		   uci set mwan3."${cellularwan1sim2interface}"=interface
		   uci set mwan3."${cellularwan1sim2interface}".enabled="1"
		   uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp1"
		   uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp2"
		   uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp3"
		   uci add_list mwan3."${cellularwan1sim2interface}".track_ip="$Cwan1sim2TrackIp4"      
		   uci set mwan3."${cellularwan1sim2interface}".family="ipv4"
		   uci set mwan3."${cellularwan1sim2interface}".reliability="3"
		   uci set mwan3."${cellularwan1sim2interface}".count="3"
		   uci set mwan3."${cellularwan1sim2interface}".timeout="1"
		   uci set mwan3."${cellularwan1sim2interface}".interval="5"
		   uci set mwan3."${cellularwan1sim2interface}".down="1"
		   uci set mwan3."${cellularwan1sim2interface}".up="1"
		   
		   uci set mwan3.cwan1sim1_m10_w1=member
		   uci set mwan3.cwan1sim1_m10_w1.interface="${cellularwan1sim1interface}"
		   uci set mwan3.cwan1sim1_m10_w1.metric="$Cwan1sim1Priority"
		   uci set mwan3.cwan1sim1_m10_w1.weight="$Cwan1sim1Priority"
		   
		   uci set mwan3.cwan1sim2_m10_w1=member
		   uci set mwan3.cwan1sim2_m10_w1.interface="${cellularwan1sim2interface}"
		   uci set mwan3.cwan1sim2_m10_w1.metric="$Cwan1sim2Priority"
		   uci set mwan3.cwan1sim2_m10_w1.weight="$Cwan1sim2Priority"
		   
			uci set mwan3.cwan1sim1_only=policy
			uci add_list mwan3.cwan1sim1_only.use_member="cwan1sim1_m10_w1"
			uci set mwan3.cwan1sim1_only.last_resort="default"
			
			uci set mwan3.cwan1sim2_only=policy
			uci add_list mwan3.cwan1sim2_only.use_member="cwan1sim2_m10_w1"
			uci set mwan3.cwan1sim2_only.last_resort="default"
			
			uci add_list mwan3.balanced.use_member="cwan1sim1_m10_w1"
			uci add_list mwan3.balanced.use_member="cwan1sim2_m10_w1"
			
		 else
		   uci delete mwan3.cwan1sim1_m10_w1 > /dev/null 2>&1
		   uci delete mwan3.cwan1sim2_m10_w1 > /dev/null 2>&1  
			uci delete mwan3.cwan6sim1_m10_w1 > /dev/null 2>&1     
		   uci delete mwan3.cwan2_m10_w1 > /dev/null 2>&1
			if [ "$PDP1" = "IPV4" ]  || [ "$PDP1" = "IPV4V6" ]
			then 
			   uci set mwan3."${cellularwan1interface}"=interface
			   uci set mwan3."${cellularwan1interface}".enabled="1"
				if [ "$Cwan1validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
				fi
				if [ "$Cwan1validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
				fi
				if [ "$Cwan1validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
				fi
				if [ "$Cwan1validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp1"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp2"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp3"
					uci add_list mwan3."${cellularwan1interface}".track_ip="$Cwan1TrackIp4" 
				fi
				uci set mwan3."${cellularwan1interface}".family="ipv4"
				uci set mwan3."${cellularwan1interface}".reliability="$Cwan1Reliability"
				uci set mwan3."${cellularwan1interface}".count="$Cwan1Count"
				uci set mwan3."${cellularwan1interface}".timeout="1"
				uci set mwan3."${cellularwan1interface}".interval="5"
				uci set mwan3."${cellularwan1interface}".down="$Cwan1Down"
				uci set mwan3."${cellularwan1interface}".up="$Cwan1Up"

				uci set mwan3.cwan1_m10_w1=member
				uci set mwan3.cwan1_m10_w1.interface="${cellularwan1interface}"
				uci set mwan3.cwan1_m10_w1.metric="$Cwan1Priority"
				uci set mwan3.cwan1_m10_w1.weight="$Cwan1Priority"
	
				uci set mwan3.cwan1_only=policy
				uci add_list mwan3.cwan1_only.use_member="cwan1_m10_w1"
				uci set mwan3.cwan1_only.last_resort="default"
				
				uci add_list mwan3.balanced.use_member="cwan1_m10_w1"
			fi
		fi
	  
	  #IPV6 update for sssm			
			if [ "$PDP1" = "IPV6" ]  
			then 
				uci set mwan3."${cellularwan6sim1interface}"=interface
				uci set mwan3."${cellularwan6sim1interface}".enabled="1"
				if [ "$Cwan6sim1validtrackip" = "1" ]
				then
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp1"
				fi
				if [ "$Cwan6sim1validtrackip" = "2" ]
				then
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp1"
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp2"
				fi
				if [ "$Cwan6sim1validtrackip" = "3" ]
				then
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp1"
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp2"
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp3"
				fi
				if [ "$Cwan6sim1validtrackip" = "4" ]
				then
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp1"
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp2"
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp3"
					uci add_list mwan3."${cellularwan6sim1interface}".track_ip="$Cwan6sim1TrackIp4"
				fi
					uci set mwan3."${cellularwan6sim1interface}".family="ipv6"
					uci set mwan3."${cellularwan6sim1interface}".reliability="$Cwan6sim1Reliability"
					uci set mwan3."${cellularwan6sim1interface}".count="$Cwan6sim1Count"
					uci set mwan3."${cellularwan6sim1interface}".timeout="1"
					uci set mwan3."${cellularwan6sim1interface}".interval="5"
					uci set mwan3."${cellularwan6sim1interface}".down="$Cwan6sim1Down"
					uci set mwan3."${cellularwan6sim1interface}".up="$Cwan6sim1Up"
   				uci set mwan3.cwan6sim1_m10_w1=member
				uci set mwan3.cwan6sim1_m10_w1.interface="${cellularwan6sim1interface}"
				uci set mwan3.cwan6sim1_m10_w1.metric="$Cwan6sim1Priority"
                				
				uci set mwan3.cwan6sim1_only=policy
				uci add_list mwan3.cwan6sim1_only.use_member="cwan6sim1_m10_w1"
				uci set mwan3.cwan6sim1_only.last_resort="default"
				uci add_list mwan3.balanced.use_member="cwan6sim1_m10_w1"
			fi        
	else
	 	uci delete mwan3.cwan1sim1_m10_w1 > /dev/null 2>&1
		uci delete mwan3.cwan1sim2_m10_w1 > /dev/null 2>&1
		uci delete mwan3.cwan1_m10_w1 > /dev/null 2>&1
		uci delete mwan3.cwan2_m10_w1 > /dev/null 2>&1
		uci delete mwan3."${cellularwan1interface}"
		uci delete mwan3."${cellularwan1sim1interface}"
		uci delete mwan3."${cellularwan1sim2interface}"
		uci delete mwan3."${cellularwan2interface}"
	fi
	
		if [ "$Wifi1Enable" = "0" ]
		then 
			uci delete mwan3.wifiwan_m10_w1 > /dev/null 2>&1
		else
		   if [ "$Wifi1Mode" = "sta" ] ||  [ "$Wifi1Mode" = "apsta" ]
		   then
			   uci set mwan3."${wifista}"=interface
			   uci set mwan3."${wifista}".enabled="1"
			if [ "$WifiWanvalidtrackip" = "1" ]
			then
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp1"
			fi
			if [ "$WifiWanvalidtrackip" = "2" ]
			then
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp1"
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp2"
			fi
			if [ "$WifiWanvalidtrackip" = "3" ]
			then
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp1"
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp2"
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp3"
			fi
			if [ "$WifiWanvalidtrackip" = "4" ]
			then
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp1"
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp2"
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp3"
				uci add_list mwan3."${wifista}".track_ip="$WifiWanTrackIp4" 
			fi
			   uci set mwan3."${wifista}".family="ipv4"
			   uci set mwan3."${wifista}".reliability="$WifiWanReliability"
			   uci set mwan3."${wifista}".count="$WifiWanCount"
			   uci set mwan3."${wifista}".down="$WifiWanDown"
			   uci set mwan3."${wifista}".up="$WifiWanUp"
			   uci set mwan3."${wifista}".check_quality="$check_quality"
			   uci set mwan3."${wifista}".failure_latency="$failure_latency"
			   uci set mwan3."${wifista}".recovery_latency="$recovery_latency"
			   uci set mwan3."${wifista}".failure_loss="$failure_loss"
			   uci set mwan3."${wifista}".recovery_loss="$recovery_loss"
			   
		 
			   uci set mwan3.wifiwan_m10_w1=member
			   uci set mwan3.wifiwan_m10_w1.interface="${wifista}"
			   uci set mwan3.wifiwan_m10_w1.metric="$WifiWanPriority"
			   uci set mwan3.wifiwan_m10_w1.weight="$WifiWanPriority"
			   
			   uci set mwan3.wifiwan_only=policy
			   uci add_list mwan3.wifiwan_only.use_member="wifiwan_m10_w1"
			   uci set mwan3.wifiwan_only.last_resort="default"
			  
			   uci add_list mwan3.balanced.use_member="wifiwan_m10_w1"
			else
			  uci delete mwan3.wifiwan_m10_w1 > /dev/null 2>&1
					  uci delete mwan3."${wifista}"

			fi
		fi

	uci commit mwan3
}

UpdateWirelessConfig()
{
	    pid=$(pgrep -f "/root/InterfaceManager/script/Wifi_udhcpcmonitor.sh")
	    kill -9 $pid
		uci set wireless.ra0.country="$CountryCode"
		uci set wireless.ra0.channel="$WifiDevicesChannel"
		txpower=$(grep -w "TxPower" ${wirelessdatfile})        
		txpower_replace="TxPower=$TxPower"
		sed -i "s/${txpower}/${txpower_replace}/" "$wirelessdatfile"
		wmmenable=$(grep -w "WmmCapable" ${wirelessdatfile})        
		wmmenable_replace="WmmCapable=$WmmEnable"
		sed -i "s/${wmmenable}/${wmmenable_replace}/" "$wirelessdatfile"
		sed -i '/ScheduledWifiOff.sh/d' /etc/crontabs/root
		sed -i '/ScheduledWifiOn.sh/d' /etc/crontabs/root
		countrycode=$(grep -w "CountryCode" ${wirelessdatfile})        
		countrycode_replace="CountryCode=$CountryCode"
		sed -i "s/${countrycode}/${countrycode_replace}/" "$wirelessdatfile"
		ht_bw=$(grep -w "HT_BW" ${wirelessdatfile})        
		ht_bw_replace="HT_BW=$channelwidth"
		sed -i "s/${ht_bw}/${ht_bw_replace}/" "$wirelessdatfile" 
		channel=$(grep -w "Channel" ${wirelessdatfile})        
		Channel_replace="Channel=$WifiDevicesChannel"
		sed -i "s/${channel}/${Channel_replace}/" "$wirelessdatfile"
		if [ "$Wifi1Enable" = "0" ]
		then 
		   uci set wireless.ap.disabled="1"
		   uci set wireless.sta.disabled="1"
		   uci delete network."${wifiap}" > /dev/null 2>&1
		   uci delete network."${wifista}" > /dev/null 2>&1
		   uci delete network."${wifiap1}" > /dev/null 2>&1
		else
			  if [ "$Wifi1Mode" = "ap" ]
			  then
				  ifdown apcli0
				  	hidessid=$(grep -w "HideSSID" ${wirelessdatfile})        
					hidessid_replace="HideSSID=0"
					sed -i "s/${hidessid}/${hidessid_replace}/" "$wirelessdatfile"
				  uci delete  network."${wifiap}" > /dev/null 2>&1
				  uci delete  network."${wifista}" > /dev/null 2>&1
				  uci delete  network."${wifiap1}" > /dev/null 2>&1
				  uci set wireless.sta.disabled="1"
				  uci set wireless.ap.disabled="0"
				  uci set wireless.ap.ssid="$Wifi1Ssid"
				  uci set wireless.ap.key="$Wifi1Key"
				  uci set wireless.ap.encryption="$Wifi1Encryption"
				  uci set network."${wifiap}"=interface
				  uci set network."${wifiap}".ipaddr="$Radio0DhcpIp"
				  uci set network."${wifiap}".netmask="255.255.255.0"
				  uci set network."${wifiap}".proto="static"
				  uci set network."${wifiap}".ifname="ra0"
				  uci set dhcp."${wifiap}".start="$Radio0DHCPRange"
				  uci set dhcp."${wifiap}".limit="$Radio0DHCPLimit"
				  ssid=$(grep -w "SSID1" ${wirelessdatfile})        
				  ssid_replace="SSID1=$Wifi1Ssid"
				  sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"
				  wpapsk1=$(grep -w "WPAPSK1" ${wirelessdatfile})        
				  wpapsk1_replace="WPAPSK1=$Wifi1Key"
				  sed -i "s/${wpapsk1}/${wpapsk1_replace}/" "$wirelessdatfile"
				  uci delete network.wan > /dev/null 2>&1
					  if [ "$guestwifienable" = "1" ]
					  then
							authmode=$(grep -w "AuthMode" ${wirelessdatfile})        
							authmode_replace="AuthMode=$wifi1authentication;$guestwifi1authentication"
							sed -i "s/${authmode}/${authmode_replace}/" "$wirelessdatfile"
							
							encryption=$(grep -w "EncrypType" ${wirelessdatfile})        
							encrypt_replace="EncrypType=$wifi1encryption;$guestwifi1encryption"
							sed -i "s/${encryption}/${encrypt_replace}/" "$wirelessdatfile"
					  else 
							#bssidnum=$(grep -w "BssidNum" ${wirelessdatfile})        
							#bssidnum_replace="BssidNum=1"
							#sed -i "s/${bssidnum}/${bssidnum_replace}/" "$wirelessdatfile"
							
							authmode=$(grep -w "AuthMode" ${wirelessdatfile})        
							authmode_replace="AuthMode=$wifi1authentication"
							sed -i "s/${authmode}/${authmode_replace}/" "$wirelessdatfile"
							
							encryption=$(grep -w "EncrypType" ${wirelessdatfile})        
							encrypt_replace="EncrypType=$wifi1encryption"
							sed -i "s/${encryption}/${encrypt_replace}/" "$wirelessdatfile"           
					  fi
					
				fi       
			

	
				  if [ "$Wifi1Mode" = "sta" ]
				  then
				      /root/InterfaceManager/script/Wifi_udhcpcmonitor.sh &			  		
					  iwpriv ra0 set HideSSID=1
					  iwpriv ra1 set HideSSID=1
					  hidessid=$(grep -w "HideSSID" ${wirelessdatfile})        
						hidessid_replace="HideSSID=1"
						sed -i "s/${hidessid}/${hidessid_replace}/" "$wirelessdatfile"
					  uci delete  network."${wifiap1}" > /dev/null 2>&1
					  uci set wireless.sta.disabled="0"
					  uci set wireless.sta.ssid="$Wifi1StaSsid"
					  uci set wireless.sta.key="$Wifi1StaKey"
					  uci set wireless.sta.encryption="$Wifi1StaEncryption"
					  uci set network.WIFI_WAN=interface
					  uci set network.WIFI_WAN.proto="dhcp"
					  uci set network.WIFI_WAN.metric="$WifiWanPriority"
					  uci set network.WIFI_WAN.ifname="apcli0"
					 
				  fi
		  
				  if [ "$guestwifienable" = "1" ]
				  then
						uci set network."${wifiap1}"=interface
						uci set network."${wifiap1}".ipaddr="$guestradio0dhcpip"
						uci set network."${wifiap1}".netmask="255.255.255.0"
						uci set network."${wifiap1}".proto="static"
						uci set network."${wifiap1}".ifname="ra1"
						uci set dhcp."${wifiap1}".start="$guestRadio0DHCPrange"
						uci set dhcp."${wifiap1}".limit="$guestRadio0DHCPlimit"
								
						ssid2=$(grep -w "SSID2" ${wirelessdatfile})        
						ssid2_replace="SSID2=$guestwifissid"
						sed -i "s/${ssid2}/${ssid2_replace}/" "$wirelessdatfile"
						
						wpapsk2=$(grep -w "WPAPSK2" ${wirelessdatfile})        
						wpapsk2_replace="WPAPSK2=$guestwifikey"
						sed -i "s/${wpapsk2}/${wpapsk2_replace}/" "$wirelessdatfile"
					else 
						uci delete  network.ra1 > /dev/null 2>&1
				  fi
		  
				  if [ "$Wifi1Mode" = "apsta" ]
				  then
						/root/InterfaceManager/script/Wifi_udhcpcmonitor.sh &			  		
						ssid=$(grep -w "SSID1" ${wirelessdatfile})        
						ssid_replace="SSID1=$Wifi1Ssid"
						sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"
						uci delete network."${wifiap1}" > /dev/null 2>&1
						ssid2=$(grep -w "SSID2" ${wirelessdatfile})        
						ssid2_replace="SSID2="
						sed -i "s/${ssid2}/${ssid2_replace}/" "$wirelessdatfile"
						hidessid=$(grep -w "HideSSID" ${wirelessdatfile})        
						hidessid_replace="HideSSID=0"
						sed -i "s/${hidessid}/${hidessid_replace}/" "$wirelessdatfile"
					  uci set wireless.ap.disabled="0"
					  uci set wireless.ap.ssid="$Wifi1Ssid"
					  uci set wireless.ap.key="$Wifi1Key"
					  uci set wireless.ap.encryption="$Wifi1Encryption"
					  uci set network."${wifiap}"=interface
					  uci set network."${wifiap}".ipaddr="$Radio0DhcpIp"
					  uci set network."${wifiap}".netmask="255.255.255.0"
					  uci set network."${wifiap}".proto="static"
					  uci set network."${wifiap}".ifname="ra0"
					  uci set dhcp."${wifiap}".start="$Radio0DHCPRange"
					  uci set dhcp."${wifiap}".limit="$Radio0DHCPLimit"
					  uci set wireless.sta.disabled="0"
					  uci set wireless.sta.ssid="$Wifi1StaSsid"
					  uci set wireless.sta.key="$Wifi1StaKey"
					  uci set wireless.sta.encryption="$Wifi1StaEncryption"
					  uci set network.WIFI_WAN=interface
					  uci set network.WIFI_WAN.proto="dhcp"
					  uci set network.WIFI_WAN.metric="$WifiWanPriority"
					  uci set network.WIFI_WAN.ifname="apcli0"           
				  fi
		fi
	uci commit wireless
	uci commit network
	 uci commit dhcp
}

UpdateScheduledWifiOnOff()
{   	
	CronReadListValuesMaintenanceReboot()
	{
		TmpVal=""
		local value="$1"
		local VarName="$2"
		TmpVal="$(eval echo '$'ListValue"$VarName")"
		eval ListValue"$VarName"="${TmpVal}${value},"
	
	}
	
	if [ "$Wifi1Mode" = "ap" ] || [ "$Wifi1Mode" = "apsta" ]
	then		
	
		if [ "$ScheduledOnOff" = "1" ]
		then
			config_load "$SystemConfigFile"             
			config_list_foreach "wirelessconfig" fromHours CronReadListValuesMaintenanceReboot fromHours
			config_list_foreach "wirelessconfig" fromMinutes CronReadListValuesMaintenanceReboot fromMinutes
			config_list_foreach "wirelessconfig" toHours CronReadListValuesMaintenanceReboot toHours
			config_list_foreach "wirelessconfig" toMinutes CronReadListValuesMaintenanceReboot toMinutes
			config_list_foreach "wirelessconfig" DayOfMonth CronReadListValuesMaintenanceReboot DayOfMonth
			config_list_foreach "wirelessconfig" Month CronReadListValuesMaintenanceReboot Month
			config_list_foreach "wirelessconfig" DayOfWeek CronReadListValuesMaintenanceReboot DayOfWeek
				
			ListValfromHours=$(echo "$ListValuefromHours" | sed s'/,$//')
			ListValfromMinutes=$(echo "$ListValuefromMinutes" | sed s'/,$//')
			ListValtoHours=$(echo "$ListValuetoHours" | sed s'/,$//')
			ListValtoMinutes=$(echo "$ListValuetoMinutes" | sed s'/,$//')
			ListValDayOfWeek=$(echo "$ListValueDayOfWeek" | sed s'/,$//')
			ListValDayOfMonth=$(echo "$ListValueDayOfMonth" | sed s'/,$//')
			ListValMonth=$(echo "$ListValueMonth" | sed s'/,$//')
			echo "$ListValfromMinutes $ListValfromHours * * $ListValDayOfWeek /root/InterfaceManager/script/wireless/ScheduledWifiOff.sh" >> /etc/crontabs/root
			echo "$ListValtoMinutes $ListValtoHours * * $ListValDayOfWeek /root/InterfaceManager/script/wireless/ScheduledWifiOn.sh" >> /etc/crontabs/root
		elif [ "$ScheduledOnOff" = "0" ];then 
			sed -i '/ScheduledWifiOff.sh/d' /etc/crontabs/root
			sed -i '/ScheduledWifiOn.sh/d' /etc/crontabs/root	
		fi
	fi
}

UpdateNetworkConfig()
{
	uci delete dhcp.LAN > /dev/null 2>&1
		uci delete network.EWAN > /dev/null 2>&1
		uci delete network.LAN > /dev/null 2>&1
		uci delete network.PPTP  > /dev/null 2>&1 
		uci delete network.l2tp  > /dev/null 2>&1 
	if [ "$PortMode" = "LAN" ] 
	then  
	   	if [ "$EthernetProtocolPortlan" = "static" ]
	    then
	        uci delete dhcp.LAN > /dev/null 2>&1
			uci set network.LAN=interface
			uci set network.LAN.ifname=eth0
			uci set network.LAN.proto="static"
			uci set network.LAN.ipaddr="$EthernetServerStaticIPPortlan"
			uci set network.LAN.netmask="$EthernetServerStaticNetmaskPortLan"
			if [ $EthernetServerStaticDnsServer = "1" ]
			then 
			    uci add_list network.LAN.dns="$EthernetServerStaticDnsServerNo1"
		    elif [ $EthernetServerStaticDnsServer = "2" ]
			then 
				uci add_list network.LAN.dns="$EthernetServerStaticDnsServerNo1"
			    uci add_list network.LAN.dns="$EthernetServerStaticDnsServerNo2"	
			fi
		else
		    uci set network.LAN=interface
		    uci set network.LAN.ifname=eth0
			uci set network.LAN.proto="static"
			uci set network.LAN.ipaddr="$EthernetServerDHCPIPPortlan"
			uci set network.LAN.netmask="$EthernetServerDHCPNetmaskPortLan"
			uci set dhcp.LAN=dhcp
			uci set	dhcp.LAN.interface=LAN
			uci set	dhcp.LAN.start="$EthernetServerDHCPrangePortlan"
			uci set	dhcp.LAN.limit="$EthernetServerDHCPlimitPortlan"
			uci set	dhcp.LAN.leasetime="12h"
			uci set	dhcp.LAN.dhcpv6="disabled"
			uci set	dhcp.LAN.ra="disabled"
			if [ $EthernetServerStaticDnsServer = "1" ]
			then 
			    uci add_list network.LAN.dns="$EthernetServerStaticDnsServerNo1"
		    elif [ $EthernetServerStaticDnsServer = "2" ]
			then 
				uci add_list network.LAN.dns="$EthernetServerStaticDnsServerNo1"
			    uci add_list network.LAN.dns="$EthernetServerStaticDnsServerNo2"	
			fi
        fi
      elif [ "$PortMode" = "EWAN" ] 
      then
            if [ "$EthernetProtocolPortwan" = "static" ]
			then
				uci set network.EWAN=interface
				uci set network.EWAN.ifname=eth0
				uci set network.EWAN.proto="static"
				uci set network.EWAN.ipaddr="$EthernetClientStaticIPPortwan"
				uci set network.EWAN.gateway="$EthernetClientStaticGatewayPortwan"
				uci set network.EWAN.metric="$EwanPriority"
				uci set network.EWAN.netmask="$EthernetClientnetmaskPortwan"
			elif [ "$EthernetProtocolPortwan" = "pppoe" ]                                               
			then
				uci set network."${ethwaninterface}"=interface                         
	            uci set network."${ethwaninterface}".ifname="$lanifname"  
				uci set network."${ethwaninterface}".proto="pppoe"
				uci set network."${ethwaninterface}".username="$EthernetClientPppoeUsername"
	            uci set network."${ethwaninterface}".password="$EthernetClientPppoePassword"              
	            uci set network."${ethwaninterface}".ac="$EthernetClientPppoeAccessConcentrator"              
	            uci set network."${ethwaninterface}".service="$EthernetClientPppoeServiceName"              
			elif [ "$EthernetProtocolPortwan" = "pptp" ]
			then
				uci set network."${ethwaninterface}"=interface
			    uci set network."${ethwaninterface}".ifname="$lanifname"
				uci set network."${ethwaninterface}".proto="dhcp"
				uci set network."${ethwaninterface}".metric="$EwanPriority"
	            
	            uci set network.PPTP=interface
	            uci set network.PPTP.proto="pptp"
	            uci set network.PPTP.ifname="pptp-PPTP"
	            uci set network.PPTP.server="$EthernetClientPptpServerAddress"
	            uci set network.PPTP.username="$EthernetClientPptpUsername"
	            uci set network.PPTP.password="$EthernetClientPptpPassword"
	            uci set network.PPTP.require_mppe="$EthernetClientPptpMppeEncryption"
	            uci set network.PPTP.mppe_stateless="$EthernetClientPptpMppeEncryption"
	            uci set network.PPTP.keepalive="30 60"
	            uci set network.PPTP.metric='0'.
	            uci set network.PPTP.gateway="$EthernetClientStaticGatewayPortwan"

				if [ "$EthernetClientPptpDNSServerSource" = "1" ]
				then 
					uci add_list network.PPTP.dns="$EthernetClientPptpDnsServerNo1"
					if [ "$EthernetClientPptpNumberOfDNSServer" = "2" ]
					then
						uci add_list network.PPTP.dns="$EthernetClientPptpDnsServerNo2"
					fi
				fi
			elif [ "$EthernetProtocolPortwan" = "l2tp" ]
			then
				uci set network."${ethwaninterface}"=interface
			    uci set network."${ethwaninterface}".ifname="$lanifname"
				uci set network."${ethwaninterface}".proto="dhcp"
				uci set network."${ethwaninterface}".metric="$EwanPriority"
	            uci set network."${ethwaninterface}".macaddr="$Port5MacId"
	            
	            uci set network.l2tp=interface
	            uci set network.l2tp.proto="l2tp"
	            uci set network.l2tp.ifname="l2tp-l2tp"
	            uci set network.l2tp.server="$EthernetClientPptpServerAddress"
	            uci set network.l2tp.username="$EthernetClientPptpUsername"
	            uci set network.l2tp.password="$EthernetClientPptpPassword"
	            uci set network.l2tp.keepalive="30 60"
	            uci set network.l2tp.metric='0'
	            uci set network.l2tp.gateway="$EthernetClientStaticGatewayPortwan"

				if [ "$EthernetClientPptpDNSServerSource" = "1" ]                                                                             
		        then                                                                                                                          
		            uci add_list network.l2tp.dns="$EthernetClientPptpDnsServerNo1"                                                       
		            if [ "$EthernetClientPptpNumberOfDNSServer" = "2" ]                                                                   
		            then                                                                                                                  
		                uci add_list network.l2tp.dns="$EthernetClientPptpDnsServerNo2"                                               
		            fi                                                                                                                    
		        fi              
		else
		    uci set network.EWAN=interface
		    uci set network.EWAN.ifname=eth0
			uci set network.EWAN.proto="dhcp"
			uci set network.EWAN.gateway="$EthernetClientDHCPGatewayPortwan"
			uci set network.EWAN.metric="$EwanPriority"
		fi  
      
      fi
       
  
    uci commit dhcp
    uci commit network	
}

UpdateModemConfig()
{
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then
	   uci set modem.cellularmodule.singlesimsinglemodule="0"
	   uci set modem.cellularmodule.singlesimdualmodule="1"
	   uci set modem.cellularmodule.dualsimsinglemodule="0"
	   uci set modem."${cellularwan1interface}".modemenable="1"
	   uci set modem."${cellularwan1sim1interface}".modemenable="0"
	   uci set modem."${cellularwan1sim2interface}".modemenable="0"
	   uci set modem."${cellularwan2interface}".modemenable="1"
	   uci set modem."${cellularwan3interface}".modemenable="0"
	   uci set modem."${cellularwan1interface}".manufacturer="$Manufacturerlocal1"
	   uci set modem."${cellularwan1interface}".model="$Model1"
	   uci set modem."${cellularwan1interface}".porttype="$PortType1"
	   uci set modem."${cellularwan1interface}".vendorid="$VendorId1"
	   uci set modem."${cellularwan1interface}".productid="$ProductId1"
	   uci set modem."${cellularwan1interface}".device="$DataPort1"
	   uci set modem."${cellularwan1interface}".comport="$ComPort1"
	   uci set modem."${cellularwan1interface}".smsport="$SmsPort1"
	   uci set modem."${cellularwan1interface}".smsenable="$SmsEnable1"
	   uci set modem."${cellularwan1interface}".smsc="$SmsCenterNumber1"
	   uci set modem."${cellularwan1interface}".smsdeviceid="$DeviceId1"
	   uci set modem."${cellularwan1interface}".smsapikey="$ApiKey1"
	   uci set modem."${cellularwan1interface}".monitorenable="1"
	   uci set modem."${cellularwan1interface}".actionmanagerenable="$MonitorEnable1"
	   uci set modem."${cellularwan1interface}".analyticsmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1interface}".statusmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1interface}".datatestenable="$DataTestEnable1"
	   uci set modem."${cellularwan1interface}".pingtestenable="$PingTestEnable1"
	   uci set modem."${cellularwan1interface}".pingip="$PingIp1"
	   uci set modem."${cellularwan1interface}".dataenable="$DataEnable1"
	   uci set modem."${cellularwan1interface}".service="$Service1"
	   uci set modem."${cellularwan1interface}".apn="$Apn1"
	   uci set modem."${cellularwan1interface}".metric="$Cwan1Priority"
	   uci set modem."${cellularwan1interface}".usbbuspath="$UsbBusPath1"
	   uci set modem."${cellularwan1interface}".action1waitinterval="$ActionInterval1"
	   if [ "$CellularModem1" = "QuectelEC20" ] || [ "$CellularModem1" = "QuectelEC25E" ]
	   then
	   uci set modem."${cellularwan1interface}".protocol="$Protocol1EC20"
	   if [ "$Protocol1EC20" == "ppp" ]
	   then
         uci set modem."${cellularwan1interface}".interfacename="3g-CWAN1"
	   else
         uci set modem."${cellularwan1interface}".interfacename="wwan0"
	   fi
	   else
	   uci set modem."${cellularwan1interface}".protocol="$Protocol1"
	   if [ "$Protocol1" == "ppp" ]
	   then
         uci set modem."${cellularwan1interface}".interfacename="3g-CWAN1"
	   else
         uci set modem."${cellularwan1interface}".interfacename="usb0"
	   fi
	   fi
	   uci set modem."${cellularwan1interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
	   uci set modem."${cellularwan1interface}".smsresponseserverenable="$SmsResponseServerEnable1"
	   uci set modem."${cellularwan1interface}".smsservernumber="$SmsServerNumber1"

	   if [ "$Pdp1" = "IPV4" ]
	   then
	       uci set modem."${cellularwan1interface}".ipv6="1"
	   fi
	   uci set modem."${cellularwan2interface}".manufacturer="$Manufacturerlocal2"
	   uci set modem."${cellularwan2interface}".model="$Model2"
	   uci set modem."${cellularwan2interface}".porttype="$PortType2"
	   uci set modem."${cellularwan2interface}".vendorid="$VendorId2"
	   uci set modem."${cellularwan2interface}".productid="$ProductId2"
	   uci set modem."${cellularwan2interface}".device="$DataPort2"
	   uci set modem."${cellularwan2interface}".comport="$ComPort2"
	   uci set modem."${cellularwan2interface}".smsport="$SmsPort2"
	   uci set modem."${cellularwan2interface}".smsenable="$SmsEnable2"
	   uci set modem."${cellularwan2interface}".smsc="$SmsCenterNumber1"
	   uci set modem."${cellularwan2interface}".smsdeviceid="$DeviceId2"
	   uci set modem."${cellularwan2interface}".smsapikey="$ApiKey2"
	   uci set modem."${cellularwan2interface}".monitorenable="1"
	   uci set modem."${cellularwan2interface}".actionmanagerenable="$MonitorEnable2"
	   uci set modem."${cellularwan2interface}".analyticsmanagerenable="$QueryModematAnalytics2"
	   uci set modem."${cellularwan2interface}".statusmanagerenable="$QueryModematAnalytics2"
	   uci set modem."${cellularwan2interface}".datatestenable="$DataTestEnable2"
	   uci set modem."${cellularwan2interface}".pingtestenable="$PingTestEnable2"
	   uci set modem."${cellularwan2interface}".pingip="$PingIp2"
	   uci set modem."${cellularwan2interface}".dataenable="$DataEnable2"
	   uci set modem."${cellularwan2interface}".service="$Sim2Service"
	   uci set modem."${cellularwan2interface}".apn="$Sim2Apn"
	   uci set modem."${cellularwan2interface}".metric="$Cwan2Priority"
	   uci set modem."${cellularwan2interface}".usbbuspath="$UsbBusPath2"
	   uci set modem."${cellularwan2interface}".action1waitinterval="$ActionInterval2"
	   if [ "$CellularModem2" = "QuectelEC20" ] || [ "$CellularModem1" = "QuectelEC25E" ]
	   then
	   uci set modem."${cellularwan2interface}".protocol="$Protocol2EC20"
	   if [ "$Protocol2EC20" == "ppp" ]
	   then
         uci set modem."${cellularwan2interface}".interfacename="3g-CWAN2"
	   else
         uci set modem."${cellularwan2interface}".interfacename="wwan0"
	   fi
	   else
	   uci set modem."${cellularwan2interface}".protocol="$Protocol2"
	   if [ "$Protocol2" == "ppp" ]
	   then
         uci set modem."${cellularwan2interface}".interfacename="3g-CWAN2"
	   else
         uci set modem."${cellularwan2interface}".interfacename="usb0"
	   fi
	   fi
	   uci set modem."${cellularwan2interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
	   uci set modem."${cellularwan2interface}".smsresponseserverenable="$SmsResponseServerEnable1"
	   uci set modem."${cellularwan2interface}".smsservernumber1="$SmsServerNumber1"
	   uci set modem."${cellularwan2interface}".smsservernumber2="$SmsServerNumber2"
       uci set modem."${cellularwan2interface}".smsservernumber3="$SmsServerNumber3"
	   uci set modem."${cellularwan2interface}".smsservernumber4="$SmsServerNumber4"
       uci set modem."${cellularwan2interface}".smsservernumber5="$SmsServerNumber5"
       
	   if [ "$Sim2Pdp" = "IPV4" ]
	   then
	       uci set modem."${cellularwan2interface}".ipv6="1"
	   fi	   
    elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
    then
       uci set modem.cellularmodule.singlesimsinglemodule="0"
	   uci set modem.cellularmodule.singlesimdualmodule="0"
	   uci set modem.cellularmodule.dualsimsinglemodule="1"
	   uci set modem."${cellularwan1interface}".modemenable="0"
	   uci set modem."${cellularwan1sim1interface}".modemenable="1"
	   uci set modem."${cellularwan1sim2interface}".modemenable="0"
	   uci set modem."${cellularwan1sim1interface}".actionmanagerenable="0"
	   uci set modem."${cellularwan1sim2interface}".actionmanagerenable="0"
	   uci set modem."${cellularwan2interface}".modemenable="0"
	   uci set modem."${cellularwan3interface}".modemenable="0"   
	   uci set modem."${cellularwan1sim1interface}".manufacturer="$Manufacturerlocal1"
	   uci set modem."${cellularwan1sim1interface}".model="$Model1"
	   uci set modem."${cellularwan1sim1interface}".porttype="$PortType1"
	   uci set modem."${cellularwan1sim1interface}".vendorid="$VendorId1"
	   uci set modem."${cellularwan1sim1interface}".productid="$ProductId1"
	   uci set modem."${cellularwan1sim1interface}".device="$DataPort1"
	   uci set modem."${cellularwan1sim1interface}".comport="$ComPort1"
	   uci set modem."${cellularwan1sim1interface}".smsport="$SmsPort1"
	   uci set modem."${cellularwan1sim1interface}".smsenable="$SmsEnable1"
	   uci set modem."${cellularwan1sim1interface}".smsc="$SmsCenterNumber1"
	   uci set modem."${cellularwan1sim1interface}".smsdeviceid="$DeviceId1"
	   uci set modem."${cellularwan1sim1interface}".smsapikey="$ApiKey1"
	   uci set modem."${cellularwan1sim1interface}".monitorenable="1"
	   uci set modem."${cellularwan1sim1interface}".analyticsmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1sim1interface}".statusmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1sim1interface}".datatestenable="$DataTestEnable1"
	   uci set modem."${cellularwan1sim1interface}".pingtestenable="$PingTestEnable1"
	   uci set modem."${cellularwan1sim1interface}".pingip="$PingIp1"
	   uci set modem."${cellularwan1sim1interface}".dataenable="$DataEnable1"
	   uci set modem."${cellularwan1sim1interface}".service="$Service1"
	   uci set modem."${cellularwan1sim1interface}".apn="$Apn1"
	   uci set modem."${cellularwan1sim1interface}".metric="$Cwan1sim1Priority"
	   uci set modem."${cellularwan1sim1interface}".usbbuspath="$UsbBusPath1"
	   if [ "$CellularModem1" = "QuectelEC20" ] || [ "$CellularModem1" = "QuectelEC25E" ]
	   then
	       uci set modem."${cellularwan1sim1interface}".protocol="$Protocol1EC20"
		   if [ "$Protocol1EC20" == "ppp" ]
		   then
			 uci set modem."${cellularwan1sim1interface}".interfacename="3g-CWAN1_0"
		   else
			 uci set modem."${cellularwan1sim1interface}".interfacename="wwan0"
		   fi
	   else
	       uci set modem."${cellularwan1sim1interface}".protocol="$Protocol1"
		   if [ "$Protocol1" == "ppp" ]
		   then
			 uci set modem."${cellularwan1sim1interface}".interfacename="3g-CWAN1_0"
		   else
			 uci set modem."${cellularwan1sim1interface}".interfacename="usb0"
		   fi
	   fi
	   uci set modem."${cellularwan1sim1interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
	   uci set modem."${cellularwan1sim1interface}".smsresponseserverenable="$SmsResponseServerEnable1"
	   uci set modem."${cellularwan1sim1interface}".smsservernumber1="$SmsServerNumber1"
	   uci set modem."${cellularwan1sim1interface}".smsservernumber2="$SmsServerNumber2"
       uci set modem."${cellularwan1sim1interface}".smsservernumber3="$SmsServerNumber3"
       uci set modem."${cellularwan1sim1interface}".smsservernumber4="$SmsServerNumber4"
       uci set modem."${cellularwan1sim1interface}".smsservernumber5="$SmsServerNumber5"
	   if [ "$Pdp1" = "IPV4" ]
	   then
	       uci set modem."${cellularwan1sim1interface}".ipv6="1"
	   fi	   	   
	   uci set modem."${cellularwan1sim2interface}".manufacturer="$Manufacturerlocal1"
	   uci set modem."${cellularwan1sim2interface}".model="$Model1"
	   uci set modem."${cellularwan1sim2interface}".porttype="$PortType1"
	   uci set modem."${cellularwan1sim2interface}".vendorid="$VendorId1"
	   uci set modem."${cellularwan1sim2interface}".productid="$ProductId1"
	   uci set modem."${cellularwan1sim2interface}".device="$DataPort1"
	   uci set modem."${cellularwan1sim2interface}".comport="$ComPort1"
	   uci set modem."${cellularwan1sim2interface}".smsport="$SmsPort1"
	   uci set modem."${cellularwan1sim2interface}".smsenable="$SmsEnable1"
	   uci set modem."${cellularwan1sim2interface}".smsc="$SmsCenterNumber1"
	   uci set modem."${cellularwan1sim2interface}".smsdeviceid="$DeviceId1"
	   uci set modem."${cellularwan1sim2interface}".smsapikey="$ApiKey1"
	   uci set modem."${cellularwan1sim2interface}".monitorenable="1"
	   uci set modem."${cellularwan1sim2interface}".analyticsmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1sim2interface}".statusmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1sim2interface}".datatestenable="$DataTestEnable1"
	   uci set modem."${cellularwan1sim2interface}".pingtestenable="$PingTestEnable1"
	   uci set modem."${cellularwan1sim2interface}".pingip="$PingIp1"
	   uci set modem."${cellularwan1sim2interface}".dataenable="$DataEnable1"
	   uci set modem."${cellularwan1sim2interface}".service="$Sim2Service"
	   uci set modem."${cellularwan1sim2interface}".apn="$Sim2Apn"
	   uci set modem."${cellularwan1sim2interface}".metric="$Cwan1sim2Priority"
	   uci set modem."${cellularwan1sim2interface}".usbbuspath="$UsbBusPath1"
	   if [ "$CellularModem1" = "QuectelEC20" ] || [ "$CellularModem1" = "QuectelEC25E" ]
	   then
	       uci set modem."${cellularwan1sim2interface}".protocol="$Protocol1EC20"
		   if [ "$Protocol1EC20" == "ppp" ]
		   then
			 uci set modem."${cellularwan1sim2interface}".interfacename="3g-CWAN1_1"
		   else
			 uci set modem."${cellularwan1sim2interface}".interfacename="wwan0"
		   fi
	   else
	       uci set modem."${cellularwan1sim2interface}".protocol="$Protocol1"
		   if [ "$Protocol1" == "ppp" ]
		   then
			 uci set modem."${cellularwan1sim2interface}".interfacename="3g-CWAN1_1"
		   else
			 uci set modem."${cellularwan1sim2interface}".interfacename="usb0"
		   fi
	   fi
	   uci set modem."${cellularwan1sim2interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
	   uci set modem."${cellularwan1sim2interface}".smsresponseserverenable="$SmsResponseServerEnable1"
	   uci set modem."${cellularwan1sim2interface}".smsservernumber1="$SmsServerNumber1"
	   uci set modem."${cellularwan1sim2interface}".smsservernumber2="$SmsServerNumber2"
       uci set modem."${cellularwan1sim2interface}".smsservernumber3="$SmsServerNumber3"
       uci set modem."${cellularwan1sim2interface}".smsservernumber4="$SmsServerNumber4"
       uci set modem."${cellularwan1sim2interface}".smsservernumber5="$SmsServerNumber5"
	   if [ "$Pdp1" = "IPV4" ]
	   then
	       uci set modem."${cellularwan1sim2interface}".ipv6="1"
	   fi
    else
       uci set modem.cellularmodule.singlesimsinglemodule="1"
	   uci set modem.cellularmodule.singlesimdualmodule="0"
	   uci set modem.cellularmodule.dualsimsinglemodule="0"
	   uci set modem."${cellularwan1interface}".modemenable="1"
	   uci set modem."${cellularwan1sim1interface}".modemenable="0"
	   uci set modem."${cellularwan1sim2interface}".modemenable="0"
	   uci set modem."${cellularwan2interface}".modemenable="0"
	   uci set modem."${cellularwan3interface}".modemenable="0"   
	   uci set modem."${cellularwan1interface}".manufacturer="$Manufacturerlocal1"
	   uci set modem."${cellularwan1interface}".model="$Model1"
	   uci set modem."${cellularwan1interface}".porttype="$PortType1"
	   uci set modem."${cellularwan1interface}".vendorid="$VendorId1"
	   uci set modem."${cellularwan1interface}".productid="$ProductId1"
	   uci set modem."${cellularwan1interface}".device="$DataPort1"
	   uci set modem."${cellularwan1interface}".comport="$ComPort1"
	   uci set modem."${cellularwan1interface}".smsport="$SmsPort1"
	   uci set modem."${cellularwan1interface}".smsenable="$SmsEnable1"
	   uci set modem."${cellularwan1interface}".smsc="$SmsCenterNumber1"
	   uci set modem."${cellularwan1interface}".smsdeviceid="$DeviceId1"
	   uci set modem."${cellularwan1interface}".smsapikey="$ApiKey1"
	   uci set modem."${cellularwan1interface}".monitorenable="1"
	   uci set modem."${cellularwan1interface}".actionmanagerenable="$MonitorEnable1"
	   uci set modem."${cellularwan1interface}".analyticsmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1interface}".statusmanagerenable="$QueryModematAnalytics1"
	   uci set modem."${cellularwan1interface}".datatestenable="$DataTestEnable1"
	   uci set modem."${cellularwan1interface}".pingtestenable="$PingTestEnable1"
	   uci set modem."${cellularwan1interface}".pingip="$PingIp1"
	   uci set modem."${cellularwan1interface}".dataenable="$DataEnable1"
	   uci set modem."${cellularwan1interface}".service="$Service1"
	   uci set modem."${cellularwan1interface}".apn="$Apn1"
	   uci set modem."${cellularwan1interface}".metric="$Cwan1Priority"
	   uci set modem."${cellularwan1interface}".usbbuspath="$UsbBusPath1"
	   uci set modem."${cellularwan1interface}".action1waitinterval="$ActionInterval1"
	   if [ "$CellularModem1" = "QuectelEC20" ] || [ "$CellularModem1" = "QuectelEC25E" ]
	   then
	       uci set modem."${cellularwan1interface}".protocol="$Protocol1EC20"
		   if [ "$Protocol1EC20" == "ppp" ]
		   then
			 uci set modem."${cellularwan1interface}".interfacename="3g-CWAN1"
		   else
			 uci set modem."${cellularwan1interface}".interfacename="wwan0"
		   fi
	   else
	       uci set modem."${cellularwan1interface}".protocol="$Protocol1"
		   if [ "$Protocol1" == "ppp" ]
		   then
			 uci set modem."${cellularwan1interface}".interfacename="3g-CWAN1"
		   else
			 uci set modem."${cellularwan1interface}".interfacename="usb0"
		   fi
	   fi
	   uci set modem."${cellularwan1interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
	   uci set modem."${cellularwan1interface}".smsresponseserverenable="$SmsResponseServerEnable1"
	   uci set modem."${cellularwan1interface}".smsservernumber1="$SmsServerNumber1"
	   uci set modem."${cellularwan1interface}".smsservernumber2="$SmsServerNumber2"
       uci set modem."${cellularwan1interface}".smsservernumber3="$SmsServerNumber3"
       uci set modem."${cellularwan1interface}".smsservernumber4="$SmsServerNumber4"
       uci set modem."${cellularwan1interface}".smsservernumber5="$SmsServerNumber5"
       
	   if [ "$Pdp1" = "IPV4" ]
	   then
	       uci set modem."${cellularwan1interface}".ipv6="1"
	   fi
	fi
	uci commit modem
}

UpdateFirewallConfig()
{
	   	if [ "$Wifi1Enable" = "0" ]
	    then 
	       uci delete firewall.wifi_wan > /dev/null 2>&1
	       uci delete firewall.wifi > /dev/null 2>&1
	    else
			if [ "$Wifi1Enable" = "1" ]
			then
				if [ "$Wifi1Mode" = "ap" ]
				then
					uci delete firewall.wifi_wan > /dev/null 2>&1
					uci set firewall.wifi=zone
					uci set firewall.wifi.name="$wifiap"
					uci set firewall.wifi.input="ACCEPT"
					uci set firewall.wifi.output="ACCEPT"
					uci set firewall.wifi.forward="ACCEPT"
					uci set firewall.wifi.network=ra0
					uci set firewall.wifi.masq="1"
					uci set firewall.wifi.mtu_fix="1"
					uci set firewall.wifi.extra_src="-m policy --dir in --pol none"
					uci set firewall.wifi.extra_dest="-m policy --dir out --pol none"
				else
					uci delete firewall.wifi > /dev/null 2>&1
					uci delete firewall.wifiewan > /dev/null 2>&1
					uci delete firewall.wifiewan2 > /dev/null 2>&1
					uci delete firewall.wificwan1 > /dev/null 2>&1
					uci delete firewall.wificwan2 > /dev/null 2>&1
					uci delete firewall.wificwan1_0 > /dev/null 2>&1
					uci delete firewall.wificwan1_1 > /dev/null 2>&1
					uci delete firewall.wifiwifiwan > /dev/null 2>&1
				fi 
				
				if [ "$Wifi1Mode" = "apsta" ]
                then
                    uci delete firewall.wifi_wan > /dev/null 2>&1
                    uci set firewall.wifi=zone
                    uci set firewall.wifi.name="$wifiap"
                    uci set firewall.wifi.input="ACCEPT"
                    uci set firewall.wifi.output="ACCEPT"
                    uci set firewall.wifi.forward="ACCEPT"
                    uci set firewall.wifi.network=ra0
                    uci set firewall.wifi.masq="1"
                    uci set firewall.wifi.mtu_fix="1"
                    uci set firewall.wifi.extra_src="-m policy --dir in --pol none"
                    uci set firewall.wifi.extra_dest="-m policy --dir out --pol none"
                    
                    uci set firewall.wifiewan=forwarding
                    uci set firewall.wifiewan.src="$wifiap"
                    uci set firewall.wifiewan.dest=EWAN
                    
                    uci set firewall.wificwan1=forwarding
                    uci set firewall.wificwan1.src="$wifiap"
                    uci set firewall.wificwan1.dest="$cellularwan1interface"
                    
                    uci set firewall.wificwan1_1=forwarding
                    uci set firewall.wificwan1_1.src="$wifiap"
                    uci set firewall.wificwan1_1.dest="$cellularwan1sim2interface"
                fi
								
				if [ "$Wifi1Mode" = "sta" ] ||  [ "$Wifi1Mode" = "apsta" ]
				then
					 #uci delete firewall.wifi > /dev/null 2>&1
					 uci set firewall.wifi_wan=zone
					 uci set firewall.wifi_wan.name="$wifista"
					 uci set firewall.wifi_wan.input="ACCEPT"
					 uci set firewall.wifi_wan.output="ACCEPT"
					 uci set firewall.wifi_wan.forward="ACCEPT"
					 uci set firewall.wifi_wan.network=wan
					 uci set firewall.wifi_wan.masq="1"
					 uci set firewall.wifi_wan.mtu_fix="1"
					 uci set firewall.wifi_wan.extra_src="-m policy --dir in --pol none"
					 uci set firewall.wifi_wan.extra_dest="-m policy --dir out --pol none"

							uci set firewall.lanwifiwan=forwarding
							uci set firewall.lanwifiwan.src=LAN
							uci set firewall.lanwifiwan.dest="$wifista"
						 
						    	uci set firewall.ra0wifiwan=forwarding
							uci set firewall.ra0wifiwan.src=ra0
							uci set firewall.ra0wifiwan.dest="$wifista"
						 
						 if [ "$Port2InternetOverLan" = "1" ] && [ "$Port2Mode" = "LAN1" ]
						 then 
							#~ uci delete firewall.wifiewan1 > /dev/null 2>&1
							#~ uci delete firewall.wifiewan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1 > /dev/null 2>&1
							#~ uci delete firewall.wificwan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_0 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_1 > /dev/null 2>&1
							uci set firewall.lan1wifi=forwarding
							uci set firewall.lan1wifi.src="$Port2lanInterfaceName"
							uci set firewall.lan1wifi.dest="$wifista"
						fi
						if [ "$Port3InternetOverLan" = "1" ] && [ "$Port3Mode" = "LAN2" ]
						 then 
							#~ uci delete firewall.wifiewan1 > /dev/null 2>&1
							#~ uci delete firewall.wifiewan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1 > /dev/null 2>&1
							#~ uci delete firewall.wificwan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_0 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_1 > /dev/null 2>&1
							uci set firewall.lan2wifi=forwarding
							uci set firewall.lan2wifi.src="$Port3lanInterfaceName"
							uci set firewall.lan2wifi.dest="$wifista"
						 fi
						 if [ "$Port4InternetOverLan" = "1" ] && [ "$Port4Mode" = "LAN3" ]
						 then 
							#~ uci delete firewall.wifiewan1 > /dev/null 2>&1
							#~ uci delete firewall.wifiewan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1 > /dev/null 2>&1
							#~ uci delete firewall.wificwan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_0 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_1 > /dev/null 2>&1
							uci set firewall.lan3wifi=forwarding
							uci set firewall.lan3wifi.src="$Port4lanInterfaceName"
							uci set firewall.lan3wifi.dest="$wifista"
						 fi
						 if [ "$Port5InternetOverLan" = "1" ] && [ "$Port5Mode" = "LAN4" ]
						 then 
							#~ uci delete firewall.wifiewan1 > /dev/null 2>&1
							#~ uci delete firewall.wifiewan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1 > /dev/null 2>&1
							#~ uci delete firewall.wificwan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_0 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_1 > /dev/null 2>&1
							uci set firewall.lan4wifi=forwarding
							uci set firewall.lan4wifi.src="$Port5lanInterfaceName"
							uci set firewall.lan4wifi.dest="$wifista"
						 fi
						 if [ "$InternetOverWifi" = "1" ] && [ "$Wifi1Enable" = "1" ]
						 then 
							#~ uci delete firewall.wifiewan1 > /dev/null 2>&1
							#~ uci delete firewall.wifiewan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1 > /dev/null 2>&1
							#~ uci delete firewall.wificwan2 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_0 > /dev/null 2>&1
							#~ uci delete firewall.wificwan1_1 > /dev/null 2>&1
							uci set firewall.wifiwifiwan=forwarding
							uci set firewall.wifiwifiwan.src="$wifiap"
							uci set firewall.wifiwifiwan.dest="$wifista"
						 fi
					 else
					   uci delete firewall.wifi_wan > /dev/null 2>&1
					   uci delete firewall.swlanwifi > /dev/null 2>&1
					   uci delete firewall.lan1wifi > /dev/null 2>&1
					   uci delete firewall.lan2wifi > /dev/null 2>&1
					   uci delete firewall.lan3wifi > /dev/null 2>&1
					   uci delete firewall.lan4wifi > /dev/null 2>&1
					   uci delete firewall.wifiwifiwan > /dev/null 2>&1
			   
			fi
	    fi
	fi


    if [ "$PortMode" = "LAN" ]
	then
       uci set firewall.lan=zone
       uci set firewall.lan.name=LAN
	   uci set firewall.lan.input="ACCEPT"
	   uci set firewall.lan.output="ACCEPT"
	   uci set firewall.lan.forward="ACCEPT"
	   uci set firewall.lan.network=LAN
	   uci set firewall.lan.masq="1"
	   uci set firewall.lan.mtu_fix="1"
	   uci set firewall.lan.extra_src="-m policy --dir in --pol none"
	   uci set firewall.lan.extra_dest="-m policy --dir out --pol none"
	elif [ "$PortMode" = "EWAN" ]
	then
	   uci delete firewall.lanwifi > /dev/null 2>&1
	   uci delete firewall.lanewan1 > /dev/null 2>&1
	   uci delete firewall.lanewan2 > /dev/null 2>&1
	   uci delete firewall.lancwan1 > /dev/null 2>&1
	   uci delete firewall.lan3 > /dev/null 2>&1
	   uci set firewall.ewan=zone
       uci set firewall.ewan.name=EWAN
	   uci set firewall.ewan.input="ACCEPT"
	   uci set firewall.ewan.output="ACCEPT"
	   uci set firewall.ewan.forward="ACCEPT"
	   uci set firewall.ewan.network=EWAN
	   uci set firewall.ewan.masq="1"
	   uci set firewall.ewan.mtu_fix="1"
	   uci set firewall.ewan.extra_src="-m policy --dir in --pol none"
	   uci set firewall.ewan.extra_dest="-m policy --dir out --pol none"
	   
	   	if [ "$EthernetProtocolPortwan" = "pptp" ]
	   then 
			uci set firewall.pptp=zone
			uci set firewall.pptp.name="PPTP"
			uci set firewall.pptp.input="ACCEPT"
			uci set firewall.pptp.output="ACCEPT"
			uci set firewall.pptp.mtu_fix="1"
			uci set firewall.pptp.forward="REJECT"
			uci set firewall.pptp.network="PPTP"
			uci set firewall.pptp.masq="1"
			uci set firewall.pptp.extra_src '-m policy --dir in --pol ipsec --proto esp'
			uci set firewall.pptp.extra_dest '-m policy --dir out --pol ipsec --proto esp'
			
			uci set firewall.pptpcwan1_0=forwarding
            uci set firewall.pptpcwan1_0.src="PPTP"
            uci set firewall.pptpcwan1_0.dest="CWAN1"
            
            uci set firewall.cwan1_0pptp=forwarding
            uci set firewall.cwan1_0pptp.src="CWAN1"
            uci set firewall.cwan1_0pptp.dest="PPTP"
            
            uci set firewall.pptpewan2=forwarding
            uci set firewall.pptpewan2.src="PPTP"
            uci set firewall.pptpewan2.dest="EWAN"
            
            uci set firewall.ewan2pptp=forwarding
            uci set firewall.ewan2pptp.src="EWAN"
            uci set firewall.ewan2pptp.dest="PPTP"
            
            uci set firewall.pptpcwan1_1=forwarding
            uci set firewall.pptpcwan1_1.src="PPTP"
            uci set firewall.pptpcwan1_1.dest="CWAN1_1"
            
            uci set firewall.cwan1_1pptp=forwarding
            uci set firewall.cwan1_1pptp.src="CWAN1_1"
            uci set firewall.cwan1_1pptp.dest="PPTP"
             
			 if [ "$Port1InternetoverSwLan" = "1" ]
	   then
			uci set firewall.swlanpptp=forwarding
			uci set firewall.swlanpptp.src="$laninterface"
			uci set firewall.swlanpptp.dest="PPTP"
			
			uci set firewall.pptpswlan=forwarding
			uci set firewall.pptpswlan.src="PPTP"
			uci set firewall.pptpswlan.dest="$laninterface"
		fi
		
		if [ "$InternetOverWifi" = "1" ]
	    then
		  if [ "$Radio0AccessPointEnable" = "1" ]
	      then
	        uci set firewall.wifipptp=forwarding
			uci set firewall.wifipptp.src="$wifiap"
			uci set firewall.wifipptp.dest="PPTP"
			
			uci set firewall.pptpwifi=forwarding
			uci set firewall.pptpwifi.src="PPTP"
			uci set firewall.pptpwifi.dest="$wifiap"
	      fi 
			
		fi
		fi
		uci commit firewall  
            /etc/init.d/firewall restart    
        fi

		if [ "$EthernetProtocolPortwan" = "l2tp" ]
	   then 
			uci set firewall.l2tp=zone
			uci set firewall.l2tp.name="l2tp"
			uci set firewall.l2tp.input="ACCEPT"
			uci set firewall.l2tp.output="ACCEPT"
			uci set firewall.l2tp.mtu_fix="1"
			uci set firewall.l2tp.forward="REJECT"
			uci set firewall.l2tp.network="l2tp"
			uci set firewall.l2tp.masq="1"
			uci set firewall.l2tp.extra_src '-m policy --dir in --pol ipsec --proto esp'
			uci set firewall.l2tp.extra_dest '-m policy --dir out --pol ipsec --proto esp'
			
			
			uci set firewall.l2tpcwan1_0=forwarding
            uci set firewall.l2tpcwan1_0.src="l2tp"
            uci set firewall.l2tpcwan1_0.dest="CWAN1"
            
            uci set firewall.cwan1_0l2tp=forwarding
            uci set firewall.cwan1_0l2tp.src="CWAN1"
            uci set firewall.cwan1_0l2tp.dest="l2tp"
            
            uci set firewall.l2tpewan2=forwarding
            uci set firewall.l2tpewan2.src="l2tp"
            uci set firewall.l2tpewan2.dest="EWAN"
            
            uci set firewall.ewan2l2tp=forwarding
            uci set firewall.ewan2l2tp.src="EWAN"
            uci set firewall.ewan2l2tp.dest="l2tp"
                        
            
			if [ "$Port1InternetoverSwLan" = "1" ]
			then
			uci set firewall.lanl2tp=forwarding
			uci set firewall.lanl2tp.src="$lanInterfaceName"
			uci set firewall.lanl2tp.dest="l2tp"
			
			uci set firewall.l2tplan=forwarding
			uci set firewall.l2tplan.src="l2tp"
			uci set firewall.l2tplan.dest="$lanInterfaceName"
			fi

		if [ "$InternetOverWifi" = "1" ]
	    then
		  if [ "$Radio0AccessPointEnable" = "1" ]
	      then
	        uci set firewall.wifil2tp=forwarding
			uci set firewall.wifil2tp.src="$wifiap"
			uci set firewall.wifil2tp.dest="l2tp"
			
			uci set firewall.l2tpwifi=forwarding
			uci set firewall.l2tpwifi.src="l2tp"
			uci set firewall.l2tpwifi.dest="$wifiap"
	      fi 
			
		fi
	   
		if [ "$InternetOverWifi" = "1" ]
	    then
		  if [ "$Radio0AccessPointEnable" = "1" ]
	      then
	        uci set firewall.wifiewan=forwarding
			uci set firewall.wifiewan.src="$wifiap"
			uci set firewall.wifiewan.dest=EWAN
	      fi 
		 fi 
	else
	   uci delete firewall.lanwifi > /dev/null 2>&1
	   uci delete firewall.lan1ewan1 > /dev/null 2>&1
	   uci delete firewall.lan1ewan2 > /dev/null 2>&1
	   uci delete firewall.lan1cwan1 > /dev/null 2>&1
	   uci delete firewall.lan1cwan1_0 > /dev/null 2>&1
	   uci delete firewall.lan1cwan1_1 > /dev/null 2>&1
	   uci delete firewall.lan1cwan2 > /dev/null 2>&1
	   uci delete firewall.lan1 > /dev/null 2>&1
    fi
		
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then
		  uci delete firewall.cwan1_0 > /dev/null 2>&1
		  uci delete firewall.cwan1_1 > /dev/null 2>&1
		  uci set firewall.cwan1=zone
		  uci set firewall.cwan1.name="$cellularwan1interface"
		  uci set firewall.cwan1.input="ACCEPT"
		  uci set firewall.cwan1.output="ACCEPT"
		  uci set firewall.cwan1.forward="ACCEPT"
		  uci set firewall.cwan1.network="$cellularwan1interface"
		  uci set firewall.cwan1.masq="1"
		  uci set firewall.cwan1.mtu_fix="1"
		  uci set firewall.cwan1.extra_src="-m policy --dir in --pol none"
		  uci set firewall.cwan1.extra_dest="-m policy --dir out --pol none"
		  uci set firewall.cwan2=zone
		  uci set firewall.cwan2.name="$cellularwan2interface"
		  uci set firewall.cwan2.input="ACCEPT"
		  uci set firewall.cwan2.output="ACCEPT"
		  uci set firewall.cwan2.forward="ACCEPT"
		  uci set firewall.cwan2.network="$cellularwan2interface"
		  uci set firewall.cwan2.masq="1"
		  uci set firewall.cwan2.mtu_fix="1"
		  uci set firewall.cwan2.extra_src="-m policy --dir in --pol none"
		  uci set firewall.cwan2.extra_dest="-m policy --dir out --pol none"                                                    
		  uci delete firewall.swlancwan1_0 > /dev/null 2>&1
		  uci delete firewall.swlancwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan1cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan1cwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan2cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan2cwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan3cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan3cwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan4cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan4cwan1_1 > /dev/null 2>&1
		  uci delete firewall.wificwan1_0 > /dev/null 2>&1
		  uci delete firewall.wificwan1_1 > /dev/null 2>&1
		  
			 if [ "$PortInternetOverLan" = "1" ] && [ "$PortMode" = "LAN" ]
			 then 
				uci set firewall.lancwan1=forwarding
				uci set firewall.lancwan1.src=LAN
				uci set firewall.lancwan1.dest="$cellularwan1interface"
			fi
			 
			if [ "$InternetOverWifi" = "1" ]
			then
			  if [ "$Radio0AccessPointEnable" = "1" ]
			  then
				uci set firewall.wificwan1=forwarding
				uci set firewall.wificwan1.src="$wifiap"
				uci set firewall.wificwan1.dest="$cellularwan1interface"
			  fi 
			 fi 
			
			if [ "$InternetOverWifi" = "1" ]
			then
			  if [ "$Radio0AccessPointEnable" = "1" ]
			  then
				uci set firewall.wificwan2=forwarding
				uci set firewall.wificwan2.src="$wifiap"
				uci set firewall.wificwan2.dest="$cellularwan2interface"
			  fi 
			 fi 
		elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci delete firewall.cwan1 > /dev/null 2>&1
		   uci delete firewall.cwan2 > /dev/null 2>&1
		   uci set firewall.cwan1_0=zone
		   uci set firewall.cwan1_0.name="$cellularwan1sim1interface"
		   uci set firewall.cwan1_0.input="ACCEPT"
		   uci set firewall.cwan1_0.output="ACCEPT"
		   uci set firewall.cwan1_0.forward="ACCEPT"
		   uci set firewall.cwan1_0.network="$cellularwan1sim1interface"
		   uci set firewall.cwan1_0.masq="1"
		   uci set firewall.cwan1_0.mtu_fix="1"
		   uci set firewall.cwan1_0.extra_src="-m policy --dir in --pol none"
		   uci set firewall.cwan1_0.extra_dest="-m policy --dir out --pol none"
		   uci set firewall.cwan1_1=zone
		   uci set firewall.cwan1_1.name="$cellularwan1sim2interface"
		   uci set firewall.cwan1_1.input="ACCEPT"
		   uci set firewall.cwan1_1.output="ACCEPT"
		   uci set firewall.cwan1_1.forward="ACCEPT"
		   uci set firewall.cwan1_1.network="$cellularwan1sim2interface"
		   uci set firewall.cwan1_1.masq="1"
		   uci set firewall.cwan1_1.mtu_fix="1"
		   uci set firewall.cwan1_1.extra_src="-m policy --dir in --pol none"
		   uci set firewall.cwan1_1.extra_dest="-m policy --dir out --pol none"    
		   uci delete firewall.cwan1_1 > /dev/null 2>&1
		   uci delete firewall.swlancwan1 > /dev/null 2>&1
		   uci delete firewall.swlancwan2 > /dev/null 2>&1
		   uci delete firewall.lan1cwan1 > /dev/null 2>&1
		   uci delete firewall.lan1cwan2 > /dev/null 2>&1
		   uci delete firewall.lan2cwan1 > /dev/null 2>&1
		   uci delete firewall.lan2cwan2 > /dev/null 2>&1
		   uci delete firewall.lan3cwan1 > /dev/null 2>&1
		   uci delete firewall.lan3cwan2 > /dev/null 2>&1
		   uci delete firewall.lan4cwan1 > /dev/null 2>&1
		   uci delete firewall.lan4cwan2 > /dev/null 2>&1
		   uci delete firewall.wificwan1 > /dev/null 2>&1
		   uci delete firewall.wificwan2 > /dev/null 2>&1
		   if [ "$Port1InternetoverSwLan" = "1" ]
		   then
				uci set firewall.swlancwan1_0=forwarding
				uci set firewall.swlancwan1_0.src="$SwlanInterfaceName"
				uci set firewall.swlancwan1_0.dest="$cellularwan1sim1interface"
			fi
			 if [ "$Port2InternetOverLan" = "1" ] && [ "$Port2Mode" = "LAN1" ]
			 then 
				uci set firewall.lan1cwan1_0=forwarding
				uci set firewall.lan1cwan1_0.src="$Port2lanInterfaceName"
				uci set firewall.lan1cwan1_0.dest="$cellularwan1sim1interface"
			fi
			 if [ "$Port3InternetOverLan" = "1" ] && [ "$Port3Mode" = "LAN2" ]
			 then 
				uci set firewall.lan2cwan1_0=forwarding
				uci set firewall.lan2cwan1_0.src="$Port3lanInterfaceName"
				uci set firewall.lan2cwan1_0.dest="$cellularwan1sim1interface"
			fi
			 if [ "$Port4InternetOverLan" = "1" ] && [ "$Port4Mode" = "LAN3" ]
			 then 
				uci set firewall.lan3cwan1_0=forwarding
				uci set firewall.lan3cwan1_0.src="$Port4lanInterfaceName"
				uci set firewall.lan3cwan1_0.dest="$cellularwan1sim1interface"
			fi
			 if [ "$Port5InternetOverLan" = "1" ] && [ "$Port5Mode" = "LAN4" ]
			 then 
				uci set firewall.lan4cwan1_0=forwarding
				uci set firewall.lan4cwan1_0.src="$Port5lanInterfaceName"
				uci set firewall.lan4cwan1_0.dest="$cellularwan1sim1interface"
			fi
			if [ "$InternetOverWifi" = "1" ]
			then
			  if [ "$Radio0AccessPointEnable" = "1" ]
			  then
				uci set firewall.wificwan1_0=forwarding
				uci set firewall.wificwan1_0.src="$wifiap"
				uci set firewall.wificwan1_0.dest="$cellularwan1sim1interface"
			  fi 
			 fi 
		   if [ "$Port1InternetoverSwLan" = "1" ]
		   then
				uci set firewall.swlancwan1_1=forwarding
				uci set firewall.swlancwan1_1.src="$SwlanInterfaceName"
				uci set firewall.swlancwan1_1.dest="$cellularwan1sim2interface"
			fi
			 if [ "$Port2InternetOverLan" = "1" ] && [ "$Port2Mode" = "LAN1" ]
			 then 
				uci set firewall.lan1cwan1_1=forwarding
				uci set firewall.lan1cwan1_1.src="$Port2lanInterfaceName"
				uci set firewall.lan1cwan1_1.dest="$cellularwan1sim2interface"
			fi
			 if [ "$Port3InternetOverLan" = "1" ] && [ "$Port3Mode" = "LAN2" ]
			 then 
				uci set firewall.lan2cwan1_1=forwarding
				uci set firewall.lan2cwan1_1.src="$Port3lanInterfaceName"
				uci set firewall.lan2cwan1_1.dest="$cellularwan1sim2interface"
			fi
			 if [ "$Port4InternetOverLan" = "1" ] && [ "$Port4Mode" = "LAN3" ]
			 then 
				uci set firewall.lan3cwan1_1=forwarding
				uci set firewall.lan3cwan1_1.src="$Port4lanInterfaceName"
				uci set firewall.lan3cwan1_1.dest="$cellularwan1sim2interface"
			fi
			 if [ "$Port5InternetOverLan" = "1" ] && [ "$Port5Mode" = "LAN4" ]
			 then 
				uci set firewall.lan4cwan1_1=forwarding
				uci set firewall.lan4cwan1_1.src="$Port5lanInterfaceName"
				uci set firewall.lan4cwan1_1.dest="$cellularwan1sim2interface"
			fi
			if [ "$InternetOverWifi" = "1" ]
			then
			  if [ "$Radio0AccessPointEnable" = "1" ]
			  then
				uci set firewall.wificwan1_1=forwarding
				uci set firewall.wificwan1_1.src="$wifiap"
				uci set firewall.wificwan1_1.dest="$cellularwan1sim2interface"
			  fi 
			 fi 
		else
		   uci delete firewall.cwan1_0 > /dev/null 2>&1
		   uci delete firewall.cwan1_1 > /dev/null 2>&1
		   uci delete firewall.cwan2 > /dev/null 2>&1
		   uci delete firewall.udp_DHCPv6_replies
		   uci set firewall.cwan1=zone
		   uci set firewall.cwan1.name="$cellularwan1interface"
		   uci set firewall.cwan1.input="ACCEPT"
		   uci set firewall.cwan1.output="ACCEPT"
		   uci set firewall.cwan1.forward="ACCEPT"
		   uci set firewall.cwan1.network="$cellularwan1interface"
		   uci set firewall.cwan1.masq="1"
		   uci set firewall.cwan1.mtu_fix="1"
		   uci set firewall.cwan1.extra_src="-m policy --dir in --pol none"
		   uci set firewall.cwan1.extra_dest="-m policy --dir out --pol none"
		   
		   	   
		   if [ "$PDP1" = "IPV6" ] || [ "$PDP1" = "IPV4V6" ] || [ "$PDP2" = "IPV6" ] || [ "$PDP2" = "IPV4V6" ]
		   then
		   
		        uci set firewall.$cellularwan6sim1interface=zone
				uci set firewall.$cellularwan6sim1interface.name="$cellularwan6sim1interface"
				uci set firewall.$cellularwan6sim1interface.input="ACCEPT"
				uci set firewall.$cellularwan6sim1interface.output="ACCEPT"
				uci set firewall.$cellularwan6sim1interface.forward="ACCEPT"
				uci set firewall.$cellularwan6sim1interface.network="$cellularwan6sim1interface"
				uci set firewall.$cellularwan6sim1interface.masq="1"
				uci set firewall.$cellularwan6sim1interface.mtu_fix="1"
				
				uci set firewall.udp_DHCPv6_replies=rule
				uci set firewall.udp_DHCPv6_replies.target='ACCEPT'
				uci set firewall.udp_DHCPv6_replies.src='wan6c1'
				uci set firewall.udp_DHCPv6_replies.proto='udp'
				uci set firewall.udp_DHCPv6_replies.dest_port='546'
				uci set firewall.udp_DHCPv6_replies.name='Allow DHCPv6 replies'
				uci set firewall.udp_DHCPv6_replies.family='ipv6'
				uci set firewall.udp_DHCPv6_replies.src_port='547'         
		   fi
		   
		   uci delete firewall.swlancwan1_0 > /dev/null 2>&1
		   uci delete firewall.swlancwan1_1 > /dev/null 2>&1
		   uci delete firewall.swlancwan2 > /dev/null 2>&1
		   uci delete firewall.lan1cwan1_0 > /dev/null 2>&1
		   uci delete firewall.lan1cwan1_1 > /dev/null 2>&1
		   uci delete firewall.lan1cwan2 > /dev/null 2>&1
		   uci delete firewall.lan2cwan1_0 > /dev/null 2>&1
		   uci delete firewall.lan2cwan1_1 > /dev/null 2>&1
		   uci delete firewall.lan2cwan2 > /dev/null 2>&1
		   uci delete firewall.lan3cwan1_0 > /dev/null 2>&1
		   uci delete firewall.lan3cwan1_1 > /dev/null 2>&1
		   uci delete firewall.lan3cwan2 > /dev/null 2>&1
		   uci delete firewall.lan4cwan1_0 > /dev/null 2>&1
		   uci delete firewall.lan4cwan1_1 > /dev/null 2>&1
		   uci delete firewall.lan4cwan2 > /dev/null 2>&1
		   uci delete firewall.wificwan1_0 > /dev/null 2>&1
		   uci delete firewall.wificwan1_1 > /dev/null 2>&1
		   uci delete firewall.wificwan2 > /dev/null 2>&1
		   if [ "$Port1InternetoverSwLan" = "1" ]
		   then
				uci set firewall.swlancwan1=forwarding
				uci set firewall.swlancwan1.src="$SwlanInterfaceName"
				uci set firewall.swlancwan1.dest="$cellularwan1interface"
			fi
			 if [ "$Port2InternetOverLan" = "1" ] && [ "$Port2Mode" = "LAN1" ]
			 then 
				uci set firewall.lan1cwan1=forwarding
				uci set firewall.lan1cwan1.src="$Port2lanInterfaceName"
				uci set firewall.lan1cwan1.dest="$cellularwan1interface"
			fi
			 if [ "$Port3InternetOverLan" = "1" ] && [ "$Port3Mode" = "LAN2" ]
			 then 
				uci set firewall.lan2cwan1=forwarding
				uci set firewall.lan2cwan1.src="$Port3lanInterfaceName"
				uci set firewall.lan2cwan1.dest="$cellularwan1interface"
			fi
			 if [ "$Port4InternetOverLan" = "1" ] && [ "$Port4Mode" = "LAN3" ]
			 then 
				uci set firewall.lan3cwan1=forwarding
				uci set firewall.lan3cwan1.src="$Port4lanInterfaceName"
				uci set firewall.lan3cwan1.dest="$cellularwan1interface"
			fi
			 if [ "$Port5InternetOverLan" = "1" ] && [ "$Port5Mode" = "LAN4" ]
			 then 
				uci set firewall.lan4cwan1=forwarding
				uci set firewall.lan4cwan1.src="$Port5lanInterfaceName"
				uci set firewall.lan4cwan1.dest="$cellularwan1interface"
			fi
			if [ "$InternetOverWifi" = "1" ]
			then
			  if [ "$Radio0AccessPointEnable" = "1" ]
			  then
				uci set firewall.wificwan1=forwarding
				uci set firewall.wificwan1.src="$wifiap"
				uci set firewall.wificwan1.dest="$cellularwan1interface"
			  fi 
		   fi 
		fi
	  else
	   	  uci delete firewall.cwan1 > /dev/null 2>&1
	   	  uci delete firewall.cwan2 > /dev/null 2>&1
	   	  uci delete firewall.cwan1_0 > /dev/null 2>&1
		  uci delete firewall.cwan1_1 > /dev/null 2>&1
		  uci delete firewall.swlancwan1 > /dev/null 2>&1
		  uci delete firewall.swlancwan2 > /dev/null 2>&1
		  uci delete firewall.swlancwan1_0 > /dev/null 2>&1
		  uci delete firewall.swlancwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan1cwan1 > /dev/null 2>&1
		  uci delete firewall.lan1cwan2 > /dev/null 2>&1
		  uci delete firewall.lan1cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan1cwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan2cwan1 > /dev/null 2>&1
		  uci delete firewall.lan2cwan2 > /dev/null 2>&1
		  uci delete firewall.lan2cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan2cwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan3cwan1 > /dev/null 2>&1
		  uci delete firewall.lan3cwan2 > /dev/null 2>&1
		  uci delete firewall.lan3cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan3cwan1_1 > /dev/null 2>&1
		  uci delete firewall.lan4cwan1 > /dev/null 2>&1
		  uci delete firewall.lan4cwan2 > /dev/null 2>&1
		  uci delete firewall.lan4cwan1_0 > /dev/null 2>&1
		  uci delete firewall.lan4cwan1_1 > /dev/null 2>&1
		  uci delete firewall.wificwan1 > /dev/null 2>&1
		  uci delete firewall.wificwan2 > /dev/null 2>&1
		  uci delete firewall.wificwan1_0 > /dev/null 2>&1
		  uci delete firewall.wificwan1_1 > /dev/null 2>&1
	fi
	
   if [ "$Port1InternetoverSwLan" = "0" ]
   then
       uci delete firewall.swlanwifi > /dev/null 2>&1
	   uci delete firewall.swlanewan1 > /dev/null 2>&1
	   uci delete firewall.swlanewan2 > /dev/null 2>&1
	   uci delete firewall.swlancwan1 > /dev/null 2>&1
	   uci delete firewall.swlancwan1_0 > /dev/null 2>&1
	   uci delete firewall.swlancwan1_1 > /dev/null 2>&1
	   uci delete firewall.swlancwan2 > /dev/null 2>&1
   fi
   if [ "$Port2InternetoverLan" = "0" ]
   then
       uci delete firewall.lan1wifi > /dev/null 2>&1
	   uci delete firewall.lan1ewan1 > /dev/null 2>&1
	   uci delete firewall.lan1ewan2 > /dev/null 2>&1
	   uci delete firewall.lan1cwan1 > /dev/null 2>&1
	   uci delete firewall.lan1cwan1_0 > /dev/null 2>&1
	   uci delete firewall.lan1cwan1_1 > /dev/null 2>&1
	   uci delete firewall.lan1cwan2 > /dev/null 2>&1
   fi
   if [ "$Port3InternetoverLan" = "0" ]
   then
       uci delete firewall.lan2wifi > /dev/null 2>&1
	   uci delete firewall.lan2ewan1 > /dev/null 2>&1
	   uci delete firewall.lan2ewan2 > /dev/null 2>&1
	   uci delete firewall.lan2cwan1 > /dev/null 2>&1
	   uci delete firewall.lan2cwan1_0 > /dev/null 2>&1
	   uci delete firewall.lan2cwan1_1 > /dev/null 2>&1
	   uci delete firewall.lan2cwan2 > /dev/null 2>&1
   fi
   if [ "$Port4InternetoverLan" = "0" ]
   then
       uci delete firewall.lan3wifi > /dev/null 2>&1
	   uci delete firewall.lan3ewan1 > /dev/null 2>&1
	   uci delete firewall.lan3ewan2 > /dev/null 2>&1
	   uci delete firewall.lan3cwan1 > /dev/null 2>&1
	   uci delete firewall.lan3cwan1_0 > /dev/null 2>&1
	   uci delete firewall.lan3cwan1_1 > /dev/null 2>&1
	   uci delete firewall.lan3cwan2 > /dev/null 2>&1
   fi
   if [ "$Port5InternetoverLan" = "0" ]
   then
       uci delete firewall.lan4wifi > /dev/null 2>&1
	   uci delete firewall.lan4ewan1 > /dev/null 2>&1
	   uci delete firewall.lan4ewan2 > /dev/null 2>&1
	   uci delete firewall.lan4cwan1 > /dev/null 2>&1
	   uci delete firewall.lan4cwan1_0 > /dev/null 2>&1
	   uci delete firewall.lan4cwan1_1 > /dev/null 2>&1
	   uci delete firewall.lan4cwan2 > /dev/null 2>&1
   fi
   if [ "$InternetOverWifi" = "0" ]
   then
	   uci delete firewall.wifiewan1 > /dev/null 2>&1
	   uci delete firewall.wifiewan2 > /dev/null 2>&1
	   uci delete firewall.wificwan1 > /dev/null 2>&1
	   uci delete firewall.wificwan1_0 > /dev/null 2>&1
	   uci delete firewall.wificwan1_1 > /dev/null 2>&1
	   uci delete firewall.wificwan2 > /dev/null 2>&1
	   uci delete firewall.wifiwifiwan > /dev/null 2>&1
   fi
   if [ "$Radio0AccessPointEnable" = "0" ]
   then
	   uci delete firewall.wifiewan1 > /dev/null 2>&1
	   uci delete firewall.wifiewan2 > /dev/null 2>&1
	   uci delete firewall.wificwan1 > /dev/null 2>&1
	   uci delete firewall.wificwan1_0 > /dev/null 2>&1
	   uci delete firewall.wificwan1_1 > /dev/null 2>&1
	   uci delete firewall.wificwan2 > /dev/null 2>&1
	   uci delete firewall.wifiwifiwan > /dev/null 2>&1
   fi
	uci commit firewall
}

UpdateInternetOverInterface()
{
   if [ "$portinternetoverlan" = "0" ]                                                                         
   then                                                                                                           
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then 
		   uci set firewall.block_lan_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan1.src='LAN' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan1.dest='CWAN1' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan2=rule > /dev/null 2>&1
		   uci set firewall.block_lan_cwan2.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan2.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan2.src='LAN' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan2.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan_cwan2.dest='CWAN2' > /dev/null 2>&1
		else
		   uci delete firewall.block_an_cwan1 > /dev/null 2>&1
		   uci delete firewall.block_lan_cwan2 > /dev/null 2>&1
		fi    
	    if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci set firewall.block_sw_lan_cwan1_0=rule > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_0.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_0.proto='all' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_0.src='SW_LAN' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_0.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_0.dest='CWAN1_0' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_1=rule > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_1.src='SW_LAN' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1_1.dest='CWAN1_1' > /dev/null 2>&1
		else
		   uci delete firewall.block_sw_lan_cwan1_0 > /dev/null 2>&1
		   uci delete firewall.block_sw_lan_cwan1_1 > /dev/null 2>&1		
		fi
	    if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
		   uci set firewall.block_sw_lan_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1.src='SW_LAN' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_sw_lan_cwan1.dest='CWAN1' > /dev/null 2>&1
		else
		    uci delete firewall.block_sw_lan_cwan1 > /dev/null 2>&1
		fi
	else
	  uci delete firewall.block_sw_lan_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_sw_lan_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_sw_lan_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_sw_lan_cwan1_1 > /dev/null 2>&1	    
	fi
   else
      uci delete firewall.block_sw_lan_ewan1 > /dev/null 2>&1
      uci delete firewall.block_sw_lan_ewan2 > /dev/null 2>&1  
	  uci delete firewall.block_sw_lan_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_sw_lan_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_sw_lan_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_sw_lan_cwan1_1 > /dev/null 2>&1
	  uci delete firewall.block_sw_lan_wifi_wan > /dev/null 2>&1
   fi 
  if [ "$Port2InternetoverLan" = "0" ]                                                                         
   then                                                                                                           
     if [ "$Port4Mode" = "EWAN1" ]
	 then
	     uci set firewall.block_lan1_ewan1=rule > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan1.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan1.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan1.src='LAN1' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan1.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan1.dest='EWAN1' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan1_ewan1 > /dev/null 2>&1
	 fi
     if [ "$Port5Mode" = "EWAN2" ]
	 then
	     uci set firewall.block_lan1_ewan2=rule > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan2.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan2.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan2.src='LAN1' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan2.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan1_ewan2.dest='EWAN2' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan1_ewan2 > /dev/null 2>&1
	 fi     
	 if [ "$Radio0StationEnable" = "1" ]
     then
	     uci set firewall.block_lan1_wifi_wan=rule > /dev/null 2>&1
		 uci set firewall.block_lan1_wifi_wan.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan1_wifi_wan.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan1_wifi_wan.src='LAN1' > /dev/null 2>&1
		 uci set firewall.block_lan1_wifi_wan.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan1_wifi_wan.dest='WIFI_WAN' > /dev/null 2>&1
	else
	    uci delete firewall.block_lan1_wifi_wan > /dev/null 2>&1 
    fi                                     
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then 
		   uci set firewall.block_lan1_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.src='LAN1' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.dest='CWAN1' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan2=rule > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan2.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan2.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan2.src='LAN1' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan2.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan2.dest='CWAN2' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan1_cwan1 > /dev/null 2>&1
		   uci delete firewall.block_lan1_cwan2 > /dev/null 2>&1
		fi    
	    if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci set firewall.block_lan1_cwan1_0=rule > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_0.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_0.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_0.src='LAN1' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_0.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_0.dest='CWAN1_0' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_1=rule > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_1.src='LAN1' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1_1.dest='CWAN1_1' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan1_cwan1_0 > /dev/null 2>&1
		   uci delete firewall.block_lan1_cwan1_1 > /dev/null 2>&1		
		fi
	    if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
		   uci set firewall.block_lan1_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.src='LAN1' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan1_cwan1.dest='CWAN1' > /dev/null 2>&1
		else
		    uci delete firewall.block_lan1_cwan1 > /dev/null 2>&1
		fi
	else
	  uci delete firewall.block_lan1_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan1_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan1_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan1_cwan1_1 > /dev/null 2>&1	   
	fi
   else
      uci delete firewall.block_lan1_ewan1 > /dev/null 2>&1
      uci delete firewall.block_lan1_ewan2 > /dev/null 2>&1  
	  uci delete firewall.block_lan1_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan1_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan1_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan1_cwan1_1 > /dev/null 2>&1
	  uci delete firewall.block_lan1_wifi_wan > /dev/null 2>&1
   fi 
  if [ "$Port3InternetoverLan" = "0" ]                                                                         
  then                                                                                                           
     if [ "$Port4Mode" = "EWAN1" ]
	 then
	     uci set firewall.block_lan2_ewan1=rule > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan1.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan1.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan1.src='LAN2' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan1.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan1.dest='EWAN1' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan2_ewan1 > /dev/null 2>&1
	 fi
     if [ "$Port5Mode" = "EWAN2" ]
	 then
	     uci set firewall.block_lan2_ewan2=rule > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan2.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan2.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan2.src='LAN2' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan2.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan2_ewan2.dest='EWAN2' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan2_ewan2 > /dev/null 2>&1
	 fi   
	 if [ "$Radio0StationEnable" = "1" ]
     then
	     uci set firewall.block_lan2_wifi_wan=rule > /dev/null 2>&1
		 uci set firewall.block_lan2_wifi_wan.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan2_wifi_wan.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan2_wifi_wan.src='LAN2' > /dev/null 2>&1
		 uci set firewall.block_lan2_wifi_wan.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan2_wifi_wan.dest='WIFI_WAN' > /dev/null 2>&1
	else
	    uci delete firewall.block_lan2_wifi_wan > /dev/null 2>&1 
    fi                                        
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then 
		   uci set firewall.block_lan2_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.src='LAN2' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.dest='CWAN1' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan2=rule > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan2.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan2.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan2.src='LAN2' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan2.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan2.dest='CWAN2' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan2_cwan1 > /dev/null 2>&1
		   uci delete firewall.block_lan2_cwan2 > /dev/null 2>&1
		fi    
	    if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci set firewall.block_lan2_cwan1_0=rule > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_0.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_0.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_0.src='LAN2' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_0.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_0.dest='CWAN1_0' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_1=rule > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_1.src='LAN2' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1_1.dest='CWAN1_1' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan2_cwan1_0 > /dev/null 2>&1
		   uci delete firewall.block_lan2_cwan1_1 > /dev/null 2>&1		
		fi
	    if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
		   uci set firewall.block_lan2_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.src='LAN2' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan2_cwan1.dest='CWAN1' > /dev/null 2>&1
		else
		    uci delete firewall.block_lan2_cwan1 > /dev/null 2>&1
		fi
	else
	  uci delete firewall.block_lan2_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan2_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan2_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan2_cwan1_1 > /dev/null 2>&1	   
	fi
   else
      uci delete firewall.block_lan2_ewan1 > /dev/null 2>&1
      uci delete firewall.block_lan2_ewan2 > /dev/null 2>&1  
	  uci delete firewall.block_lan2_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan2_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan2_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan2_cwan1_1 > /dev/null 2>&1
	  uci delete firewall.block_lan2_wifi_wan > /dev/null 2>&1
   fi 
   
  if [ "$Port4InternetoverLan" = "0" ]                                                                         
  then                                                                                                           
     if [ "$Port4Mode" = "EWAN1" ]
	 then
	     uci set firewall.block_lan3_ewan1=rule > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan1.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan1.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan1.src='LAN3' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan1.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan1.dest='EWAN1' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan3_ewan1 > /dev/null 2>&1
	 fi
     if [ "$Port5Mode" = "EWAN2" ]
	 then
	     uci set firewall.block_lan3_ewan2=rule > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan2.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan2.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan2.src='LAN3' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan2.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan3_ewan2.dest='EWAN2' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan3_ewan2 > /dev/null 2>&1
	 fi   
	 if [ "$Radio0StationEnable" = "1" ]
     then
	     uci set firewall.block_lan3_wifi_wan=rule > /dev/null 2>&1
		 uci set firewall.block_lan3_wifi_wan.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan3_wifi_wan.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan3_wifi_wan.src='LAN3' > /dev/null 2>&1
		 uci set firewall.block_lan3_wifi_wan.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan3_wifi_wan.dest='WIFI_WAN' > /dev/null 2>&1
	else
	    uci delete firewall.block_lan3_wifi_wan > /dev/null 2>&1 
    fi                                         
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then 
		   uci set firewall.block_lan3_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.src='LAN3' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.dest='CWAN1' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan2=rule > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan2.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan2.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan2.src='LAN3' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan2.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan2.dest='CWAN2' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan3_cwan1 > /dev/null 2>&1
		   uci delete firewall.block_lan3_cwan2 > /dev/null 2>&1
		fi    
	    if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci set firewall.block_lan3_cwan1_0=rule > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_0.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_0.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_0.src='LAN3' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_0.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_0.dest='CWAN1_0' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_1=rule > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_1.src='LAN3' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1_1.dest='CWAN1_1' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan3_cwan1_0 > /dev/null 2>&1
		   uci delete firewall.block_lan3_cwan1_1 > /dev/null 2>&1		
		fi
	    if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
		   uci set firewall.block_lan3_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.src='LAN3' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan3_cwan1.dest='CWAN1' > /dev/null 2>&1
		else
		    uci delete firewall.block_lan3_cwan1 > /dev/null 2>&1
		fi
	else
	  uci delete firewall.block_lan3_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan3_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan3_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan3_cwan1_1 > /dev/null 2>&1	
	fi
   else
      uci delete firewall.block_lan3_ewan1 > /dev/null 2>&1
      uci delete firewall.block_lan3_ewan2 > /dev/null 2>&1  
	  uci delete firewall.block_lan3_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan3_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan3_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan3_cwan1_1 > /dev/null 2>&1
	  uci delete firewall.block_lan3_wifi_wan > /dev/null 2>&1
   fi 
  if [ "$Port5InternetoverLan" = "0" ]                                                                         
  then                                                                                                           
     if [ "$Port4Mode" = "EWAN1" ]
	 then
	     uci set firewall.block_lan4_ewan1=rule > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan1.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan1.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan1.src='LAN4' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan1.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan1.dest='EWAN1' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan4_ewan1 > /dev/null 2>&1
	 fi
     if [ "$Port5Mode" = "EWAN2" ]
	 then
	     uci set firewall.block_lan4_ewan2=rule > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan2.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan2.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan2.src='LAN4' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan2.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan4_ewan2.dest='EWAN2' > /dev/null 2>&1
	 else
	      uci delete firewall.block_lan4_ewan2 > /dev/null 2>&1
	 fi    
	 if [ "$Radio0StationEnable" = "1" ]
     then
	     uci set firewall.block_lan4_wifi_wan=rule > /dev/null 2>&1
		 uci set firewall.block_lan4_wifi_wan.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_lan4_wifi_wan.proto='all' > /dev/null 2>&1
		 uci set firewall.block_lan4_wifi_wan.src='LAN4' > /dev/null 2>&1
		 uci set firewall.block_lan4_wifi_wan.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_lan4_wifi_wan.dest='WIFI_WAN' > /dev/null 2>&1
	else
	    uci delete firewall.block_lan4_wifi_wan > /dev/null 2>&1 
    fi                                         
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then 
		   uci set firewall.block_lan4_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.src='LAN4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.dest='CWAN1' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan2=rule > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan2.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan2.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan2.src='LAN4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan2.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan2.dest='CWAN2' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan4_cwan1 > /dev/null 2>&1
		   uci delete firewall.block_lan4_cwan2 > /dev/null 2>&1
		fi    
	    if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci set firewall.block_lan4_cwan1_0=rule > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_0.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_0.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_0.src='LAN4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_0.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_0.dest='CWAN1_0' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_1=rule > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_1.src='LAN4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1_1.dest='CWAN1_1' > /dev/null 2>&1
		else
		   uci delete firewall.block_lan4_cwan1_0 > /dev/null 2>&1
		   uci delete firewall.block_lan4_cwan1_1 > /dev/null 2>&1		
		fi
	    if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
		   uci set firewall.block_lan4_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.src='LAN4' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_lan4_cwan1.dest='CWAN1' > /dev/null 2>&1
		else
		    uci delete firewall.block_lan4_cwan1 > /dev/null 2>&1
		fi
	else
	  uci delete firewall.block_lan4_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan4_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan4_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan4_cwan1_1 > /dev/null 2>&1	   
	fi
   else
      uci delete firewall.block_lan4_ewan1 > /dev/null 2>&1
      uci delete firewall.block_lan4_ewan2 > /dev/null 2>&1  
	  uci delete firewall.block_lan4_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_lan4_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_lan4_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_lan4_cwan1_1 > /dev/null 2>&1
	  uci delete firewall.block_lan4_wifi_wan > /dev/null 2>&1
   fi 
  if [ "$InternetOverWifi" = "0" ]                                                                         
  then                                                                                                           
     if [ "$Port4Mode" = "EWAN1" ]
	 then
	     uci set firewall.block_wifi_ewan1=rule > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan1.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan1.proto='all' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan1.src='WIFI' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan1.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan1.dest='EWAN1' > /dev/null 2>&1
	 else
	      uci delete firewall.block_wifi_ewan1 > /dev/null 2>&1
	 fi
     if [ "$Port5Mode" = "EWAN2" ]
	 then
	     uci set firewall.block_wifi_ewan2=rule > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan2.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan2.proto='all' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan2.src='WIFI' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan2.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_wifi_ewan2.dest='EWAN2' > /dev/null 2>&1
	 else
	      uci delete firewall.block_wifi_ewan2 > /dev/null 2>&1
	 fi  
	 if [ "$Radio0StationEnable" = "1" ]
     then
	     uci set firewall.block_wifi_wifi_wan=rule > /dev/null 2>&1
		 uci set firewall.block_wifi_wifi_wan.family='ipv4' > /dev/null 2>&1
		 uci set firewall.block_wifi_wifi_wan.proto='all' > /dev/null 2>&1
		 uci set firewall.block_wifi_wifi_wan.src='WIFI' > /dev/null 2>&1
		 uci set firewall.block_wifi_wifi_wan.target='DROP' > /dev/null 2>&1
		 uci set firewall.block_wifi_wifi_wan.dest='WIFI_WAN' > /dev/null 2>&1
	else
	    uci delete firewall.block_wifi_wifi_wan > /dev/null 2>&1 
    fi                                           
	if [ "$EnableCellular" = "1" ]
    then
		if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
		then 
		   uci set firewall.block_wifi_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.src='WIFI' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.dest='CWAN1' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan2=rule > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan2.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan2.proto='all' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan2.src='WIFI' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan2.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan2.dest='CWAN2' > /dev/null 2>&1
		else
		   uci delete firewall.block_wifi_cwan1 > /dev/null 2>&1
		   uci delete firewall.block_wifi_cwan2 > /dev/null 2>&1
		fi    
	    if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then
		   uci set firewall.block_wifi_cwan1_0=rule > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_0.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_0.proto='all' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_0.src='WIFI' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_0.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_0.dest='CWAN1_0' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_1=rule > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_1.src='WIFI' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1_1.dest='CWAN1_1' > /dev/null 2>&1
		else
		   uci delete firewall.block_wifi_cwan1_0 > /dev/null 2>&1
		   uci delete firewall.block_wifi_cwan1_1 > /dev/null 2>&1		
		fi
	    if [ "$CellularOperationModelocal" = "singlecellularsinglesim" ]
		then
		   uci set firewall.block_wifi_cwan1=rule > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.family='ipv4' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.proto='all' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.src='WIFI' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.target='DROP' > /dev/null 2>&1
		   uci set firewall.block_wifi_cwan1.dest='CWAN1' > /dev/null 2>&1
		else
		    uci delete firewall.block_wifi_cwan1 > /dev/null 2>&1
		fi
	else
	  uci delete firewall.block_wifi_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_wifi_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_wifi_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_wifi_cwan1_1 > /dev/null 2>&1	
	fi
   else
      uci delete firewall.block_wifi_ewan1 > /dev/null 2>&1
      uci delete firewall.block_wifi_ewan2 > /dev/null 2>&1  
	  uci delete firewall.block_wifi_cwan1 > /dev/null 2>&1
	  uci delete firewall.block_wifi_cwan2 > /dev/null 2>&1    
	  uci delete firewall.block_wifi_cwan1_0 > /dev/null 2>&1
	  uci delete firewall.block_wifi_cwan1_1 > /dev/null 2>&1
	  uci delete firewall.block_wifi_wifi_wan > /dev/null 2>&1
   fi 
   uci commit firewall
}


SystemConfigFile="/etc/config/sysconfig"
MwanConfigFile="/etc/config/mwan3config"
simtmpfile="/tmp/simnumfile"
wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"

/etc/init.d/mwan3 stop 2>&1


ReadSystemConfigFile
ReadMwanConfigFile
UpdateWirelessConfig
UpdateNetworkConfig
UpdateMwanConfig
UpdateScheduledWifiOnOff

if [ "$EnableCellular" = "1" ]
then
#/etc/init.d/smstools3 stop
UpdateModemConfig
#/etc/init.d/smstools3 start
else
   uci set modem."${cellularwan1interface}".modemenable="0"
   uci set modem."${cellularwan1sim1interface}".modemenable="0"
   uci set modem."${cellularwan1sim2interface}".modemenable="0"
   uci set modem."${cellularwan2interface}".modemenable="0"
   uci set modem."${cellularwan3interface}".modemenable="0"
fi
UpdateFirewallConfig
UpdateInternetOverInterface

/root/InterfaceManager/script/SystemRestart.sh > /dev/null 2>&1 & 

exit 0
#~ #/bin/sleep 10

#~ /etc/init.d/network restart 2>&1

#~ /bin/sleep 40


#/root/InterfaceManager/script/InterfaceInitializer.sh boot

#~ /etc/init.d/firewall restart 2>&1 
#~ /etc/init.d/mwan3 start 2>&1
