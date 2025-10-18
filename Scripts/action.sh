#!/system/bin/sh

MODULE_ID="yadoru"
MODULE_PATH="/data/adb/modules/$MODULE_ID"
YADORU_SCRIPT="$MODULE_PATH/rooter.sh"
TMP_MENU_FILE="/data/local/tmp/${MODULE_ID}_menu_items.txt"

generate_package_list() {
  pm list packages -3 | sed 's/package://' | sort > "$TMP_MENU_FILE"
}

print_menu() {
  echo "Vol-: Navigation"
  echo "Vol+: Select and Exit"
  echo "Power: Exit"
  echo " "
  
  current_line=1
  while IFS= read -r package_name; do
    if [ -n "$package_name" ]; then
      display_name="$package_name"
      max_len=34 
      if [ ${#display_name} -gt $max_len ]; then
        display_name_short="$(echo "$display_name" | cut -c1-$((max_len-3)))..."
      else
        display_name_short="$display_name"
      fi

      if [ "$current_line" -eq "$selectedIndex" ]; then
        printf ">> %s\n" "$display_name_short"
      else
        printf "   %s\n" "$display_name_short"
      fi
      current_line=$((current_line + 1))
    fi
  done < "$TMP_MENU_FILE"
  echo " "
}

wait_for_key() {
  while true; do
    keyevent=$(getevent -qlc 1 2>/dev/null | grep 'KEY_.*DOWN' | head -n 1)
    case "$keyevent" in
      *KEY_VOLUMEUP*DOWN*) echo "UP"; return ;;
      *KEY_VOLUMEDOWN*DOWN*) echo "DOWN"; return ;;
      *KEY_POWER*DOWN*) echo "POWER"; return ;;
    esac
    sleep 0.05
  done
}

generate_package_list

totalItems=$(wc -l < "$TMP_MENU_FILE" | awk '{print $1}')
selectedIndex=1

print_menu

while true; do
  keyPressed=$(wait_for_key)
  
  case "$keyPressed" in
    "UP")
      selectedPackageName=$(sed -n "${selectedIndex}p" "$TMP_MENU_FILE")
      if [ -n "$selectedPackageName" ]; then
        sh "$YADORU_SCRIPT" "$selectedPackageName" &
      fi
      rm -f "$TMP_MENU_FILE"
      exit 0 # Script shuts down after selection
      ;;

    "DOWN")
      selectedIndex=$((selectedIndex + 1))
      if [ "$selectedIndex" -gt "$totalItems" ]; then
        selectedIndex=1
      fi
      print_menu
      ;;

    "POWER")
      echo " "
      echo "   Script shutdown..."
      echo " "
      sleep 0.5
      rm -f "$TMP_MENU_FILE"
      exit 0
      ;; 
  esac
done

rm -f "$TMP_MENU_FILE"
exit 0