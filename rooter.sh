#!/system/bin/sh

PACKAGE_NAME="$1"

sleep 3

OWNER_ID_USERNAME=$(stat -c '%U' /data/data/"$PACKAGE_NAME" 2>/dev/null)

su -l "$OWNER_ID_USERNAME" -c "su"
exit $?