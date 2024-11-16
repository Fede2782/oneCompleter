# Loop fino a quando ro.boot.completed non è uguale a 1
while [ "$(getprop ro.boot.completed)" != "1" ]; do
    sleep 1
done

qsettings=$(settings get secure sysui_qs_tiles)

pm disable com.samsung.android.smartmirroring/com.samsung.android.smartmirroring.settings.DisableSecondScreenActivity
pm enable com.samsung.android.smartmirroring/com.samsung.android.smartmirroring.player.SecondScreenActivity
pm enable com.samsung.android.smartmirroring/com.samsung.android.smartmirroring.tile.ScreenSharingTile
pm enable com.samsung.android.smartmirroring/.player.SecondScreenActivity
pm enable com.samsung.android.smartmirroring/.tile.ScreenSharingTile
pm enable com.samsung.android.smartsuggestions/com.samsung.android.smartsuggestions.widget.appwidget.SmartSuggestionsWidgetProvider

if [[ $qsettings == *"ScreenSharing"* ]]; then
  echo "The string contains 'ScreenSharing'. No further action needed." >> /dev/null
else
  # Add your additional actions here
  settings put secure sysui_qs_tiles "$qsettings,custom(com.samsung.android.smartmirroring/.tile.ScreenSharingTile)"
fi
