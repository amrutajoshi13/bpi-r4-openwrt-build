#!/bin/sh
# ==========================================
# Restore configuration files from tar.gz
# ==========================================

TAR_FILE="/tmp/configs_backup.tar.gz"
ROOT_DIR="/root"

# Temporary extraction folder
TMP_EXTRACT="/tmp/configs_extract"

# 1) Clean temporary extraction folder
rm -rf "$TMP_EXTRACT"
mkdir -p "$TMP_EXTRACT"

# 2) Extract archive to temporary folder
tar -xzf "$TAR_FILE" -C "$TMP_EXTRACT"

# 3) Restore files to their original location
cd "$TMP_EXTRACT"

# Loop through all extracted files
find . -type f | while IFS= read -r file; do
    # Remove leading ./ from find output
    REL_PATH="${file#./}"
    
    # Target full path in /root
    TARGET="$ROOT_DIR/$REL_PATH"

    # Make sure target directory exists
    DIRNAME=$(dirname "$TARGET")
    [ -d "$DIRNAME" ] || mkdir -p "$DIRNAME"

    # Copy/overwrite only the extracted files
    cp -f "$file" "$TARGET"
done

# 4) Clean temporary folder
rm -rf "$TMP_EXTRACT"

echo "Restore completed successfully."

/root/usrRPC/script/Board_Recycle_12V_Script.sh
exit 0
