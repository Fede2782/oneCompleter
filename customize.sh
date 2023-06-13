MAXAPI=33
MINAPI=33

SKIPUNZIP=1

if [[ "$(getprop ro.build.PDA)" == "P615XXS5FWD2" ]]; then
    echo "Supported software version: P615XXS5FWD2"
else
    ui_print "Unsupported device or version: '$(getprop ro.build.PDA)'"
    ui_print "P615XXS5FWD2 required for this module's version"
    abort
fi

#Check space (Thanks to ChatGPT for making my script work with Android)
#At the moment 2GB should be enough
required_storage=2048

# Get the output of df command and filter out the header using tail
df_output=$(df /data -BM | tail -n +2)

# Loop through each line of the df output
while read -r line; do
  # Extract the available storage value from each line
  available_storage=$(echo "$line" | awk '{print $4}' | sed 's/[^0-9]//g')
  avail_storage_gb=$(($available_storage / 1024))

  # Check if available storage is greater than or equal to the required storage
  if [ "$available_storage" -ge "$required_storage" ]; then
    ui_print "There is enough storage available: $avail_storage_gb GB."
  else
    echo "Not enough space available: $avail_storage_gb GB."
    abort
  fi
done <<< "$df_output"

ui_print "- Extracting module files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH

ui_print "- Creating temp directory..."
mkdir $MODPATH/tmp

ui_print "- Installing large apps..."

ui_print "- Installing AR Emoji Editor..."
wget -O $MODPATH/tmp/AREmojiEditor.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/AREmojiEditor.tar.gz"
mkdir $MODPATH/system/priv-app/AREmojiEditor/
tar -xvf $MODPATH/tmp/AREmojiEditor.tar.gz -C $MODPATH/system/priv-app/AREmojiEditor/

ui_print "- Installing AR Emoji Stickers..."
wget -O $MODPATH/tmp/AvatarEmojiSticker.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/AvatarEmojiSticker.tar.gz"
mkdir $MODPATH/system/priv-app/AvatarEmojiSticker/
tar -xvf $MODPATH/tmp/AvatarEmojiSticker.tar.gz -C $MODPATH/system/priv-app/AvatarEmojiSticker/

ui_print "- Installing AR Emoji..."
wget -O $MODPATH/tmp/AREmoji.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/AREmoji.tar.gz"
mkdir $MODPATH/system/priv-app/AREmoji/
tar -xvf $MODPATH/tmp/AREmoji.tar.gz -C $MODPATH/system/priv-app/AREmoji/

ui_print "- Installing Smart Suggestions..."
wget -O $MODPATH/tmp/SamsungSmartSuggestions.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/SamsungSmartSuggestions.tar.gz"
mkdir $MODPATH/system/priv-app/SamsungSmartSuggestions/
tar -xvf $MODPATH/tmp/SamsungSmartSuggestions.tar.gz -C $MODPATH/system/priv-app/SamsungSmartSuggestions/

ui_print "- Installing Camera Kit by Snapchat (for fun mode)..."
wget -O $MODPATH/tmp/FunModeSDK.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/FunModeSDK.tar.gz"
mkdir $MODPATH/system/app/FunModeSDK/
tar -xvf $MODPATH/tmp/FunModeSDK.tar.gz -C $MODPATH/system/app/FunModeSDK/

ui_print "- Installing new Samsung Weather..."
wget -O $MODPATH/tmp/SamsungWeather.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/SamsungWeather.tar.gz"
tar -xvf $MODPATH/tmp/SamsungWeather.tar.gz -C $MODPATH/system/app/SamsungWeather/

ui_print "- Installing AI models for Styles and Erasers in Photo Editor.."
wget -O $MODPATH/tmp/EditorFiles.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/EditorFiles.tar.gz"
tar -xvf $MODPATH/tmp/EditorFiles.tar.gz -C $MODPATH/system/etc/

ui_print "- Now clearing temp files and system cache to make everything working..."
rm -rf /data/system/package_cache/*
rm -rf $MODPATH/tmp

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0777 0755

