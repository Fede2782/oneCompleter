MAXAPI=33
MINAPI=33

SKIPUNZIP=1

if [[ "$(getprop ro.build.PDA)" == "P615XXS7FXA1" || "$(getprop ro.build.PDA)" == "P610XXS4FXA1" ]]; then
    ui_print "Supported software version: $(getprop ro.build.PDA)"
else
    ui_print "Unsupported device or version: $(getprop ro.build.PDA)"
    ui_print "P615XXU7FWH7 or P610XXU4FH7 required for this module's version"
    abort
fi

ui_print "- Extracting module files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH

ui_print "- Creating temp directory..."
mkdir $MODPATH/tmp

ui_print "- Installing large apps..."

#REMOTE vers
#SmartSuggestions 5.2.00.66
#AREmojiStickers 5.2.00.26
#AREmojiEditor 5.2.00.8
#AREmoji 7.5.00.12

ui_print "- Installing AR Emoji Editor..."
wget -O $MODPATH/tmp/AREmojiEditor.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/AREmojiEditor.tar.gz"
mkdir $MODPATH/system/app/
mkdir $MODPATH/system/priv-app/
mkdir $MODPATH/system/priv-app/AREmojiEditor
tar -xvf $MODPATH/tmp/AREmojiEditor.tar.gz -C $MODPATH/system/priv-app/AREmojiEditor/

ui_print "- Installing AR Emoji Stickers..."
wget -O $MODPATH/tmp/AvatarEmojiSticker.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/AvatarEmojiSticker.tar.gz"
mkdir $MODPATH/system/priv-app/AvatarEmojiSticker/
tar -xvf $MODPATH/tmp/AvatarEmojiSticker.tar.gz -C $MODPATH/system/priv-app/AvatarEmojiSticker/

ui_print "- Installing AR Emoji..."
wget -O $MODPATH/tmp/AREmoji.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/AREmoji.tar.gz"
mkdir $MODPATH/system/priv-app/AREmoji/
tar -xvf $MODPATH/tmp/AREmoji.tar.gz -C $MODPATH/system/priv-app/AREmoji/

ui_print "- Installing Camera Kit by Snapchat (for fun mode)..."
wget -O $MODPATH/tmp/FunModeSDK.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/FunModeSDK.tar.gz"
mkdir $MODPATH/system/app/FunModeSDK/
tar -xvf $MODPATH/tmp/FunModeSDK.tar.gz -C $MODPATH/system/app/FunModeSDK/

#ui_print "- Installing new Samsung Weather..."
#wget -O $MODPATH/tmp/SamsungWeather.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/SamsungWeather.tar.gz"
#tar -xvf $MODPATH/tmp/SamsungWeather.tar.gz -C $MODPATH/system/app/SamsungWeather/

ui_print "- Installing AI models for Styles and Erasers in Photo Editor..."
wget -O $MODPATH/tmp/EditorFiles.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/EditorFiles.tar.gz"
tar -xvf $MODPATH/tmp/EditorFiles.tar.gz -C $MODPATH/system/etc/

ui_print "- Installing HashTag Service..."
wget -O $MODPATH/tmp/HashTagService.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/HashTagService.tar.gz"
mkdir $MODPATH/system/priv-app/HashTagService
tar -xvf $MODPATH/tmp/HashTagService.tar.gz -C $MODPATH/system/priv-app/HashTagService/

ui_print "- Installing Full Photo Editor..."
wget -O $MODPATH/tmp/PhotoEditor_Full.tar.gz "https://gitlab.com/Fede2782/onecompleter-files/-/raw/main/PhotoEditor_Full.tar.gz"
mkdir $MODPATH/system/priv-app/PhotoEditor_Full
tar -xvf $MODPATH/tmp/PhotoEditor_Full.tar.gz -C $MODPATH/system/priv-app/PhotoEditor_Full/

#if [[ "$(getprop ro.build.PDA)" == "P610XXS3FWD2" ]]; then
#    ui_print "- Found P610 model"
#    ui_print "- Applying patch...."
#    mv $MODPATH/system/etc/floating_feature_p610.xml $MODPATH/system/etc/floating_feature.xml
#    mv $MODPATH/system/vendor/etc/floating_feature_p610.xml $MODPATH/system/vendor/etc/floating_feature.xml
#else
#    ui_print "- Found P615 model"
#    ui_print "- Cleaning unused files..."
#    rm $MODPATH/system/etc/floating_feature_p610.xml
#    rm $MODPATH/system/vendor/etc/floating_feature_p610.xml
#fi

ui_print "- Finishing the last things..."
chmod +x $MODPATH/service.sh

qsettings=$(settings get secure sysui_qs_tiles)

pm disable com.samsung.android.smartmirroring/com.samsung.android.smartmirroring.settings.DisableSecondScreenActivity
pm enable com.samsung.android.smartmirroring/com.samsung.android.smartmirroring.player.SecondScreenActivity
pm enable com.samsung.android.smartmirroring/com.samsung.android.smartmirroring.tile.ScreenSharingTile
pm enable com.samsung.android.smartsuggestions/com.samsung.android.smartsuggestions.widget.appwidget.SmartSuggestionsWidgetProvider
pm enable com.samsung.android.smartmirroring/.player.SecondScreenActivity
pm enable com.samsung.android.smartmirroring/.tile.ScreenSharingTile

ui_print "- Adding Second Screen tile in Quick Settings..."
ui_print "- If you remove it you may have to install again the module (you don't need to uninstall it first)"
if [[ $qsettings == *"ScreenSharing"* ]]; then
  echo "The string contains 'ScreenSharing'. No further action needed." >> /dev/null
else
  # Add your additional actions here
  settings put secure sysui_qs_tiles "$qsettings,custom(com.samsung.android.smartmirroring/.tile.ScreenSharingTile)"
fi

REMOVE="
/system/priv-app/PhotoEditor_Mid
/system/app/SamsungWeather/SamsungWeather.apk.prof
"

ui_print "- Now clearing temp files and system cache to make everything working..."
rm -rf /data/system/package_cache/*
rm -rf $MODPATH/tmp

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0777 0755

ui_print "- You'll see SecondScreen toggle after reboot in QuickSettings"
ui_print ""
ui_print "- Done!"
ui_print ""
