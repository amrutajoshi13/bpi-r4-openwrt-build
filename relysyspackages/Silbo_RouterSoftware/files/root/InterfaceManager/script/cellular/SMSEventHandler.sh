#!/bin/sh

. /lib/functions.sh

#
# PKG_RELEASE: 1.01
#

# Input arguments and Default Parameters
SMSEventType="$1"
IncomingSMSFile="$2"
MaxReceivedSMS=20
MaxSentSMS=20
MaxFailedSMS=20
ReceivedSMSDir="/var/spool/sms/incoming"
SentSMSDir="/var/spool/sms/sent"
FailedSMSDir="/var/spool/sms/failed"
OutgoingSMSDir="/var/spool/sms/outgoing/"
statCmd="/usr/bin/stat"
ModemConfig="/etc/config/modem"
SysConfig="/etc/config/sysconfig"
#validreceiverflag = 0 

source /tmp/InterfaceManager/status/ports.txt
source /tmp/InterfaceManager/status/Dataport.txt

#log file for nms
LOG_DIR=/root/NMS_Scripts/log/
LOG_FILE=nms_log_usage.txt
MAX_FILES=2
MAX_SIZE=500

memory_info=$(free -m | awk 'NR==2{print $2}')
memory_used=$(free -m | awk 'NR==2{print $3}')
memory_free=$(free -m | awk 'NR==2{print $4}')
memory_shrd=$(free -m | awk 'NR==2{print $5}')
memory_buff=$(free -m | awk 'NR==2{print $6}')
memory_available=$(free -m | awk 'NR==2{print $7}')

echo "Checking log directory: $LOG_DIR"
# check if the log directory exists, create it if it doesn't
if [ ! -d "$LOG_DIR" ]; then
  echo "Creating log directory: $LOG_DIR"
  mkdir -p "$LOG_DIR"
fi
echo "Checking log file: $LOG_DIR/$LOG_FILE"
# check if the log file exists, create it if it doesn't
if [ ! -f "$LOG_DIR/$LOG_FILE" ]; then
  echo "Creating log file: $LOG_DIR/$LOG_FILE"
  touch "$LOG_DIR/$LOG_FILE"
fi
echo "Checking log file size: $LOG_DIR/$LOG_FILE"
# check the size of the current log file, rotate it if necessary
if [ "$(wc -c < "$LOG_DIR/$LOG_FILE")" -gt "$MAX_SIZE" ]; then
  echo "Rotating log file: $LOG_DIR/$LOG_FILE"
  mv "$LOG_DIR/$LOG_FILE" "$LOG_DIR/$LOG_FILE.1"
  touch "$LOG_DIR/$LOG_FILE"
  truncate -s 0 "$LOG_DIR/$LOG_FILE"
fi
echo "Checking number of log files in directory: $LOG_DIR"
# check the number of log files, delete the oldest one if necessary
if [ "$(ls -1 $LOG_DIR/$LOG_FILE* | wc -l)" -gt "$MAX_FILES" ]; then
  echo "Deleting oldest log file in directory: $LOG_DIR"
  rm -f "$(ls -1 $LOG_DIR/$LOG_FILE* | head -n 1)"
fi

ReadConfig()
{
  interface=$1
   
  #if [ $interface = "CWAN1_0 show" ]
  #then
      #interface="CWAN1_0"
  #fi
  config_load "$ModemConfig"
 # echo "Modem config loaded"
 
  #config_get SMSDeviceid "$interface" smsdeviceid
  SMSDeviceid=$(uci get modem.$interface.smsdeviceid)
  CellularOperationMode=$(uci get sysconfig.sysconfig.CellularOperationMode)
  
  config_get SMSApikey "$interface" smsapikey
  config_get SmsResponseSenderEnable "$interface" smsresponsesenderenable
  config_get SmsResponseServerEnable "$interface" smsresponseserverenable
  config_get SmsServerNumber1 "$interface" smsservernumber1
  config_get SmsServerNumber2 "$interface" smsservernumber2
  config_get SmsServerNumber3 "$interface" smsservernumber3
  config_get SmsServerNumber4 "$interface" smsservernumber4
  config_get SmsServerNumber5 "$interface" smsservernumber5
  config_get SmsDeviceId "$interface" smsdeviceid
  
  config_get ConfiguredDataPort "$interface" device
  config_get ConfiguredComPort "$interface" comport
  
 config_load "$SysConfig"
 config_get enable_deviceid smsconfig enable_deviceid
 config_get enable_apikey smsconfig enable_apikey
 config_get validsmsreceivernumbers smsconfig validsmsreceivernumbers 
 config_get debugpassword smsconfig debugpassword
 config_get enabledebugsms smsconfig enabledebugsms
 
 config_get apn sysconfig apn
 config_get sim2apn sysconfig sim2apn
 config_get Sim1apntype sysconfig Sim1apntype
 config_get Sim2apntype sysconfig Sim2apntype
 config_get sim2autoapn sysconfig sim2autoapn
 config_get sim1autoapn sysconfig sim1autoapn
 config_get pdp sysconfig pdp
 config_get sim2pdp sysconfig sim2pdp
 config_get cellularmodem1 sysconfig cellularmodem1
}

send_sms_notification() 
{
    local message=$1

    echo "SmsResponseServerEnable=$SmsResponseServerEnable"
    echo "validsmsreceivernumbers=$validsmsreceivernumbers"

    if [ "$SmsResponseServerEnable" = "1" ]; then
        if [ "$validsmsreceivernumbers" -eq 0  ];then 
          echo "SMS received from valid sender 1"
           /usr/bin/sendsms "+$Sender" "$thirdmsga= $SmsDeviceId $message"
        fi
        if [ "$validsmsreceivernumbers" -eq 1 ]; then
            if [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber1" "$thirdmsga= $SmsDeviceId , $message"
            fi
        fi   

        if [ "$validsmsreceivernumbers" -eq 2 ]; then
            if [ "$SmsServerNumber2" = "$Sender" ] || [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber2" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$thirdmsga= $SmsDeviceId , $message"
            fi
        fi    

        if [ "$validsmsreceivernumbers" -eq 3 ]; then
            if [ "$SmsServerNumber3" = "$Sender" ] || [ "$SmsServerNumber2" = "$Sender" ] ||  [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber3" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber2" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$thirdmsga= $SmsDeviceId , $message"
            fi   
        fi    

        if [ "$validsmsreceivernumbers" -eq 4 ]; then 
            if [ "$SmsServerNumber4" = "$Sender" ] || [ "$SmsServerNumber3" = "$Sender" ] ||  [ "$SmsServerNumber2" = "$Sender" ] ||  [ "$SmsServerNumber1" = "$Sender" ]; then  
                /usr/bin/sendsms "+$SmsServerNumber4" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber3" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber2" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$thirdmsga= $SmsDeviceId , $message"
            fi
        fi    

        if [ "$validsmsreceivernumbers" -eq 5 ]; then
            if [ "$SmsServerNumber5" = "$Sender" ] || [ "$SmsServerNumber4" = "$Sender" ] ||  [ "$SmsServerNumber3" = "$Sender" ] ||  [ "$SmsServerNumber2" = "$Sender" ] ||  [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber5" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber4" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber3" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber2" "$thirdmsga= $SmsDeviceId , $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$thirdmsga= $SmsDeviceId , $message"
            fi   
        fi
    fi
}

send_oldsms_notification() 
{
    local message=$1

    echo "SmsResponseServerEnable=$SmsResponseServerEnable"
    echo "validsmsreceivernumbers=$validsmsreceivernumbers"

    if [ "$SmsResponseServerEnable" = "1" ]; then
        if [ "$validsmsreceivernumbers" -eq 0  ];then 
          echo "SMS received from valid sender 1"
           /usr/bin/sendsms "+$Sender" "$SmsDeviceId $message"
        fi
        if [ "$validsmsreceivernumbers" -eq 1 ]; then
            if [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber1" "$SmsDeviceId $message"
            fi
        fi   

        if [ "$validsmsreceivernumbers" -eq 2 ]; then
            if [ "$SmsServerNumber2" = "$Sender" ] || [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber2" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$SmsDeviceId $message"
            fi
        fi    

        if [ "$validsmsreceivernumbers" -eq 3 ]; then
            if [ "$SmsServerNumber3" = "$Sender" ] || [ "$SmsServerNumber2" = "$Sender" ] ||  [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber3" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber2" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$SmsDeviceId $message"
            fi   
        fi    

        if [ "$validsmsreceivernumbers" -eq 4 ]; then 
            if [ "$SmsServerNumber4" = "$Sender" ] || [ "$SmsServerNumber3" = "$Sender" ] ||  [ "$SmsServerNumber2" = "$Sender" ] ||  [ "$SmsServerNumber1" = "$Sender" ]; then  
                /usr/bin/sendsms "+$SmsServerNumber4" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber3" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber2" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$SmsDeviceId $message"
            fi
        fi    

        if [ "$validsmsreceivernumbers" -eq 5 ]; then
            if [ "$SmsServerNumber5" = "$Sender" ] || [ "$SmsServerNumber4" = "$Sender" ] ||  [ "$SmsServerNumber3" = "$Sender" ] ||  [ "$SmsServerNumber2" = "$Sender" ] ||  [ "$SmsServerNumber1" = "$Sender" ]; then 
                /usr/bin/sendsms "+$SmsServerNumber5" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber4" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber3" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber2" "$SmsDeviceId $message"
                /usr/bin/sendsms "+$SmsServerNumber1" "$SmsDeviceId $message"
            fi   
        fi
    fi
}


if [ "$SMSEventType" = "RECEIVED" ]
then
        # Parse Sender Number & message(which contains actual command)
        Sender=$(awk 'BEGIN {IGNORECASE = 1}/From:[[:blank:]]*/{print $2}' "$IncomingSMSFile")
        Modem=$(grep -i "modem" "$IncomingSMSFile" | head -1 | awk '{print $2}')
        InMsg=$(sed '1,/^$/d' "$IncomingSMSFile")
        firstmsg=$(echo "$InMsg" | cut -d '+' -f1)
        inmsg='$SB'

        if [ "$firstmsg" = "$inmsg" ]  
         then 
            echo "Modem=$Modem"
            ReadConfig "$Modem"
            # ReadConfig "${$Modem:0:-2}"
            deviceid=$(echo "$InMsg" | awk -F'[,=]' '{print $2}')
            securekey=$(echo "$InMsg" | awk -F'[,=]' '{print $3}')
            command=$(echo "$InMsg" | awk -F'[,=]' '{print $4}')
            argument=$(echo "$InMsg" | awk -F'[,=]' '{print $5}')
            argumentkey=$(echo "$InMsg" | awk -F'[,=]' '{print $6}')
            argumentIPK=$(echo "$InMsg" | awk -F'[,=]' '{print $7}')
            parameter1=$(echo "$InMsg" | awk -F'[,=]' '{print $8}')

              secondmsg=$(echo "$InMsg" | cut -d '=' -f1)
              thirdcommand=$(echo "$secondmsg" | cut -d '+' -f2)

              thirdmsga=$(echo "$secondmsg" | cut -d '+' -f2)
              if [ "$command" = "UPT" ]; then
                    thirdmsga="UPT"
              elif [ "$command" = "TME" ]; then
                    thirdmsga="TME"
              elif [ "$command" = "GNI" ]; then
                  thirdmsga="GNI"
              elif [ "$command" = "SSC" ]; then
                  thirdmsga="SSC"
              elif [ "$command" = "NMS" ]; then
                  thirdmsga="NMS"
              elif [ "$command" = "HTP" ]; then
                  thirdmsga="HTP"
              elif [ "$command" = "PKG" ]; then
                  thirdmsga="PKG"
              elif [ "$command" = "MDS" ]; then
                  thirdmsga="MDS"
              elif [ "$command" = "DIO" ]; then
                  thirdmsga="DIO"
              else
                    $thirdmsga
              fi 

        else
              echo "Modem=$Modem"
              ReadConfig "$Modem"
            # ReadConfig "${$Modem:0:-2}"
              echo "*** Message received successfully from $Sender ***"
              msgbrasesremoved=$(echo $InMsg | awk -F '[{}]' '{print $2}')
              # deviceid=$(echo "$msgbrasesremoved" | awk -F '[][]' '{print $2}' | cut -d ',' -f 1)
              deviceid=$(echo "$msgbrasesremoved" | awk -F '[][]' '{print $2}' | cut -d ',' -f 1 | sed 's/"//g')
              # securekey=$(echo "$msgbrasesremoved" | awk -F '[][]' '{print $2}' | cut -d ',' -f 2)
              securekey=$(echo "$msgbrasesremoved" | awk -F '[][]' '{print $2}' | cut -d ',' -f 2 | sed 's/"//g')
              # command=$(echo "$msgbrasesremoved" | awk -F ',' '{print $3}' | cut -d ':' -f 2)
                command=$(echo "$msgbrasesremoved" | awk -F ',' '{print $3}' | cut -d ':' -f 2 | sed 's/"//g')
              if [ "$command" = "REGNMS" ]
              then
                  argument="$(echo "$InMsg" | grep -o '"URL":"[^"]*' | cut -d'"' -f4) $(echo "$InMsg" | grep -o '"KEY":"[^"]*' | cut -d'"' -f4)" 
                  echo "$argument" >> "$LOG_DIR/$LOG_FILE"
              elif [ "$command" = "SWCNMS" ]
              then
                  argument="$(echo "$InMsg" | grep -o '"URL":"[^"]*' | cut -d'"' -f4) $(echo "$InMsg" | grep -o '"KEY":"[^"]*' | cut -d'"' -f4)"
                  echo "$argument" >> "$LOG_DIR/$LOG_FILE"
              else
                  # argument=$(echo "$msgbrasesremoved" | awk -F ',' '{print $4}' | cut -d ':' -f 2)
                  argument=$(echo "$msgbrasesremoved" | awk -F ',' '{print $4}' | cut -d ':' -f 2 | sed 's/"//g')
                  echo "$argument" >> "$LOG_DIR/$LOG_FILE"
              fi
        fi
           
            # if ([ "$enable_deviceid" -eq 1 ] && [ "$enable_apikey" -eq 1 ])
      if ( [ "$enable_deviceid" -eq 0 ] && [ "$enable_apikey" -eq 0 ] && [ -z "$deviceid" ] && [ -z "$securekey" ] ) ||
         ( [ "$enable_deviceid" -eq 1 ] && [ "$enable_apikey" -eq 0 ] && [ "$SMSDeviceid" = "$deviceid" ] && [ -z "$securekey" ] ) ||
         ( [ "$enable_deviceid" -eq 0 ] && [ "$enable_apikey" -eq 1 ] && [ -z "$deviceid" ] && [ "$SMSApikey" = "$securekey" ] ) ||
         ( [ "$enable_deviceid" -eq 1 ] && [ "$enable_apikey" -eq 1 ] && [ "$SMSDeviceid" = "$deviceid" ] && [ "$SMSApikey" == "$securekey" ] ) || 
         ( [ "$enable_deviceid" -eq 1 ] && [ "$enable_apikey" -eq 0 ] && [ "$SMSDeviceid" = "$deviceid" ] ) ||
         ( [ "$enable_deviceid" -eq 0 ] && [ "$enable_apikey" -eq 1 ] && [ "$SMSApikey" == "$securekey" ] )
        then  
            if [ "$thirdcommand" = "GET" ]
              then
                    if [ "$command" = "UPT" ]
                      then
                        systemuptime=$(uptime | cut -d "," -f 1)
                        send_sms_notification "$systemuptime"
                    elif [ "$command" = "TME" ]
                      then
                        systemtime=$(date)
                        send_sms_notification "$systemtime"
                    elif [ "$command" = "GNI" ]
                      then
                        Modem=$(uci get sysconfig.sysconfig.cellularmodem1)
                        sleep 2
                        #deviceqccid
                        ComPort=$(grep -o '/dev/ttyUSB[0-9]*' /tmp/InterfaceManager/status/ports.txt)
                        sleep 10
                        deviceqccid="$(/bin/at-cmd $ComPort at+qccid | grep -oE '[0-9]+')"
                        if [[ "${#QCCID}" -gt 10 ]]
                          then
                            status="READY"
                        else
                            deviceqccid="$(/bin/at-cmd $ComPort at+qccid | grep -oE '[0-9]+')"
                        fi
                        #active sim ,APN,networktype
                        ActiveSim=$(cat /tmp/simnumfile)
                        if [ "$ActiveSim" = "1" ]
                        then
                          APNtype=$(uci get sysconfig.sysconfig.Sim1apntype)
                          if [ "$APNtype" = "auto" ]
                            then
                                APN=$(uci get sysconfig.sysconfig.sim1autoapn)
                          else
                                APN=$(uci get sysconfig.sysconfig.apn)
                          fi
                          Networktype=$(grep -E 'option pdp'  /etc/config/sysconfig | awk '{print $3}')
                        else
                          APNtype=$(uci get sysconfig.sysconfig.Sim2apntype)
                          if [ "$APNtype" = "auto" ]
                            then
                                APN=$(uci get sysconfig.sysconfig.sim2autoapn)
                          else
                                APN=$(uci get sysconfig.sysconfig.sim2apn)
                          fi
                          Networktype=$(grep -E 'option sim2pdp'  /etc/config/sysconfig | awk '{print $3}')
                        fi
                          #simdata usage
                          ActiveSim=$(cat /tmp/simnumfile)
                          if [ "$ActiveSim" = "1" ]
                            then
                                Sim1datausage=$(cat /etc/sim1datausage)
                          elif [ "$ActiveSim" = "2" ]
                            then
                                Sim2datausage=$(cat /etc/sim2datausage)
                          else
                                Sim1datausage=$(cat /etc/sim1datausage)
                                Sim2datausage=$(cat /etc/sim2datausage)
                          fi
                        
                        #network mode
                        ComPort=$(grep -o '/dev/ttyUSB[0-9]*' /tmp/InterfaceManager/status/ports.txt)
                        sleep 2
                        NetworkMode="$(/bin/at-cmd $ComPort AT+QENG=\"servingcell\" | awk -F',' '/\+QENG/ {print $3}' | tr -d '\"')"
                        sleep 5
                        if [ "$NetworkMode" = "LTE" ] || [ "$NetworkMode" = "GSM" ] || [ "$NetworkMode" = "WCDMA" ]
                          then
                          status="READY"
                        else
                            NetworkMode="$(/bin/at-cmd $ComPort AT+QENG=\"servingcell\" | awk -F',' '/\+QENG/ {print $3}' | tr -d '\"')"
                        fi
                        #bandlock
                        sleep 2
                        ComPort=$(grep -o '/dev/ttyUSB[0-9]*' /tmp/InterfaceManager/status/ports.txt)
                        sleep 3
                        bandlock="$(/bin/at-cmd $ComPort at+qnwinfo | awk -F'"' '/LTE BAND /{print $6}')"
                        Bandlockcompare=$(echo $bandlock | cut -d " " -f1) 
                        if [[ "$Bandlockcompare" = "LTE" ]]
                          then
                            status="READY"
                        else
                              bandlock="$(/bin/at-cmd $DataPort at+qnwinfo | awk -F'"' '/LTE BAND /{print $6}')"
                        fi
                         sleep 2
                          #signal
                        Signal="$(/bin/at-cmd $ComPort AT+QENG=\"servingcell\" | grep +QENG: | cut -d',' -f14,15,16,17 | awk -F',' '{print "RSRP:", $1 ",", "RSRQ:", $2 ",", "RSSI:", $3 ",", "SINR:", $4}')"
                        if echo "$Signal" | grep -q "RSRP:" && echo "$Signal" | grep -q "RSRQ:" && echo "$Signal" | grep -q "RSSI:" && echo "$Signal" | grep -q "SINR:"
                          then
                            status="READY"
                        else
                            Signal="$(/bin/at-cmd $ComPort AT+QENG=\"servingcell\" | grep +QENG: | cut -d',' -f14,15,16,17 | awk -F',' '{print "RSRP:", $1 ",", "RSRQ:", $2 ",", "RSSI:", $3 ",", "SINR:", $4}')"
                        fi
                        ActiveSim=$(cat /tmp/simnumfile)
                        if [ "$ActiveSim" = "1" ]
                         then
                            info_string="ModemName:$Modem,Sim1APN:$APN,QCCID:$deviceqccid,sim1datausage:$Sim1datausage,Sim1PDP:$Networktype,NetMode:$NetworkMode,networkband:$bandlock,signal:$Signal,activeSim:$ActiveSim"
                        else
                            info_string="ModemName:$Modem,Sim2APN:$APN,QCCID:$deviceqccid,sim2datausage:$Sim2datausage,Sim2PDP:$Networktype,NetMode:$NetworkMode,networkband:$bandlock,signal:$Signal,activeSim:$ActiveSim"
                        fi
                        send_sms_notification "$info_string"
                    elif [ "$command" = "SSC" ]
                      then
                          simvariable=$(cat /tmp/simnumfile)
                          send_sms_notification "$simvariable"
                    elif [ "$command" = "NMS" ]
                      then
                        tuneliPN=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')
                        Dtunelip=$(uci get remoteconfig.nms.nmsenable)
                        nmsurl=$(uci get openwisp.http.url)
                        TIP="NMS_status:$Dtunelip,tunnel_ip:$tuneliPN,NMS_URL:$nmsurl"
                        send_sms_notification "$TIP"
                    elif [ "$command" = "HTP" ]
                      then
                            HTPserver=$(uci get cloudconfig.cloudconfig.HTTPServerURL)
                            HTPort=$(uci get cloudconfig.cloudconfig.HTTPServerPort)
                            HTPREQUIREMENTS="$HTPserver,$HTPort"
                            send_sms_notification "$HTPREQUIREMENTS"
                    elif [ "$command" = "PKG" ]
                      then
                            pkgserver=$(uci get packagemanager.general.url)
                            pkgrequirement="$pkgserver"
                            send_sms_notification "$pkgrequirement"
                    elif [ "$command" = "MDS" ]
                      then
                            count=$(grep -c 'config RS485Config' /etc/config/DeviceConfigGeneric)
                           # Loop through each device and store their names
                            i=1
                            while [ $i -le $count ]; do
                              device=$(grep -o "config RS485Config '[^']*" /etc/config/DeviceConfigGeneric | cut -d ' ' -f 3 | sed "${i}q;d" | tr -d "'")
                              eval "device$i=\"$device\"" 
                              i=$((i+1))
                            done

                            # Iterate through each device name and perform actions
                            i=1
                            while [ $i -le $count ]; do
                                DeviceName=$(eval "echo \$device$i")
                                checkSlaveid=$(uci get DeviceConfigGeneric.$DeviceName.serialslaveid)

                                # check serialslaveid is match or not
                                  if [ "$checkSlaveid" == "$argument" ]
                                  then 
                                       mdsbaudrate=$(uci get DeviceConfigGeneric.$DeviceName.Baudrate)
                                       mdsparity=$(uci get DeviceConfigGeneric.$DeviceName.Parity)
                                       mdsDatabits=$(uci get DeviceConfigGeneric.$DeviceName.Databits)
                                       mdsstopbits=$(uci get DeviceConfigGeneric.$DeviceName.NoOfStopbits)
                                            
                                      upadtemdsgettingresponse="$argument,$mdsbaudrate,$mdsparity,$mdsDatabits,$mdsstopbits"
                                      send_sms_notification "$upadtemdsgettingresponse"
                                  else
                                        upadtemdsgettingresponse="Slaveid not matching."
                                        send_sms_notification "$upadtemdsgettingresponse"
                                  fi
                            i=$((i+1))
                            done
                    elif [ "$command" = "DIO" ]
                      then    
                            NUM_DETPIN=$(uci get digitalinputconfig.didogpioconfig.numberOfDido)
                                    i=1
                                    output="$NUM_DETPIN"
                                    while [ $i -le $NUM_DETPIN ]; do
                                          dipin=$(uci get digitalinputconfig.didogpioconfig.di"$i")
                                          valuegpio=$(cat /sys/class/gpio/gpio$dipin/value)

                                          # dopin=$(uci get digitalinputconfig.didogpioconfig.do"$i")
                                          # valuegpdo=$(cat /sys/class/gpio/gpio$dopin/value)
                                          # output=$(echo "${output} ${dipin} ${valuegpio} ${dopin} ${valuegpdo}")
                                      output="$output,$i,$valuegpio"
                                      i=$((i + 1))
                                    done
                                    send_sms_notification "$output"

                    else
                        echo "invalid command or key"
                    fi
            elif [ "$command" = "reboot" ] && [ "$argument" = "hardware" ]
                then
                  upadtedmsg="Reboot message recieved"
                  send_oldsms_notification "$upadtedmsg"
                  sleep 50
                  /root/usrRPC/script/Board_Recycle_12V_Script.sh
            elif [ "$command" = "uptime" ]
               then
                systemuptime=$(uptime | cut -d "," -f 1)
                 send_oldsms_notification "$systemuptime"
            elif [ "$command" = "networkinfo" ] && [ "$argument" = "hardware" ]
                  then
                        Modem="$(uci get sysconfig.sysconfig.cellularmodem1)"
                        ActiveSimNo="$(cat /tmp/simnumfile)"
                        activeSim=$(cat /tmp/simnumfile)
                        
                        if [ "$activeSim" -eq 1 ]; then
                            PDP="Sim1PDP=$(uci get sysconfig.sysconfig.pdp)"
                          if [ "$cellularoperationmode" = "singlecellularsinglesim" ]; then
                            sim1datausage="Sim1Datausage=$(cat /etc/simdatausage)"
                          else
                            sim1datausage="Sim1Datausage=$(cat /etc/sim1datausage)"
                          fi
                          
                          if [ "$Sim1apntype" = "manual" ]; then
                            APN="Sim1APN=$(uci get sysconfig.sysconfig.apn)"
                          else 
                            APN="Sim1APN=$(uci get sysconfig.sysconfig.sim1autoapn)"
                          fi
                        elif [ "$activeSim" -eq 2 ]; then
                            PDP="Sim2PDP=$(uci get sysconfig.sysconfig.sim2pdp)"
                            sim2datausage="Sim2Datausage=$(cat /etc/sim2datausage)"	
                          if [ "$Sim2apntype" = "manual" ]; then
                            APN="Sim2APN=$(uci get sysconfig.sysconfig.sim2apn)"	
                          else
                            APN="Sim2APN=$(uci get sysconfig.sysconfig.sim2autoapn)"
                          fi
                        fi
                        sleep 2
                        QCCID="$(/bin/at-cmd $ComPort at+qccid | grep -oE '[0-9]+')"
                        if [[ "${#QCCID}" -gt 10 ]]
                          then
                          status="READY"
                        else
                            QCCID="$(/bin/at-cmd $DataPort at+qccid | grep -oE '[0-9]+')"
                        fi
                        sleep 1
                          bandlock="$(/bin/at-cmd $ComPort at+qnwinfo | awk -F'"' '/LTE BAND /{print $6}')"
                          Bandlockcompare=$(echo $bandlock | cut -d " " -f1) 
                          if [[ "$Bandlockcompare" = "LTE" ]]
                            then
                            status="READY"
                          else
                              bandlock="$(/bin/at-cmd $DataPort at+qnwinfo | awk -F'"' '/LTE BAND /{print $6}')"
                          fi
                        sleep 1
                          NetworkMode="$(/bin/at-cmd $ComPort AT+QENG=\"servingcell\" | awk -F',' '/\+QENG/ {print $3}' | tr -d '\"')"
                        if [ "$NetworkMode" = "LTE" ] || [ "$NetworkMode" = "GSM" ] || [ "$NetworkMode" = "WCDMA" ]
                          then
                          status="READY"
                        else
                            NetworkMode="$(/bin/at-cmd $DataPort AT+QENG=\"servingcell\" | awk -F',' '/\+QENG/ {print $3}' | tr -d '\"')"
                        fi
                    
                        signal="$(/bin/at-cmd $ComPort AT+QENG=\"servingcell\" | grep +QENG: | cut -d',' -f14,15,16,17 | awk -F',' '{print "RSRP:", $1 ",", "RSRQ:", $2 ",", "RSSI:", $3 ",", "SINR:", $4}')"
                        if echo "$signal" | grep -q "RSRP:" && echo "$signal" | grep -q "RSRQ:" && echo "$signal" | grep -q "RSSI:" && echo "$signal" | grep -q "SINR:"
                          then
                          status="READY"
                        else
                        signal="$(/bin/at-cmd $DataPort AT+QENG=\"servingcell\" | grep +QENG: | cut -d',' -f14,15,16,17 | awk -F',' '{print "RSRP:", $1 ",", "RSRQ:", $2 ",", "RSSI:", $3 ",", "SINR:", $4}')"
                        fi

                        send_oldsms_notification ""$'\n'"ModemName=$Modem"$'\n'"NetworkMode=$NetworkMode"$'\n'"$APN"$'\n'"$PDP"$'\n'"ActiveSim=$ActiveSimNo"$'\n'"QCCID=$QCCID"$'\n'"BandLock=$bandlock"$'\n'"SignalStrength=$signal"$'\n'"$sim1datausage"$'\n'"$sim2datausage"
                      
            elif [ "$command" = "gettime" ] && [ "$argument" = "system" ]
              then
                systemtime=$(date)
                send_oldsms_notification "$systemtime"
            elif [ "$thirdcommand" = "RBT" ] 
              then   
                  if [ "$command" = "hardware" ]
                    then 
                          upadtedmsg="OK"
                          send_sms_notification "$upadtedmsg"
                          sleep 50
                          /root/usrRPC/script/Board_Recycle_12V_Script.sh
                  fi
            elif [ "$thirdcommand" = "SSC" ] 
              then 
                  if [ "$command" = "SSC" ] && [ "$argument" = "1" ]
                    then
                        if [ "$CellularOperationMode" = "singlecellulardualsim" ] 
                          then
                            sim=`cat /tmp/simnumfile` 
                                if [ "$sim" = "$argument" ]
                                then  
                                    action="The arguement passed is same as the active sim,Hence cannot switch" 
                                    # SimCannotSwitch
                                    send_sms_notification "$action"
                                else 
                                      # SimSwitching
                                      action="Initiating Sim Switching, Please Wait" 
                                      send_sms_notification "$action"
                                      sleep 20
                                    /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
                                    modemgpio=$(uci get systemgpio.gpio.modem1powergpio)
                                    echo 1 > /sys/class/gpio/gpio$modemgpio/value
                                    echo 0 > /sys/class/gpio/gpio$modemgpio/value

                                    #at-cmd /dev/ttyUSB2 at+qpowd
                                    #SimSwitched
                                    action="Sim Switched" 
                                    send_sms_notification "$action"	 
                                      sleep 50
                                  fi
                        fi
                  elif [ "$command" = "SSC" ] && [ "$argument" = "2" ]
                    then
                          if [ "$CellularOperationMode" = "singlecellulardualsim" ]
                            then
                                sim=`cat /tmp/simnumfile` 
                                if [ "$sim" = "$argument" ]
                                then  
                                    action="The arguement passed is same as the active sim,Hence cannot switch" 
                                    # SimCannotSwitch
                                    send_sms_notification "$action"
                                else 
                                    # SimSwitching
                                      action="Initiating Sim Switching, Please Wait" 
                                      send_sms_notification "$action"	 
                                    sleep 20
                                    simcontrol=$(uci get sysconfig.sysconfig.primarysimswitchbackenable)
                                    simupdate=$(uci get sysconfig.sysconfig.primarysimswitchbacktime)

                                    if [ "$simcontrol" = "1" ]                                                                                  
                                    then                                                                                                                        
                                      pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")                                                     
                                      kill -TERM "$pid" > /dev/null 2>&1                                                                               
                                      sleep 1                                                                                                          
                                      kill -KILL "$pid" > /dev/null 2>&1                                                                                   
                                      /root/InterfaceManager/script/cellular/PrimarySwitch.sh "$simupdate" CWAN1 1 &                                     
                                    fi
                                    /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2
                                    
                                     modemgpio=$(uci get systemgpio.gpio.modem1powergpio)
                                    echo 1 > /sys/class/gpio/gpio$modemgpio/value
                                    echo 0 > /sys/class/gpio/gpio$modemgpio/value

                                    #at-cmd /dev/ttyUSB2 at+qpowd
                                    #SimSwitched
                                    action="Sim Switched" 
                                    send_sms_notification "$action"	 
                                    sleep 50
                                fi
                          fi 
                  else  
                          echo "command or argument invalid "  
                  fi
            elif [ "$command" = "simswitch" ] && [ "$argument" = "1" ]
              then
                    if [ "$CellularOperationMode" = "singlecellulardualsim" ] 
                      then
                            sim=`cat /tmp/simnumfile` 
                                if [ "$sim" = "$argument" ]
                                then  
                                    action="The arguement passed is same as the active sim,Hence cannot switch" 
                                    # SimCannotSwitch
                                    send_oldsms_notification "$action"
                                else 
                                      # SimSwitching
                                      action="Initiating Sim Switching, Please Wait" 
                                      send_oldsms_notification "$action"
                                      sleep 20
                                    /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 1
                                    modemgpio=$(uci get systemgpio.gpio.modem1powergpio)
                                    echo 1 > /sys/class/gpio/gpio$modemgpio/value
                                    echo 0 > /sys/class/gpio/gpio$modemgpio/value

                                    #at-cmd /dev/ttyUSB2 at+qpowd
                                    #SimSwitched
                                    action="Sim Switched" 
                                    send_oldsms_notification "$action"	 
                                      sleep 50
                                  fi
                    fi
 
			 
            elif [ "$command" = "simswitch" ] && [ "$argument" = "2" ]
              then
                    if [ "$CellularOperationMode" = "singlecellulardualsim" ]
                      then
                                sim=`cat /tmp/simnumfile` 
                                if [ "$sim" = "$argument" ]
                                then  
                                    action="The arguement passed is same as the active sim,Hence cannot switch" 
                                    # SimCannotSwitch
                                    send_oldsms_notification "$action"
                                else 
                                    # SimSwitching
                                      action="Initiating Sim Switching, Please Wait" 
                                      send_oldsms_notification "$action"	 
                                    sleep 20
                                    simcontrol=$(uci get sysconfig.sysconfig.primarysimswitchbackenable)
                                    simupdate=$(uci get sysconfig.sysconfig.primarysimswitchbacktime)

                                    if [ "$simcontrol" = "1" ]                                                                                  
                                    then                                                                                                                        
                                      pid=$(pgrep -f "/root/InterfaceManager/script/cellular/PrimarySwitch.sh")                                                     
                                      kill -TERM "$pid" > /dev/null 2>&1                                                                               
                                      sleep 1                                                                                                          
                                      kill -KILL "$pid" > /dev/null 2>&1                                                                                   
                                      /root/InterfaceManager/script/cellular/PrimarySwitch.sh "$simupdate" CWAN1 1 &                                     
                                    fi
                                    /root/InterfaceManager/script/cellular/SimSwitch.sh CWAN1 2

                                     modemgpio=$(uci get systemgpio.gpio.modem1powergpio)
                                    echo 1 > /sys/class/gpio/gpio$modemgpio/value
                                    echo 0 > /sys/class/gpio/gpio$modemgpio/value

                                    #at-cmd /dev/ttyUSB2 at+qpowd
                                    #SimSwitched
                                    action="Sim Switched" 
                                    send_oldsms_notification "$action"	 
                                    sleep 50
                                fi
                     fi        
            elif [ "$thirdcommand" = "NMS" ] 
              then  
                  if [ "$command" = "1" ]
                    then   
                        #check internet is there or not
                        PacketLoss=$(ping -c 5 8.8.8.8 | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1) 
                        echo " packet loss for internet: $PacketLoss" >> "$LOG_DIR/$LOG_FILE"
                        #check url is working or not
                        URLIP=$(echo "$argument" | grep -oE '[0-9A-Za-z.-]+\.[0-9A-Za-z.-]+\.[0-9A-Za-z.-]+\.[0-9A-Za-z.-]+')
                        URLpacketloss=$(ping -c 5 $URLIP | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1) 
                        echo "url ping checking: $URLpacketloss" >> "$LOG_DIR/$LOG_FILE"
                        if [ "$PacketLoss" -eq 0 ] && [ "$URLpacketloss" -eq 0 ]; 
                        then
                          sleep 5
                          sh /root/NMS_Scripts/Register_NMS.sh $argument $argumentkey
                          tunelip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')
                          NMS_URL=$(uci get openwisp.http.url)
                          tunelhandler="Device successfully registered to NMS,Tunnel_IP:$tunelip"  
                          echo "$tunelhandler" >> "$LOG_DIR/$LOG_FILE"
                        else
                          tunelhandler="Device Not Registered to NMS " 
                          echo "$tunelhandler" >> "$LOG_DIR/$LOG_FILE"
                        fi
                        send_sms_notification "$tunelhandler"
                  elif [ "$command" = "2" ] 
                    then
                        sleep 4
                        sh /root/InterfaceManager/script/Disable_Nms.sh
                        sleep 10
                        Delettunelhandler="Device deletion from NMS completed successfully "
                        echo "$Delettunelhandler" >> "$LOG_DIR/$LOG_FILE"
                          send_sms_notification "$Delettunelhandler"
                      
                  elif [ "$command" = "3" ] 
                    then      
                      SWPacketLoss=$(ping -c 5 8.8.8.8 | grep "packet loss" | cut -d "," -f 3 | tr -d " " | cut -d "%" -f 1)
                      echo " packet loss for internet: $SWPacketLoss" >> "$LOG_DIR/$LOG_FILE"
                      if [ "$SWPacketLoss" -eq 0 ]; 
                        then
                        sleep 6
                        sh /root/NMS_Scripts/switch_NMS.sh $argument $argumentkey
                        Stunelip=$(ifconfig tun0 | grep -oE 'inet addr:[0-9.]+ ' | grep -oE '[0-9.]+')-
                        SNMS_URL=$(uci get openwisp.http.url)
                        switchtunelhandler="Device successfully registered New NMS.Tunnel_IP:$Stunelip"
                        echo "$switchtunelhandler" >> "$LOG_DIR/$LOG_FILE"
                      else
                        switchtunelhandler="check Internet connection"
                        echo "$switchtunelhandler" >> "$LOG_DIR/$LOG_FILE"
                      fi
                        send_sms_notification "$switchtunelhandler"
                  else
                        echo "invalid command or key"
                  fi
            elif [ "$thirdcommand" = "HTP" ] 
              then 
                                  uci set cloudconfig.cloudconfig.HTTPServerURL="$command"
                                  uci set cloudconfig.cloudconfig.HTTPServerPort="$argument"
                                  uci commit cloudconfig
                                  sh -x /etc/init.d/GD44AppManager stop
                                  sleep 5
                                  sh -x /etc/init.d/GD44AppManager start

                                  serverURL=$(uci show cloudconfig.cloudconfig.HTTPServerURL)
                                  URLUPDATE=$(echo "$serverURL" | cut -d '=' -f2)
                                  formacturl=$(echo "$URLUPDATE" | sed "s/'//g")
                                  sed -i "s|HTTPServerURL=\"[^\"]*\"|HTTPServerURL=\"$formacturl:$argumentIPK\"|" /root/HTTPSenderAppComponent/etc/Config/HTTPSenderServerClientConfig.cfg
                            
                                upadtedresponse="OK"
                                send_sms_notification "$upadtedresponse"
            elif [ "$thirdcommand" = "PKG" ] 
              then  
                      uci set packagemanager.general.url="$command"
                      uci commit packagemanager
                      upadtedpkgresponse="OK"
                      send_sms_notification "$upadtedpkgresponse"

            elif [ "$thirdcommand" = "MDS" ] 
              then  
                    count=$(grep -c 'config RS485Config' /etc/config/DeviceConfigGeneric)
                    # Loop through each device and store their names
                    i=1
                    while [ $i -le $count ]; do
                      device=$(grep -o "config RS485Config '[^']*" /etc/config/DeviceConfigGeneric | cut -d ' ' -f 3 | sed "${i}q;d" | tr -d "'")
                      eval "device$i=\"$device\"" 
                      i=$((i+1))
                    done

                    # Iterate through each device name and perform actions
                    i=1
                    while [ $i -le $count ]; do
                        DeviceName=$(eval "echo \$device$i")
                        checkSlaveid=$(uci get DeviceConfigGeneric.$DeviceName.serialslaveid)

                        # check serialslaveid is match or not
                          if [ "$checkSlaveid" == "$command" ]
                          then 
                                  uci set DeviceConfigGeneric.$DeviceName.Baudrate="$argument"
                                  if [ "$argumentkey" == "0" ] || [ "$argumentkey" == "1" ] || [ "$argumentkey" == "2" ]
                                    then
                                      uci set DeviceConfigGeneric.$DeviceName.Parity="$argumentkey"
                                      uci set DeviceConfigGeneric.$DeviceName.Databits="$argumentIPK"
                                      uci set DeviceConfigGeneric.$DeviceName.NoOfStopbits="$parameter1"
                                  fi
                                  uci commit DeviceConfigGeneric
                              
                          else
                                upadtemdsresponse="Slaveid not matching."
                                echo "$upadtemdsresponse"
                          fi
                    i=$((i+1))
                    done
                                  sh /bin/UpdateConfigurationsGateway ucitoappcfg
                                    sleep 5
                                  sh -x /etc/init.d/GD44AppManager stop
                                   sleep 5
                                  sh -x /etc/init.d/GD44AppManager start

                                    upadtemdsresponse="OK"

                    send_sms_notification "$upadtemdsresponse"

            elif [ "$thirdcommand" = "PIN" ] 
              then  
                    NO_of_PPIN=$(uci get digitalinputconfig.didogpioconfig.numberOfDido)
                  if [ "$NO_of_PPIN" == "$command" ]
                    then
                      last_four_values=$(echo "$InMsg" | cut -d ',' -f4-)
                      status=$(echo "$InMsg" | cut -d',' -f3)
                      pinargument=""
                      pinkey=""
                      j=1
                      i=1
                      while [ $j -le $status ]; do
                                    value=$(echo "$last_four_values" | awk -v i="$i" -F',' '{print $i}')
                                    if [ $((i%2)) -eq 1 ]; then              # Odd indexed value
                                      pinargument="$value"
                                      echo "$pinargument"
                                      pin=$(uci get digitalinputconfig.didogpioconfig.do"$pinargument")
                                      echo $pin > /sys/class/gpio/export
                                    fi                                 
                              i=$((i+1))
                                    value=$(echo "$last_four_values" | awk -v i="$i" -F',' '{print $i}')
                                    if [ $((i%2)) != 1 ]; then         # Even indexed value
                                        pinkey="$value"
                                        if [ "$pinkey" == "1" ];
                                          then
                                              echo out > /sys/class/gpio/gpio$pin/direction
                                        else
                                              echo in > /sys/class/gpio/gpio$pin/direction
                                        fi
                                    fi
                               i=$((i+1))
                               j=$((j+1))
                               uci set digitalinputconfig.digitalinputconfig.DIOMode"$pinargument"="$pinkey"
                               uci commit digitalinputconfig
                               sh -x /etc/init.d/GD44AppManager stop
                               sleep 5
                               sh -x /etc/init.d/GD44AppManager start
			                         sed -i "s/^DIOMode$pinargument=.*$/DIOMode$pinargument=$pinkey/" "/root/ReadDIAppConfig.cfg"
                       done

                       upadtepinresponse="OK"
                       send_sms_notification "$upadtepinresponse"
                  else
                        upadtepinresponse="PIN number not matching"
                        send_sms_notification "$upadtepinresponse"
                  fi
            elif [ "$thirdcommand" = "DIO" ] 
              then  
                   NUM_PIN=$(uci get digitalinputconfig.didogpioconfig.numberOfDido)
                  if [ "$NUM_PIN" == "$command" ]
                    then
                       last_values=$(echo "$InMsg" | cut -d ',' -f4-) 
                       numstatus=$(echo "$InMsg" | cut -d',' -f3)    
                       DOpinargument=""
                       DOpinvalue=""
                        j=1
                        i=1 
                         while [ $j -le $numstatus ]; do
                                    valuename=$(echo "$last_values" | awk -v i="$i" -F',' '{print $i}')
                                    if [ $((i%2)) -eq 1 ]; then              # Odd indexed value
                                      DOpinargument="$valuename"
                                      echo "$DOpinargument"
                                      pin=$(uci get digitalinputconfig.didogpioconfig.do"$DOpinargument")
                                      echo $pin > /sys/class/gpio/export
                                    fi                                 
                              i=$((i+1))
                                    valuename=$(echo "$last_values" | awk -v i="$i" -F',' '{print $i}')
                                    if [ $((i%2)) != 1 ]; then         # Even indexed value
                                        DOpinvalue="$valuename"
                                        echo "$DOpinvalue" > /sys/class/gpio/gpio$pin/value
                                    fi
                                    mosquitto_pub -t "IOCard1/P530/IREQ/DIOControlData" -m "<,1,RELAY-$pin-$DOpinvalue,>" 
                               i=$((i+1))
                               j=$((j+1))
                          done
                       upadtepinsetresponse="OK"
                       send_sms_notification "$upadtepinsetresponse"
                  else
                        upadtepinsetresponse="PIN number not matching"
                        send_sms_notification "$upadtepinsetresponse"
                  fi
            elif [ "$command" = "enabledebugsms" ] && [ "$argument" = "$debugpassword" ]
              then         
                    /sbin/uci set sysconfig.sysconfig.enabledebugsms=1
                    /sbin/uci commit sysconfig 
                    smsdebug="Debug SMS Enabled"
                    send_sms_notification "$smsdebug"
            elif [ "$command" = "disabledebugsms" ] && [ "$argument" = "$debugpassword" ]
              then         
                    /sbin/uci set sysconfig.sysconfig.enabledebugsms=0
                    /sbin/uci commit sysconfig 
                    smsenable="Debug SMS Disabled"  
                    send_sms_notification "$smsenable"   
            elif [ "$command" = "uciset" ]
              then
                    if [ $enabledebugsms = '1' ]
                    then
                      /sbin/$argument
                      /usr/bin/sendsms "+$Sender" "Success : $argument"
                    else
                      /usr/bin/sendsms "+$Sender" "Please enable SMS debug"
                    fi      
            elif [ "$command" = "ucicommit" ]
              then
                  if [ $enabledebugsms = '1' ]
                  then
                      /sbin/$argument
                      /usr/bin/sendsms "+$Sender" "Success : $argument"
                  else
                      /usr/bin/sendsms "+$Sender" "Please enable SMS debug"
                  fi  
            elif [ "$command" = "uciget" ]
              then
                    if [ $enabledebugsms = '1' ]
                    then
                      output=$(/sbin/$argument)                      
                      /usr/bin/sendsms "+$Sender" "$output"
                    else
                      /usr/bin/sendsms "+$Sender" "Please enable SMS debug"
                  fi
            elif [ "$command" = "ucishow" ]
                then       
                    if [ $enabledebugsms = '1' ]
                      then
                        output=$(/sbin/$argument)                      
                        /usr/bin/sendsms "+$Sender" "${output}"
                      else
                        /usr/bin/sendsms "+$Sender" "Please enable SMS debug"
                    fi
            elif [ "$command" = "runscript" ]
                then       
                    if [ $enabledebugsms = '1' ]
                      then
                        output=$($argument 2>&1)                      
                        /usr/bin/sendsms "+$Sender" "$output"
                      else
                        /usr/bin/sendsms "+$Sender" "Please enable SMS debug"
                    fi                  
              # elif [ "$command" = "TME" ] && [ "$argument" = "system" ]
            
            elif [ "$command" = "gettime" ] && [ "$argument" = "hardware" ]
              then
                    hardwaretime=$(hwclock)
                    send_sms_notification "$hardwaretime"
            else
                  echo "invalid command or key"
            fi
      else
              echo "invalid command or key"
      fi
        

elif [ "$SMSEventType" = "SENT" ]
then
        # Delete sent messages
        RemoveFiles "$SentSMSDir" "$MaxSentSMS"
        echo "*** Message sent successfully ***"
elif [ "$SMSEventType" = "FAILED" ]
then
        # Delete failed messages
        RemoveFiles "$FailedSMSDir" "$MaxFailedSMS"
        echo "*** Message send failure ***"
else
        echo "*** No actions for event $SMSEventType ***"
fi
exit 0
