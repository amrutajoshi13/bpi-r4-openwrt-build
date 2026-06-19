#!/bin/sh

JsonKeyParamsRs485IndexCfgDirPath="/root/Device_health"
JsonKeyParamsRs485IndexconfigureCfgPath="${JsonKeyParamsRs485IndexCfgDirPath}/JsonKeyParametersIndex"
JsonKeyParamsRs485IndexconfigureCfgPath2="${JsonKeyParamsRs485IndexCfgDirPath}/JsonKeyParameters"
JsonKeyParamsRs485IndexconfigureFile="/etc/config/Health_Jsonconfig"

UpdateJsonKeyparamsRS485IndexCfg() {
    rm "${JsonKeyParamsRs485IndexconfigureCfgPath}.cfg"
    rm "${JsonKeyParamsRs485IndexconfigureCfgPath2}.cfg"
    config_load "$JsonKeyParamsRs485IndexconfigureFile"

    SerialNumber=$(uci get boardconfig.board.serialnum)
    
    for i in $(seq 0 37); do
     
        CurrentModbusParameter=$(uci get Health_Jsonconfig.@JsonRs485Indexconfig[$((i))].ModbusParameter)
        CurrentModbusCustomParameter=$(uci get Health_Jsonconfig.@JsonRs485KeyCustomconfig[$((i))].ModbusCustomParameter)
        CurrentParameter=$(uci get Health_Jsonconfig.@JsonRs485Indexconfig[$((i))].Parameterkey)
        CurrentParameterValue=$(uci get Health_Jsonconfig.@JsonRs485Indexconfig[$((i))].Parametervalue )
       
        KeyFound=false


       
        for j in $(seq 0 34); do
            Key="Key$j"
            CurrentKey=$(uci get Health_Jsonconfig.JsonRs485Keyconfig."$Key")

            if [ "$CurrentModbusParameter" == "$CurrentKey" ]; then
                KeyFound=true
                echo "$CurrentModbusParameter=\"$CurrentParameter\"" >> "${JsonKeyParamsRs485IndexconfigureCfgPath2}.cfg"
                break
            fi
        done   

      

        for j in $(seq 35 37); do
            Key="Key$j"
            echo "$Key"
            CurrentKey=$(uci get Health_Jsonconfig.JsonRs485Keyconfig."$Key")

            if [ "$CurrentModbusParameter" == "$CurrentKey" ]; then
                KeyFound=true
                size=${#CurrentModbusParameter}
                index=${CurrentModbusParameter:$size-1:1}
                index=$(echo "$CurrentModbusParameter" | cut -d 'd' -f 2)
              echo "$CurrentModbusParameter=\"$CurrentParameter\"" >> "${JsonKeyParamsRs485IndexconfigureCfgPath2}.cfg"
              echo "RS485CustomParam${index}=\"$CurrentParameterValue\"" >> "${JsonKeyParamsRs485IndexconfigureCfgPath2}.cfg"
                
                break
        # fi

            fi
        done    

        if [ -n "$CurrentModbusParameter" ]; then
            echo "$CurrentModbusParameter"  >> "${JsonKeyParamsRs485IndexconfigureCfgPath}.cfg"
        fi
        
    done
    
}


UpdateAppCfg()
{      
	 UpdateJsonKeyparamsRS485IndexCfg
}

if [ $# -ne 1 ]
then
    echo "${0##*/}: missing action"
    usage
else
    action="$1"
    case "$action" in
            "ucitoappcfg")
                UpdateAppCfg
                ;;
                 
            *)
                usage
                ;;
    esac
fi

exit 0