#!/bin/sh

OUTPUT_FILE="/bin/config.txt"
CONFIG_DIR="/etc/config"
FTP_LOG="/usr/ftp_logs.txt"

serial_num=$(uci get boardconfig.board.serialnum)
site_name=$(uci get siteconfig.siteconfig.siteid)
FILE="$FTP_LOG"
echo "FILE=$FTP_LOG"
if [ -f "$FILE" ]; then
    size_kb=$(du -k "$FILE" | awk '{print $1}')
    echo "File size is: ${size_kb} KB"
    if [ "$size_kb" -gt 100 ]; then
        echo "File size is greater than 100 KB. Removing and recreating the file."
        rm -f "$FILE"
        touch "$FILE"
    else
        echo "File size is less than or equal to 100 KB. No action taken."
    fi
else
    echo "File does not exist. Creating the file."
    > "$FILE"
fi


rm -f "$OUTPUT_FILE"
touch "$OUTPUT_FILE"

for i in /etc/config/*
do
	[ -f "$i" ] || continue
    filename=$(basename "$i")
    #echo "filename=$filename"
    flag=0

    # If exclude.txt exists, check if current file should be excluded
    
		if [ -f "/root/exclude.txt" ]; then
			n=$(wc -l < /root/exclude.txt)
			for j in $(seq 1 $n)
			do 
				#ExcludeFileName=$(head -$j /root/exclude.txt | tail -1)
				TargetFile=$(head -$j /root/exclude.txt | tail -1 | sed 's/[[:space:]]//g')
				
				[ -z "$TargetFile" ] && continue

				if [ "$filename" = "$TargetFile" ]

				then
					flag=1
					break
				fi
			done
        else
			echo "WARNING: /root/include.txt not found. Including all files."
			flag=0  # Optionally include all if no include list
		fi
		
		if [ $flag -eq 0 ]; then
			echo "INFO: Including file: $filename"
			echo "file $filename" >> "$OUTPUT_FILE"
			cat "$i" >> "$OUTPUT_FILE"
		fi
		
done

DATE=$(date +"%d_%m_%y")
TIME=$(date +"%H_%M_%S")
cp "$OUTPUT_FILE" "/usr/${site_name}_${serial_num}_${DATE}_${TIME}.txt"
TEMP_FILE="/usr/${site_name}_${serial_num}_${DATE}_${TIME}.txt"
TEMP_FILENAME=$(basename "$TEMP_FILE")
FTP_ENABLED=$(uci get importexportconfig.ftpconfig.enableftp 2>/dev/null)

if [ "$FTP_ENABLED" = "1" ]; then

	FTP_SERVER=$(uci get importexportconfig.ftpconfig.serverurl)
	USERNAME=$(uci get importexportconfig.ftpconfig.username)
	PASSWORD=$(uci get importexportconfig.ftpconfig.password)

	MAX_RETRIES=3
	RETRY_DELAY=30  # seconds
	RETRY_COUNT=0

	# Upload with retry logic
	while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
		echo "Attempt $(($RETRY_COUNT + 1)) to upload $TEMP_FILE..."
		timestamp=$(date)
		curl -T "$TEMP_FILE" --user "$USERNAME:$PASSWORD" "$FTP_SERVER"
		if [ $? -eq 0 ]; then
			echo "$timestamp  File $TEMP_FILENAME uploaded successfully on attempt $(($RETRY_COUNT + 1))." | tee -a "$FILE"
			break
		else
			echo "$timestamp File $TEMP_FILENAME Upload failed" | tee -a "$FILE"
			RETRY_COUNT=$((RETRY_COUNT + 1))
			sleep $RETRY_DELAY
		fi
	done

	# Final check
	if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
		echo " Failed to upload file after $MAX_RETRIES attempts."
	else
		# Delete temp file after successful upload
		rm -f "$TEMP_FILE"
		echo " Temp file removed: $TEMP_FILE"
	fi	
else
    echo "FTP upload is disabled in config"
fi
