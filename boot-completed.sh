if [[ -e /data/local/tmp/first_run ]]; then
  pm install-existing com.samsung.android.smartsuggestions
  pm install-existing --user 0 com.samsung.android.smartsuggestions
  pm compile -r bg-dexopt com.samsung.android.smartsuggestions
  rm /data/local/tmp/first_run
  touch /data/local/tmp/setup_completed
fi
