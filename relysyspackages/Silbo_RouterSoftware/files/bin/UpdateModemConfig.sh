#!/bin/sh
. /lib/functions.sh



modemconfigUCIPath=/etc/config/modemconfig
modemconfigsection="modemconfig"


config_load "$modemconfigUCIPath"
config_get cellularmodem2 "$modemconfigsection" cellularmodem2
config_get cellularmodem1 "$modemconfigsection" cellularmodem1

config_get usbbuspath1  "$modemconfigsection" usbbuspath1
config_get usbbuspath2  "$modemconfigsection" usbbuspath2

uci set sysconfig.sysconfig.usbbuspath1="$usbbuspath1"
uci set sysconfig.sysconfig.usbbuspath2="$usbbuspath2"

###################Modem 1 Custom #############################
if [ "$cellularmodem1" = "custom" ] 
then

config_get Manufacturer1 "$modemconfigsection" Manufacturer1
config_get model1 "$modemconfigsection" model1
config_get porttype1 "$modemconfigsection" porttype1
config_get vendorid1 "$modemconfigsection" vendorid1
config_get productid1 "$modemconfigsection" productid1
config_get dataport1 "$modemconfigsection" dataport1
config_get comport1 "$modemconfigsection" comport1
config_get smsport1 "$modemconfigsection" smsport1

uci set sysconfig.sysconfig.cellularmodem1="$Manufacturer1":"$model1"
uci set sysconfig.sysconfig.Manufacturer1="$Manufacturer1"
uci set sysconfig.sysconfig.model1="$model1"
uci set sysconfig.sysconfig.porttype1="$porttype1"
uci set sysconfig.sysconfig.vendorid1="$vendorid1"
uci set sysconfig.sysconfig.productid1="$productid1"
uci set sysconfig.sysconfig.dataport1="$dataport1"
uci set sysconfig.sysconfig.comport1="$comport1"
uci set sysconfig.sysconfig.smsport1="$smsport1"
fi

#########################QuectelEC200T MOdem1##########################

if [ "$cellularmodem1" = "QuectelEC200T" ] 
then
config_get QuectelEC200TManufacturer1 "$modemconfigsection" QuectelEC200TManufacturer1
config_get QuectelEC200Tmodel1 "$modemconfigsection" QuectelEC200Tmodel1
config_get QuectelEC200Tporttype1 "$modemconfigsection" QuectelEC200Tporttype1
config_get QuectelEC200Tvendorid1 "$modemconfigsection" QuectelEC200Tvendorid1
config_get QuectelEC200Tproductid1 "$modemconfigsection" QuectelEC200Tproductid1
config_get QuectelEC200Tdataport1 "$modemconfigsection" QuectelEC200Tdataport1
config_get QuectelEC200Tcomport1 "$modemconfigsection" QuectelEC200Tcomport1
config_get QuectelEC200Tsmsport1 "$modemconfigsection" QuectelEC200Tsmsport1

uci set sysconfig.sysconfig.cellularmodem1="$cellularmodem1"
uci set sysconfig.sysconfig.Manufacturer1="$QuectelEC200TManufacturer1"
uci set sysconfig.sysconfig.model1="$QuectelEC200Tmodel1"
uci set sysconfig.sysconfig.porttype1="$QuectelEC200Tporttype1"
uci set sysconfig.sysconfig.vendorid1="$QuectelEC200Tvendorid1"
uci set sysconfig.sysconfig.productid1="$QuectelEC200Tproductid1"
uci set sysconfig.sysconfig.dataport1="$QuectelEC200Tdataport1"
uci set sysconfig.sysconfig.comport1="$QuectelEC200Tcomport1"
uci set sysconfig.sysconfig.smsport1="$QuectelEC200Tsmsport1"
fi 





#########################QuectelEC200A MOdem1##########################

if [ "$cellularmodem1" = "QuectelEC200A" ] 
then
config_get QuectelEC200AManufacturer1 "$modemconfigsection" QuectelEC200AManufacturer1
config_get QuectelEC200Amodel1 "$modemconfigsection" QuectelEC200Amodel1
config_get QuectelEC200Aporttype1 "$modemconfigsection" QuectelEC200Aporttype1
config_get QuectelEC200Avendorid1 "$modemconfigsection" QuectelEC200Avendorid1
config_get QuectelEC200Aproductid1 "$modemconfigsection" QuectelEC200Aproductid1
config_get QuectelEC200Adataport1 "$modemconfigsection" QuectelEC200Adataport1
config_get QuectelEC200Acomport1 "$modemconfigsection" QuectelEC200Acomport1
config_get QuectelEC200Asmsport1 "$modemconfigsection" QuectelEC200Asmsport1

uci set sysconfig.sysconfig.cellularmodem1="$cellularmodem1"
uci set sysconfig.sysconfig.Manufacturer1="$QuectelEC200AManufacturer1"
uci set sysconfig.sysconfig.model1="$QuectelEC200Amodel1"
uci set sysconfig.sysconfig.porttype1="$QuectelEC200Aporttype1"
uci set sysconfig.sysconfig.vendorid1="$QuectelEC200Avendorid1"
uci set sysconfig.sysconfig.productid1="$QuectelEC200Aproductid1"
uci set sysconfig.sysconfig.dataport1="$QuectelEC200Adataport1"
uci set sysconfig.sysconfig.comport1="$QuectelEC200Acomport1"
uci set sysconfig.sysconfig.smsport1="$QuectelEC200Asmsport1"
fi 

#########################QuectelEC25E MOdem1##########################

if [ "$cellularmodem1" = "QuectelEC25E" ] 
then
config_get QuectelEC25EManufacturer1 "$modemconfigsection" QuectelEC25EManufacturer1
config_get QuectelEC25Emodel1 "$modemconfigsection" QuectelEC25Emodel1
config_get QuectelEC25Eporttype1 "$modemconfigsection" QuectelEC25Eporttype1
config_get QuectelEC25Evendorid1 "$modemconfigsection" QuectelEC25Evendorid1
config_get QuectelEC25Eproductid1 "$modemconfigsection" QuectelEC25Eproductid1
config_get QuectelEC25Edataport1 "$modemconfigsection" QuectelEC25Edataport1
config_get QuectelEC25Ecomport1 "$modemconfigsection" QuectelEC25Ecomport1
config_get QuectelEC25Esmsport1 "$modemconfigsection" QuectelEC25Esmsport1

uci set sysconfig.sysconfig.cellularmodem1="$cellularmodem1"
uci set sysconfig.sysconfig.Manufacturer1="$QuectelEC25EManufacturer1"
uci set sysconfig.sysconfig.model1="$QuectelEC25Emodel1"
uci set sysconfig.sysconfig.porttype1="$QuectelEC25Eporttype1"
uci set sysconfig.sysconfig.vendorid1="$QuectelEC25Evendorid1"
uci set sysconfig.sysconfig.productid1="$QuectelEC25Eproductid1"
uci set sysconfig.sysconfig.dataport1="$QuectelEC25Edataport1"
uci set sysconfig.sysconfig.comport1="$QuectelEC25Ecomport1"
uci set sysconfig.sysconfig.smsport1="$QuectelEC25Esmsport1"
fi

#########################QuectelEC20 MOdem1##########################

if [ "$cellularmodem1" = "QuectelEC20" ] 
then
config_get QuectelEC20Manufacturer1 "$modemconfigsection" QuectelEC20Manufacturer1
config_get QuectelEC20model1 "$modemconfigsection" QuectelEC20model1
config_get QuectelEC20porttype1 "$modemconfigsection" QuectelEC20porttype1
config_get QuectelEC20vendorid1 "$modemconfigsection" QuectelEC20vendorid1
config_get QuectelEC20productid1 "$modemconfigsection" QuectelEC20productid1
config_get QuectelEC20dataport1 "$modemconfigsection" QuectelEC20dataport1
config_get QuectelEC20comport1 "$modemconfigsection" QuectelEC20comport1
config_get QuectelEC20smsport1 "$modemconfigsection" QuectelEC20smsport1

uci set sysconfig.sysconfig.cellularmodem1="$cellularmodem1"
uci set sysconfig.sysconfig.Manufacturer1="$QuectelEC20Manufacturer1"
uci set sysconfig.sysconfig.model1="$QuectelEC20model1"
uci set sysconfig.sysconfig.porttype1="$QuectelEC20porttype1"
uci set sysconfig.sysconfig.vendorid1="$QuectelEC20vendorid1"
uci set sysconfig.sysconfig.productid1="$QuectelEC20productid1"
uci set sysconfig.sysconfig.dataport1="$QuectelEC20dataport1"
uci set sysconfig.sysconfig.comport1="$QuectelEC20comport1"
uci set sysconfig.sysconfig.smsport1="$QuectelEC20smsport1"
fi 


#########################QuectelEC25E MOdem2##########################

if [ "$cellularmodem2" = "custom" ] 
then
config_get Manufacturer2 "$modemconfigsection" Manufacturer2
config_get model2 "$modemconfigsection" model2
config_get porttype2 "$modemconfigsection" porttype2
config_get vendorid2 "$modemconfigsection" vendorid2
config_get productid2 "$modemconfigsection" productid2
config_get dataport2 "$modemconfigsection" dataport2
config_get comport2 "$modemconfigsection" comport2
config_get smsport2 "$modemconfigsection" smsport2

uci set sysconfig.sysconfig.cellularmodem2="$Manufacturer2":"$model2"
uci set sysconfig.sysconfig.Manufacturer2="$Manufacturer2"
uci set sysconfig.sysconfig.model2="$model2"
uci set sysconfig.sysconfig.porttype2="$porttype2"
uci set sysconfig.sysconfig.vendorid2="$vendorid2"
uci set sysconfig.sysconfig.productid2="$productid2"
uci set sysconfig.sysconfig.dataport2="$dataport2"
uci set sysconfig.sysconfig.comport2="$comport2"
uci set sysconfig.sysconfig.smsport2="$smsport2"
fi

if [ "$cellularmodem2" = "QuectelEC200T" ] 
then
config_get QuectelEC200TManufacturer2 "$modemconfigsection" QuectelEC200TManufacturer2
config_get QuectelEC200Tmodel2 "$modemconfigsection" QuectelEC200Tmodel2
config_get QuectelEC200Tporttype2 "$modemconfigsection" QuectelEC200Tporttype2
config_get QuectelEC200Tvendorid2 "$modemconfigsection" QuectelEC200Tvendorid2
config_get QuectelEC200Tproductid2 "$modemconfigsection" QuectelEC200Tproductid2
config_get QuectelEC200Tdataport2 "$modemconfigsection" QuectelEC200Tdataport2
config_get QuectelEC200Tcomport2 "$modemconfigsection" QuectelEC200Tcomport2
config_get QuectelEC200Tsmsport2 "$modemconfigsection" QuectelEC200Tsmsport2

uci set sysconfig.sysconfig.cellularmodem2="$cellularmodem2"
uci set sysconfig.sysconfig.Manufacturer2="$QuectelEC200TManufacturer2"
uci set sysconfig.sysconfig.model2="$QuectelEC200Tmodel2"
uci set sysconfig.sysconfig.porttype2="$QuectelEC200Tporttype2"
uci set sysconfig.sysconfig.vendorid2="$QuectelEC200Tvendorid2"
uci set sysconfig.sysconfig.productid2="$QuectelEC200Tproductid2"
uci set sysconfig.sysconfig.dataport2="$QuectelEC200Tdataport2"
uci set sysconfig.sysconfig.comport2="$QuectelEC200Tcomport2"
uci set sysconfig.sysconfig.smsport2="$QuectelEC200Tsmsport2"
fi 


if [ "$cellularmodem2" = "QuectelEC25E" ] 
then
config_get QuectelEC25EManufacturer2 "$modemconfigsection" QuectelEC25EManufacturer2
config_get QuectelEC25Emodel2 "$modemconfigsection" QuectelEC25Emodel2
config_get QuectelEC25Eporttype2 "$modemconfigsection" QuectelEC25Eporttype2
config_get QuectelEC25Evendorid2 "$modemconfigsection" QuectelEC25Evendorid2
config_get QuectelEC25Eproductid2 "$modemconfigsection" QuectelEC25Eproductid2
config_get QuectelEC25Edataport2 "$modemconfigsection" QuectelEC25Edataport2
config_get QuectelEC25Ecomport2 "$modemconfigsection" QuectelEC25Ecomport2
config_get QuectelEC25Esmsport2 "$modemconfigsection" QuectelEC25Esmsport2

uci set sysconfig.sysconfig.cellularmodem2="$cellularmodem2"
uci set sysconfig.sysconfig.Manufacturer2="$QuectelEC25EManufacturer2"
uci set sysconfig.sysconfig.model2="$QuectelEC25Emodel2"
uci set sysconfig.sysconfig.porttype2="$QuectelEC25Eporttype2"
uci set sysconfig.sysconfig.vendorid2="$QuectelEC25Evendorid2"
uci set sysconfig.sysconfig.productid2="$QuectelEC25Eproductid2"
uci set sysconfig.sysconfig.dataport2="$QuectelEC25Edataport2"
uci set sysconfig.sysconfig.comport2="$QuectelEC25Ecomport2"
uci set sysconfig.sysconfig.smsport2="$QuectelEC25Esmsport2"
fi

uci commit sysconfig

echo "{\"code\":\"0\",\"output\":\"Updated Configurations\"}"
