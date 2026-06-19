#!/bin/sh

. /lib/functions.sh

ReadSystemConfigFile()
{
	config_load "$SystemConfigFile"

	#  Cellular
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
	config_get Manufacturerlocal2 sysconfig Manufacturer2
	config_get Model2 sysconfig model2
	config_get PortType2 sysconfig porttype2
	config_get VendorId2 sysconfig vendorid2
	config_get ProductId2 sysconfig productid2
	config_get DataPort2 sysconfig dataport2
	config_get ComPort2 sysconfig comport2
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
	config_get sim2pdp sysconfig sim2pdp
	config_get Sim2PinCode sysconfig sim2pincode
	config_get Sim2UserName sysconfig sim2username
	config_get Sim2Password sysconfig sim2password
	config_get sim2auth sysconfig sim2auth
	config_get EnableCellular sysconfig enablecellular
	config_get UsbBusPath1 sysconfig usbbuspath1
	config_get UsbBusPath2 sysconfig usbbuspath2
	config_get ActionInterval1 sysconfig actioninterval1
	config_get ActionInterval2 sysconfig actioninterval2
	config_get Protocol1 sysconfig protocol1
	config_get Protocol2 sysconfig protocol2
	config_get Sim1apntype sysconfig Sim1apntype
	config_get Sim2apntype sysconfig Sim2apntype
	
	#sms
	config_get SmsPort1 smsconfig smsport1
	config_get SmsEnable1 smsconfig smsenable1
	config_get SmsCenterNumber1 smsconfig smscenternumber1
	config_get DeviceId1 smsconfig smsdeviceid
	config_get ApiKey1 smsconfig smsapikey
	config_get SmsPort2 smsconfig smsport2
	config_get SmsEnable2 smsconfig smsenable2
	config_get SmsCenterNumber2 smsconfig smscenternumber2
	config_get DeviceId2 smsconfig deviceid2
	config_get ApiKey2 smsconfig apikey2
	config_get SmsResponseSenderEnable1 smsconfig smsresponsesenderenable
	config_get SmsResponseSenderEnable2 smsconfig smsresponsesenderenable
	config_get SmsResponseServerEnable1 smsconfig smsresponseserverenable
	config_get SmsResponseServerEnable2 smsconfig smsresponseserverenable
	config_get SmsServerNumber1 smsconfig smsservernumber1
	config_get SmsServerNumber2 smsconfig smsservernumber2
	config_get SmsServerNumber3 smsconfig smsservernumber3
	config_get SmsServerNumber4 smsconfig smsservernumber4        
	config_get SmsServerNumber5 smsconfig smsservernumber5
	
	#5g
	config_get support5gnetwork sysconfig support5gnetwork
	config_get networkingmode1 sysconfig networkingmode1
	config_get autoconfigsim1 sysconfig autoconfigsim1
	config_get rattype1 sysconfig rattype1
	config_get nsa_bands1 sysconfig nsa_bands1
	config_get sa_bands1 sysconfig sa_bands1
	config_get ComPortSymLink1 sysconfig ComPortSymLink1
	config_get networkingmode2 sysconfig networkingmode2
	config_get autoconfigsim2 sysconfig autoconfigsim2
	config_get rattype2 sysconfig rattype2
	config_get nsa_bands2 sysconfig nsa_bands2
	config_get sa_bands2 sysconfig sa_bands2
	config_get ComPortSymLink2 sysconfig ComPortSymLink2

}

ReadSystemGpioFile()
{
   	config_load "$SystemGpioConfig"
	config_get SimSelectGpio gpio simselectgpio
	config_get Sim1SelectValue gpio sim1selectvalue
	config_get Sim2SelectValue gpio sim2selectvalue
}

UpdateFirewallConfig()
{
	IpsecEnable=$(uci get vpnconfig1.general.enableipsecgeneral)
	InternetOverWifi=$(uci get sysconfig.wificonfig.InternetOverWifi)
	wifi1enable=$(uci get sysconfig.wificonfig.wifi1enable)
	guestwifienable2=$(uci get sysconfig.guestwifi.guestwifienable2)
	guestwifienable5=$(uci get sysconfig.guestwifi.guestwifienable5)
	
	if [ "$EnableCellular" = "1" ]
    then
		uci delete firewall.cwan1_0 > /dev/null 2>&1
		uci delete firewall.cwan1_1 > /dev/null 2>&1
		uci delete firewall.cwan1 > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c1_replies > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c2_replies > /dev/null 2>&1
		uci delete firewall.wan6c1 > /dev/null 2>&1
		uci delete firewall.wan6c2 > /dev/null 2>&1
		if [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
		then

			if [ "$Pdp1" = "IPV4" ] || [ "$Pdp1" = "IPV4V6" ];then
				uci set firewall.cwan1_0=zone
				uci set firewall.cwan1_0.name="$cellularwan1sim1interface"
				uci set firewall.cwan1_0.input="REJECT"
				uci set firewall.cwan1_0.output="ACCEPT"
				uci set firewall.cwan1_0.forward="ACCEPT"
				#don't set the network as below
				uci set firewall.cwan1_0.network="$cellularwan1sim1interface"
				uci set firewall.cwan1_0.masq="1"
				uci set firewall.cwan1_0.mtu_fix="1"
				uci set firewall.cwan1_0.extra_src="-m policy --dir in --pol none"
				uci set firewall.cwan1_0.extra_dest="-m policy --dir out --pol none"
			fi
			if [ "$Pdp1" = "IPV6" ];then
				uci set firewall.$cellular1wan6interface=zone
				uci set firewall.$cellular1wan6interface.name="$cellular1wan6interface"
				uci set firewall.$cellular1wan6interface.input="REJECT"
				uci set firewall.$cellular1wan6interface.output="ACCEPT"
				uci set firewall.$cellular1wan6interface.forward="ACCEPT"
				uci set firewall.$cellular1wan6interface.network="$cellular1wan6interface"
				uci set firewall.$cellular1wan6interface.masq="1"
				uci set firewall.$cellular1wan6interface.mtu_fix="1"
				uci set firewall.$cellular1wan6interface.extra_src="-m policy --dir in --pol none"
				uci set firewall.$cellular1wan6interface.extra_dest="-m policy --dir out --pol none"				
			fi
			if [ "$Pdp1" = "IPV6" ] || [ "$Pdp1" = "IPV4V6" ];then
				uci set firewall.udp_DHCPv6c1_replies=rule
				uci set firewall.udp_DHCPv6c1_replies.target='ACCEPT'
				uci set firewall.udp_DHCPv6c1_replies.src="$cellular1wan6interface"
				uci set firewall.udp_DHCPv6c1_replies.proto='udp'
				uci set firewall.udp_DHCPv6c1_replies.dest_port='546'
				uci set firewall.udp_DHCPv6c1_replies.name='Allow DHCPv6c1 replies'
				uci set firewall.udp_DHCPv6c1_replies.family='ipv6'
				uci set firewall.udp_DHCPv6c1_replies.src_port='547'  
			fi 
			      
			
		else
			uci delete firewall.cwan1_0 > /dev/null 2>&1
			uci delete firewall.cwan1_1 > /dev/null 2>&1
			uci delete firewall.cwan1 > /dev/null 2>&1
			uci delete firewall.cwan2 > /dev/null 2>&1
			uci delete firewall.udp_DHCPv6c1_replies > /dev/null 2>&1
			uci delete firewall.udp_DHCPv6c2_replies > /dev/null 2>&1
			uci delete firewall.wan6c1 > /dev/null 2>&1
			if [ "$Pdp1" = "IPV4" ] || [ "$Pdp1" = "IPV4V6" ];then
				uci set firewall.cwan1=zone
				uci set firewall.cwan1.name="$cellularwan1interface"
				uci set firewall.cwan1.input="REJECT"
				uci set firewall.cwan1.output="ACCEPT"
				uci set firewall.cwan1.forward="ACCEPT"
				#don't set the network as below
				#uci set firewall.cwan1.network="$cellularwan1interface $cellular1wan6interface"
				uci set firewall.cwan1.network="$cellularwan1interface"
				uci set firewall.cwan1.masq="1"
				uci set firewall.cwan1.mtu_fix="1"
				uci set firewall.cwan1.extra_src="-m policy --dir in --pol none"
				uci set firewall.cwan1.extra_dest="-m policy --dir out --pol none"
			fi
			if [ "$Pdp1" = "IPV6" ];then
				uci set firewall.$cellular1wan6interface=zone
				uci set firewall.$cellular1wan6interface.name="$cellular1wan6interface"
				uci set firewall.$cellular1wan6interface.input="REJECT"
				uci set firewall.$cellular1wan6interface.output="ACCEPT"
				uci set firewall.$cellular1wan6interface.forward="ACCEPT"
				uci set firewall.$cellular1wan6interface.network="$cellular1wan6interface"
				uci set firewall.$cellular1wan6interface.masq="1"
				uci set firewall.$cellular1wan6interface.mtu_fix="1"
				uci set firewall.$cellular1wan6interface.extra_src="-m policy --dir in --pol none"
				uci set firewall.$cellular1wan6interface.extra_dest="-m policy --dir out --pol none"	
			fi
			if [ "$Pdp1" = "IPV6" ] || [ "$Pdp1" = "IPV4V6" ];then	
				uci set firewall.udp_DHCPv6c1_replies=rule
				uci set firewall.udp_DHCPv6c1_replies.target='ACCEPT'
				uci set firewall.udp_DHCPv6c1_replies.src="$cellular1wan6interface"
				uci set firewall.udp_DHCPv6c1_replies.proto='udp'
				uci set firewall.udp_DHCPv6c1_replies.dest_port='546'
				uci set firewall.udp_DHCPv6c1_replies.name='Allow DHCPv6c1 replies'
				uci set firewall.udp_DHCPv6c1_replies.family='ipv6'
				uci set firewall.udp_DHCPv6c1_replies.src_port='547'  
			fi 
		fi
	else
		uci delete firewall.cwan1_0 > /dev/null 2>&1
		uci delete firewall.cwan1_1 > /dev/null 2>&1
		uci delete firewall.cwan1 > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c1_replies > /dev/null 2>&1
		uci delete firewall.udp_DHCPv6c2_replies > /dev/null 2>&1
		uci delete firewall.wan6c1 > /dev/null 2>&1
		uci delete firewall.wan6c2 > /dev/null 2>&1
	
	fi

/root/InterfaceManager/script/update_firewall.sh
	uci commit firewall
	ubus call firewall reload
}

UpdateModemConfig()
{
	
	#failover/balanced policy for mwan3.
	policy_type=$(uci get mwan3config.general.select)
	Cwan1Priority=$(uci get mwan3config."${cellularwan1interface}".wanpriority)
	Cwan2Priority=$(uci get mwan3config."${cellularwan2interface}".wanpriority)
	Cwan1sim1Priority=$(uci get mwan3config."${cellularwan1sim1interface}".wanpriority)
	Cwan1sim2Priority=$(uci get mwan3config."${cellularwan1sim2interface}".wanpriority)
	if [ "$CellularOperationModelocal" = "dualcellularsinglesim" ]
	then	
		######################################################
		uci set modem.cellularmodule.singlesimsinglemodule="0"
		uci set modem.cellularmodule.singlesimdualmodule="1"
		uci set modem.cellularmodule.dualsimsinglemodule="0"
		uci set modem."${cellularwan1interface}".modemenable="1"
		uci set modem."${cellularwan1sim1interface}".modemenable="0"
		uci set modem."${cellularwan1sim2interface}".modemenable="0"
		uci set modem."${cellularwan2interface}".modemenable="1"
		uci set modem."${cellularwan3interface}".modemenable="0"
		#This is set in hotplug script
		uci set modem."${cellularwan1interface}".device="$DataPort1"
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
		uci set modem."${cellularwan1interface}".pdp="$Pdp1"
		uci set modem."${cellularwan1interface}".username="$UserName1"
		uci set modem."${cellularwan1interface}".password="$Password1"
		uci set modem."${cellularwan1interface}".auth="$Auth1"
		uci set modem."${cellularwan1interface}".apntype="$Sim1apntype"
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1interface}".metric="$Cwan1Priority"
		fi
		#uci set modem."${cellularwan1interface}".usbbuspath="$UsbBusPath1"
		uci set modem."${cellularwan1interface}".action1waitinterval="$ActionInterval1"   
		uci set modem."${cellularwan1interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
		uci set modem."${cellularwan1interface}".smsresponseserverenable="$SmsResponseServerEnable1"
		uci set modem."${cellularwan1interface}".smsservernumber1="$SmsServerNumber1"
		uci set modem."${cellularwan1interface}".smsservernumber2="$SmsServerNumber2"
		uci set modem."${cellularwan1interface}".smsservernumber3="$SmsServerNumber3"
		uci set modem."${cellularwan1interface}".smsservernumber4="$SmsServerNumber4"
		uci set modem."${cellularwan1interface}".smsservernumber5="$SmsServerNumber5"
		uci set modem."${cellularwan2interface}".device="$DataPort2"
		uci set modem."${cellularwan2interface}".smsport="$SmsPort2"
		uci set modem."${cellularwan2interface}".smsenable="$SmsEnable1"
		uci set modem."${cellularwan2interface}".smsc="$SmsCenterNumber1"
		uci set modem."${cellularwan2interface}".smsdeviceid="$DeviceId1"
		uci set modem."${cellularwan2interface}".smsapikey="$ApiKey1"
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
		uci set modem."${cellularwan2interface}".pdp="$sim2pdp"
		uci set modem."${cellularwan2interface}".username="$sim2username"
		uci set modem."${cellularwan2interface}".password="$sim2password"
		uci set modem."${cellularwan2interface}".auth="$sim2auth"
		uci set modem."${cellularwan2interface}".apntype="$Sim2apntype"
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan2interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan2interface}".metric="$Cwan2Priority"
		fi
		uci set modem."${cellularwan2interface}".action1waitinterval="$ActionInterval2"
		uci set modem."${cellularwan2interface}".smsresponsesenderenable="$SmsResponseSenderEnable2"
		uci set modem."${cellularwan2interface}".smsresponseserverenable="$SmsResponseServerEnable2"
		uci set modem."${cellularwan2interface}".smsservernumber1="$SmsServerNumber1"
		uci set modem."${cellularwan2interface}".smsservernumber2="$SmsServerNumber2"
		uci set modem."${cellularwan2interface}".smsservernumber3="$SmsServerNumber3"
		uci set modem."${cellularwan2interface}".smsservernumber4="$SmsServerNumber4"
		uci set modem."${cellularwan2interface}".smsservernumber5="$SmsServerNumber5"

		
	elif [ "$CellularOperationModelocal" = "singlecellulardualsim" ]
    then
		uci set modem.cellularmodule.singlesimsinglemodule="0"
		uci set modem.cellularmodule.singlesimdualmodule="0"
		uci set modem.cellularmodule.dualsimsinglemodule="1"
		uci set modem."${cellularwan1interface}".modemenable="0"
		uci set modem."${cellularwan1sim1interface}".modemenable="1"
		uci set modem."${cellularwan1sim2interface}".modemenable="1"
		uci set modem."${cellularwan1sim1interface}".actionmanagerenable="0"
		uci set modem."${cellularwan1sim2interface}".actionmanagerenable="0"
		uci set modem."${cellularwan2interface}".modemenable="0"
		uci set modem."${cellularwan1sim1interface}".device="$DataPort1"
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
		uci set modem."${cellularwan1sim1interface}".pdp="$Pdp1"
		uci set modem."${cellularwan1sim1interface}".username="$UserName1"
		uci set modem."${cellularwan1sim1interface}".password="$Password1"
		uci set modem."${cellularwan1sim1interface}".auth="$Auth1"
		uci set modem."${cellularwan1sim1interface}".apntype="$Sim1apntype"
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1sim1interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1sim1interface}".metric="$Cwan1sim1Priority"
		fi

		uci set modem."${cellularwan1sim1interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
		uci set modem."${cellularwan1sim1interface}".smsresponseserverenable="$SmsResponseServerEnable1"
		uci set modem."${cellularwan1sim1interface}".smsservernumber1="$SmsServerNumber1"
		uci set modem."${cellularwan1sim1interface}".smsservernumber2="$SmsServerNumber2"
		uci set modem."${cellularwan1sim1interface}".smsservernumber3="$SmsServerNumber3"
		uci set modem."${cellularwan1sim1interface}".smsservernumber4="$SmsServerNumber4"
		uci set modem."${cellularwan1sim1interface}".smsservernumber5="$SmsServerNumber5"
		uci set modem."${cellularwan1sim2interface}".device="$DataPort1"
		uci set modem."${cellularwan1sim2interface}".smsport="$SmsPort1"
		uci set modem."${cellularwan1sim2interface}".smsenable="$SmsEnable1"
		uci set modem."${cellularwan1sim2interface}".smsc="$SmsCenterNumber2"
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
		uci set modem."${cellularwan1sim2interface}".pdp="$sim2pdp"
		uci set modem."${cellularwan1sim2interface}".username="$sim2username"
		uci set modem."${cellularwan1sim2interface}".password="$sim2password"
		uci set modem."${cellularwan1sim2interface}".auth="$sim2auth"
		uci set modem."${cellularwan1sim2interface}".apntype="$Sim2apntype"
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1sim2interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1sim2interface}".metric="$Cwan1sim2Priority"
		fi

		uci set modem."${cellularwan1sim2interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
		uci set modem."${cellularwan1sim2interface}".smsresponseserverenable="$SmsResponseServerEnable1"
		uci set modem."${cellularwan1sim2interface}".smsservernumber1="$SmsServerNumber1"
		uci set modem."${cellularwan1sim2interface}".smsservernumber2="$SmsServerNumber2"
		uci set modem."${cellularwan1sim2interface}".smsservernumber3="$SmsServerNumber3"
		uci set modem."${cellularwan1sim2interface}".smsservernumber4="$SmsServerNumber4"
		uci set modem."${cellularwan1sim2interface}".smsservernumber5="$SmsServerNumber5"
	else
		uci set modem.cellularmodule.singlesimsinglemodule="1"
		uci set modem.cellularmodule.singlesimdualmodule="0"
		uci set modem.cellularmodule.dualsimsinglemodule="0"
		uci set modem."${cellularwan1interface}".modemenable="1"
		uci set modem."${cellularwan1sim1interface}".modemenable="0"
		uci set modem."${cellularwan1sim2interface}".modemenable="0"
		uci set modem."${cellularwan2interface}".modemenable="0"
		uci set modem."${cellularwan1interface}".device="$DataPort1"
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
		uci set modem."${cellularwan1interface}".pdp="$Pdp1"
		uci set modem."${cellularwan1interface}".username="$UserName1"
		uci set modem."${cellularwan1interface}".password="$Password1"
		uci set modem."${cellularwan1interface}".auth="$Auth1"
		uci set modem."${cellularwan1interface}".apntype="$Sim1apntype"
		if [ "$policy_type" = "balanced" ]
		then
			uci set modem."${cellularwan1interface}".metric="1"
		elif [ "$policy_type" = "failover" ]
		then
			uci set modem."${cellularwan1interface}".metric="$Cwan1Priority"
		fi
		uci set modem."${cellularwan1interface}".action1waitinterval="$ActionInterval1"   

		uci set modem."${cellularwan1interface}".smsresponsesenderenable="$SmsResponseSenderEnable1"
		uci set modem."${cellularwan1interface}".smsresponseserverenable="$SmsResponseServerEnable1"
		uci set modem."${cellularwan1interface}".smsservernumber1="$SmsServerNumber1"
		uci set modem."${cellularwan1interface}".smsservernumber2="$SmsServerNumber2"
		uci set modem."${cellularwan1interface}".smsservernumber3="$SmsServerNumber3"
		uci set modem."${cellularwan1interface}".smsservernumber4="$SmsServerNumber4"
		uci set modem."${cellularwan1interface}".smsservernumber5="$SmsServerNumber5"		
	fi
	
	uci commit modem
	#ubus call modem reload
}

cellularwan1interface="CWAN1"
cellularwan2interface="CWAN2"
cellularwan3interface="CWAN3"
cellularwan1sim1interface="CWAN1_0"
cellularwan1sim2interface="CWAN1_1"

#IPV6 Variables 
cellular1wan6interface="wan6c1"
cellular2wan6interface="wan6c2"

wifiinterface="ra0"
wifi5interface="rai0"
wifiap="ra0_ap"
wifi5ap="rai0_ap"
wifista="sta"
wifiwaninterface="WIFI_WAN"

#To change guest name -- 
wifiap1="ra1"
wifiap51="rai1"

SystemConfigFile="/etc/config/sysconfig"
SystemGpioConfig="/etc/config/systemgpio"
simtmpfile="/tmp/simnumfile"
SimNumFile="/tmp/simnumfile"

Gcom2Gonly="/etc/gcom/set2gonly.gcom"
Gcom4Gonly="/etc/gcom/set4gonly.gcom"
GcomAutoonly="/etc/gcom/setauto.gcom"
set_nr5g_disable_mode="/etc/gcom/set_nr5g_disable_mode.gcom"
set_mode_pref="/etc/gcom/set_mode_pref.gcom"
set_nsa_bands="/etc/gcom/set_nsa_bands.gcom"
set_sa_bands="/etc/gcom/set_sa_bands.gcom"
nr5g_disable_mode="/etc/gcom/nr5g_disable_mode.gcom"
mode_pref="/etc/gcom/mode_pref.gcom"
nsa_bands="/etc/gcom/nsa_bands.gcom"
sa_bands="/etc/gcom/sa_bands.gcom"

# Read sysconfig, systemgpio & update the firewall config file.
ReadSystemConfigFile
ReadSystemGpioFile
UpdateFirewallConfig

#If cellular is enabled then restart the sms init script and update the modem config file.
if [ "$EnableCellular" = "1" ]
then
	/etc/init.d/smstools3 stop
	
	#Read from sysconfig & update to modem config file.
	UpdateModemConfig
	
	/etc/init.d/smstools3 start
else
	uci set modem."${cellularwan1interface}".modemenable="0"
	uci set modem."${cellularwan1sim1interface}".modemenable="0"
	uci set modem."${cellularwan1sim2interface}".modemenable="0"
	uci set modem."${cellularwan2interface}".modemenable="0"
	uci set modem."${cellularwan3interface}".modemenable="0"
	
	uci commit modem
fi

exit 0
