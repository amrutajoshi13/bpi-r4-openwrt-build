#!/bin/sh

while true; do
	LOG_DIR=/root/Router_Logs/SHMAPP_Log
	LOG_FILE=Poweroff_log_usage.txt
	MAX_FILES=2
	MAX_SIZE=100

	    # check if the log directory exists, create it if it doesn't
	if [ ! -d "$LOG_DIR" ]; then
	    echo "Creating log directory: $LOG_DIR"
	    mkdir -p "$LOG_DIR"
	fi
	    # check if the log file exists, create it if it doesn't
	if [ ! -f "$LOG_DIR/$LOG_FILE" ]; then
	    echo "Creating log file: $LOG_DIR/$LOG_FILE"
	    touch "$LOG_DIR/$LOG_FILE"
	fi
	    # check the size of the current log file, rotate it if necessary
	if [ "$(wc -c < "$LOG_DIR/$LOG_FILE")" -gt "$MAX_SIZE" ]; then
		echo "Rotating log file: $LOG_DIR/$LOG_FILE"
		mv "$LOG_DIR/$LOG_FILE" "$LOG_DIR/$LOG_FILE.1"
		touch "$LOG_DIR/$LOG_FILE"
		truncate -s 0 "$LOG_DIR/$LOG_FILE"
	fi
	    # check the number of log files, delete the oldest one if necessary
	if [ "$(ls -1 $LOG_DIR/$LOG_FILE* | wc -l)" -gt "$MAX_FILES" ]; then
		echo "Deleting oldest log file in directory: $LOG_DIR"
		rm -f "$(ls -1 $LOG_DIR/$LOG_FILE* | head -n 1)"
	fi

	current_date=$(date +"%Y-%m-%d")
	current_time=$(date +"%H:%M:%S")
	current_date_time="${current_date} ${current_time}"
	echo "$current_date_time" >> "$LOG_DIR/$LOG_FILE"
	sleep 30
	sleep 30
done
