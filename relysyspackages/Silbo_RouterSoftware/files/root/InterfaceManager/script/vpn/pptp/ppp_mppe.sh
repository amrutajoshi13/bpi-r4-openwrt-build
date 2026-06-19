#!/bin/sh

. /lib/functions.sh

PptpdUCIPath="/etc/config/pptp_i_config"

ReadpptpdUCIConfig() {
    config_load "$PptpdUCIPath"
    config_foreach pptpdConfigParameters service
}

pptpdConfigParameters() {

    local pptpdConfigSection="$1"

    config_get Name "$pptpdConfigSection" name
    config_get Type "$pptpdConfigSection" type
    config_get Enabled "$pptpdConfigSection" enabled
    config_get Mppe "$pptpdConfigSection" mppe_stateless

    if [ "$Enabled" = "1" ]; then

        # CLIENT
        if [ "$Type" = "CLIENT" ]; then
            if [ "$Mppe" -eq 1 ]; then
                sed -i '/^mppe /c\mppe required,no40,no56,stateless' /etc/ppp/options.pptp
            else
                sed -i '/^mppe /c\mppe no40,no56,stateless' /etc/ppp/options.pptp
            fi
        fi

        # # SERVER
        # if [ "$Type" = "SERVER" ]; then
        #     if [ "$Mppe" -eq 1 ]; then
        #         # Remove 'nomppe' if it exists
        #         sed -i '/^nomppe/d' /etc/ppp/options.pptpd
        #     elif [ "$Mppe" -eq 0 ]; then
        #         # Add 'nomppe' if it's not already there
        #         if ! grep -q '^nomppe' /etc/ppp/options.pptpd; then
        #             sed -i '/^refuse-mschap/a\nomppe' /etc/ppp/options.pptpd
        #         fi
        #     fi
        # fi

    else
        echo "PPTP Disabled"
    fi
}

ReadpptpdUCIConfig
