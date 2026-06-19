#!/bin/sh

ACTION="$1"
APP_PATH="$2"

RETRY_COUNT=3
SLEEP_SEC=1

source /root/SourceAppComponent/etc/Config/app_run_status.cfg

MONIT_SRC_DIR="/Web_Page_Gateway_Apps/Common_GW_Files/monit.d"
MONIT_DST_DIR="/etc/monit.d"

SENDER_APP_PATH="/root/SenderAppComponent/SenderApp"
DATACOLLECTOR_APP_PATH="/root/DataCollectorAppComponent/DataCollectorApp"

# -------------------------------
# Validate arguments
# -------------------------------
if [ -z "$ACTION" ] || [ -z "$APP_PATH" ]; then
    echo "Usage: $0 start|stop|restart <full_app_path>"
    exit 1
fi

# -------------------------------
# Resolve executable details
# -------------------------------
resolve_app_path()
{
    if [ ! -x "$APP_PATH" ]; then
        echo "ERROR: Executable '$APP_PATH' not found or not executable"
        exit 1
    fi

    APP_NAME="$(basename "$APP_PATH")"
    MONIT_FILE="Monitor_${APP_NAME}"
}

# -------------------------------
# Monit file install
# -------------------------------
install_monit_file()
{
    echo "Installing monit file: $MONIT_FILE"

    /etc/monit stop

    if [ -f "$MONIT_SRC_DIR/$MONIT_FILE" ]; then
        mv "$MONIT_SRC_DIR/$MONIT_FILE" "$MONIT_DST_DIR/"
    else
        echo "WARNING: $MONIT_FILE not found in source"
    fi

    /etc/monit start
}

# -------------------------------
# Monit file remove
# -------------------------------
remove_monit_file()
{
    echo "Removing monit file: $MONIT_FILE"

    /etc/monit stop

    if [ -f "$MONIT_DST_DIR/$MONIT_FILE" ]; then
        mv "$MONIT_DST_DIR/$MONIT_FILE" "$MONIT_SRC_DIR/"
    fi

    /etc/monit start
}

# -------------------------------
# Check running (by executable name)
# -------------------------------
is_running()
{
    pidof "$APP_NAME" >/dev/null 2>&1
}

# -------------------------------
# Start App
# -------------------------------
start_app()
{
    # Start core apps first
    start_core_app

    # Start generic app if provided
    if [ -n "$APP_PATH" ]; then
        
        start_generic_app
    fi
}

start_core_app()
{
    # SenderApp
    CORE_NAME="SenderApp"
    CORE_PATH="/root/SenderAppComponent/SenderApp"
    if ! pidof "$CORE_NAME" >/dev/null 2>&1; then
        echo "Starting $CORE_NAME"
        for i in $(seq 1 $RETRY_COUNT); do
            "$CORE_PATH" >/dev/null 2>&1 &
            sleep $SLEEP_SEC
            if pidof "$CORE_NAME" >/dev/null 2>&1; then
                echo "SUCCESS: $CORE_NAME started"
                MONIT_FILE="Monitor_$CORE_NAME"
                install_monit_file
                break
            fi
        done
    else
        echo "$CORE_NAME is already running"
    fi

    # DataCollectorApp
    CORE_NAME="DataCollectorApp"
    CORE_PATH="/root/DataCollectorAppComponent/DataCollectorApp"
    if ! pidof "$CORE_NAME" >/dev/null 2>&1; then
        echo "Starting $CORE_NAME"
        for i in $(seq 1 $RETRY_COUNT); do
            "$CORE_PATH" >/dev/null 2>&1 &
            sleep $SLEEP_SEC
            if pidof "$CORE_NAME" >/dev/null 2>&1; then
                echo "SUCCESS: $CORE_NAME started"
                MONIT_FILE="Monitor_$CORE_NAME"
                install_monit_file
                break
            fi
        done
    else
        echo "$CORE_NAME is already running"
    fi
}

#start_generic_app()
#{
    ## Check if APP_PATH is valid
    #if [ ! -x "$APP_PATH" ]; then
        #echo "ERROR: Executable '$APP_PATH' not found or not executable"
        #return 1
    #fi

    ## Get the app name from path
    #APP_NAME="$(basename "$APP_PATH")"
    #MONIT_FILE="Monitor_${APP_NAME}"

    ## Check if already running
    #if is_running; then
        #echo "$APP_NAME is already running"
        #return 0
    #fi
    
	#resolve_app_path
	
    #echo "Starting $APP_NAME"
	#pidof "DataCollectorApp" >/dev/null 2>&1 && killall "DataCollectorApp" && echo "DataCollectorApp stopped"
	#sleep $SLEEP_SEC
	#"$CORE_PATH" >/dev/null 2>&1 &
	#sleep $SLEEP_SEC
	
	
    #echo "Starting $APP_NAME"
	#pidof "SenderApp" >/dev/null 2>&1 && killall "SenderApp" && echo "SenderApp stopped"
	#sleep $SLEEP_SEC
	#"$CORE_PATH" >/dev/null 2>&1 &
	#sleep $SLEEP_SEC

	

    ## Retry loop
    #for i in $(seq 1 $RETRY_COUNT); do
        #"$APP_PATH" >/dev/null 2>&1 &
        #sleep $SLEEP_SEC

        #if pidof "$APP_NAME" >/dev/null 2>&1; then
            #echo "SUCCESS: $APP_NAME started"
            #install_monit_file
            #return 0
        #fi

        #echo "Retry $i failed"
    #done

    #echo "ERROR: Failed to start $APP_NAME"
    #return 1
#}


start_generic_app()
{
    # Check if APP_PATH is valid
    if [ ! -x "$APP_PATH" ]; then
        echo "ERROR: Executable '$APP_PATH' not found or not executable"
        return 1
    fi

    # Get app name
    APP_NAME="$(basename "$APP_PATH")"
    MONIT_FILE="Monitor_${APP_NAME}"

    # If already running
    if is_running; then
        echo "$APP_NAME is already running"
        return 0
    fi

    resolve_app_path

    # ------------------------------------------------
    # Restart DataCollectorApp
    # ------------------------------------------------
    echo "Restarting DataCollectorApp"

    pidof "DataCollectorApp" >/dev/null 2>&1 && \
    killall "DataCollectorApp" && \
    echo "DataCollectorApp stopped"

    sleep $SLEEP_SEC

    "$DATACOLLECTOR_APP_PATH" >/dev/null 2>&1 &

    sleep $SLEEP_SEC

    if pidof "DataCollectorApp" >/dev/null 2>&1; then
        echo "DataCollectorApp restarted successfully"
    else
        echo "WARNING: Failed to restart DataCollectorApp"
    fi

    # ------------------------------------------------
    # Restart SenderApp
    # ------------------------------------------------
    echo "Restarting SenderApp"

    pidof "SenderApp" >/dev/null 2>&1 && \
    killall "SenderApp" && \
    echo "SenderApp stopped"

    sleep $SLEEP_SEC

    "$SENDER_APP_PATH" >/dev/null 2>&1 &

    sleep $SLEEP_SEC

    if pidof "SenderApp" >/dev/null 2>&1; then
        echo "SenderApp restarted successfully"
    else
        echo "WARNING: Failed to restart SenderApp"
    fi

    # ------------------------------------------------
    # Start requested app
    # ------------------------------------------------
    echo "Starting $APP_NAME"

    for i in $(seq 1 $RETRY_COUNT); do

        "$APP_PATH" >/dev/null 2>&1 &

        sleep $SLEEP_SEC

        if pidof "$APP_NAME" >/dev/null 2>&1; then
            echo "SUCCESS: $APP_NAME started"
            install_monit_file
            return 0
        fi

        echo "Retry $i failed"
    done

    echo "ERROR: Failed to start $APP_NAME"
    return 1
}

# -------------------------------
# Stop App
# -------------------------------
stop_app()
{
    echo "Stopping $APP_NAME"
	
		if [ "$aio_Enable" = "0" ] && [ "$dio_Enable" = "0" ] && [ "$modbus_Enable" = "0" ] && \
	    [ "$rs232_Enable" = "0" ] && [ "$bacnet_Enable" = "0" ] && [ "$snmp_Enable" = "0" ] && \
	    [ "$port_Enable" = "0" ]; then

			echo "All core apps disabled. Stopping SenderApp and DataCollectorApp..."
			pidof "SenderApp" >/dev/null 2>&1 && killall "SenderApp" && echo "SenderApp stopped"
            pidof "DataCollectorApp" >/dev/null 2>&1 && killall "DataCollectorApp" && echo "DataCollectorApp stopped"
        fi
    
    if [ -n "$APP_PATH" ]; then
        resolve_app_path
        echo "Stopping $APP_NAME"
		for i in 1 2 3
		do
			killall "$APP_NAME" 2>/dev/null
			sleep $SLEEP_SEC

			if ! is_running; then
				echo "SUCCESS: $APP_NAME stopped"
				remove_monit_file
				return 0
			fi

			echo "Retry $i failed"
		done

		echo "ERROR: Failed to stop $APP_NAME"
		return 1
    fi
}
# Ensure SenderApp always running
if ! pidof "SenderApp" >/dev/null 2>&1; then
    echo "SenderApp not running. Starting..."

    "$SENDER_APP_PATH" >/dev/null 2>&1 &

    sleep $SLEEP_SEC
fi
# -------------------------------
# Main
# -------------------------------


case "$ACTION" in
    start)   start_app ;;
    stop)    stop_app ;;
    restart) stop_app; start_app ;;
    *)
        echo "Usage: $0 start|stop|restart <full_app_path>"
        exit 1
        ;;
esac

exit 0
