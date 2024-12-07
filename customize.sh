MAXAPI=34
MINAPI=34

SKIPUNZIP=1

if [[ "$(getprop ro.system.product.cpu.abilist64)" == *"arm64-v8a"* ]]; then
    ui_print "- Supported architecture: $(getprop ro.system.product.cpu.abilist64)"
else
    ui_print "Unsupported architecture: $(getprop ro.system.product.cpu.abilist)"
    ui_print "64-bit Android required for this module."
    abort
fi

if [[ "$(getprop ro.build.version.oneui)" == "60101" || "$(getprop ro.build.version.oneui)" == "60100" ]]; then
    ui_print "- Supported One UI version"
else
    ui_print "Unsupported One UI version: $(getprop ro.build.version.oneui)"
    ui_print "One UI 6.1 (60100) or OneUI 6.1.1 (60101) required for this module's version"
    abort
fi

if grep -q "sep_lite" "/system/etc/floating_feature.xml"; then
    ui_print "One UI Core devices are not supported"
    abort
else
    if [[ ! -e "/system/lib64/libBeauty_v4.camera.samsung.so" ]]; then
        ui_print "One UI Core devices are not supported"
        abort
    fi
    ui_print "- Supported One UI edition"
fi

SET_CONFIG()
{
    local CONFIG="$1"
    local VALUE="$2"
    local FILE="$MODPATH/system/etc/floating_feature.xml"

    if [ ! -e "$FILE" ]; then
	cp "/system/etc/floating_feature.xml" "$FILE"
    fi

    if [[ "$2" == "-d" ]] || [[ "$2" == "--delete" ]]; then
        CONFIG="$(echo -n "$CONFIG" | sed 's/=//g')"
        if grep -Fq "$CONFIG" "$FILE"; then
            ui_print "Deleting \"$CONFIG\" config in /system/system/etc/floating_feature.xml"
            sed -i "/$CONFIG/d" "$FILE"
        fi
    else
        if grep -Fq "<$CONFIG>" "$FILE"; then
            ui_print "Replacing \"$CONFIG\" config with \"$VALUE\" in /system/system/etc/floating_feature.xml"
            sed -i "$(sed -n "/<${CONFIG}>/=" "$FILE") c\ \ \ \ <${CONFIG}>${VALUE}</${CONFIG}>" "$FILE"
        else
            ui_print "Adding \"$CONFIG\" config with \"$VALUE\" in /system/system/etc/floating_feature.xml"
            sed -i "/<\/SecFloatingFeatureSet>/d" "$FILE"
            if ! grep -q "Added by oneCompleter" "$FILE"; then
                echo "    <!-- Added by oneCompleter -->" >> "$FILE"
            fi
            echo "    <${CONFIG}>${VALUE}</${CONFIG}>" >> "$FILE"
            echo "</SecFloatingFeatureSet>" >> "$FILE"
        fi
    fi
}

READ_AND_APPLY_CONFIGS()
{
    local CONFIG_FILE="$MODPATH/sff.sh"

    if [ -f "$CONFIG_FILE" ]; then
        while read -r i; do
            [[ "$i" = "#"* ]] && continue
            [[ -z "$i" ]] && continue

            if [[ "$i" == *"delete" ]] || [[ -z "$(echo -n "$i" | cut -d "=" -f 2)" ]]; then
                SET_CONFIG "$(echo -n "$i" | cut -d " " -f 1)" --delete
            elif echo -n "$i" | grep -q "="; then
                SET_CONFIG "$(echo -n "$i" | cut -d "=" -f 1)" "$(echo -n "$i" | cut -d "=" -f2-)"
            else
                echo "Malformed string in $MODPATH/sff.sh: \"$i\""
                return 1
            fi
        done < "$CONFIG_FILE"
    fi
}

ui_print "- Extracting module files..."
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >> /dev/null
#mkdir $MODPATH/zygisk
#mv $MODPATH/lib/zygisk/* $MODPATH/zygisk/
#rm -rf $MODPATH/lib

ui_print "- Loading configuration..."
source $MODPATH/config.sh
if [ -e /sdcard/onecompleter/config.sh ]; then
    source /sdcard/onecompleter/config.sh
    ui_print "- Loading configuration in /sdcard/onecompleter/config.sh"
elif [ -e /sdcard/onecompleter/config.sh ]; then
    source /data/adb/modules/onecompleter/config.sh
    ui_print "- Loading previous configuration"
    ui_print "- If you have not customized anything before the default one will be used"
else
    ui_print "- Using default configuration"
fi

ui_print "- Creating temp directory..."
mkdir $MODPATH/tmp

#ui_print "- Installing large apps..."
#mkdir $MODPATH/system/app/
#mkdir $MODPATH/system/priv-app/

mkdir -p $MODPATH/system/etc
READ_AND_APPLY_CONFIGS

if grep -q 'sec_touchpad' /proc/bus/input/devices; then
  if [[ "$(getprop ro.build.characteristics)" == "tablet" ]]; then
    if grep -q 'SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE>standalone,newdex' "/system/etc/floating_feature.xml"; then
      ui_print "- Enabling Wireless DeX"
      ui_print "- - This feature requires a kernel with DeX input driver"
      SET_CONFIG "SEC_FLOATING_FEATURE_COMMON_CONFIG_DEX_MODE" "standalone,newdex,wireless"
    fi
  fi
fi

if [[ $INTERVIEW_MODE == "1" ]]; then
    ui_print "- Enabling Interview mode"
    ui_print "- - This feature requires proper microphone setup"
    SET_CONFIG "SEC_FLOATING_FEATURE_VOICERECORDER_CONFIG_DEF_MODE" "normal,interview,voicememo"
fi

if [[ "$(getprop ro.product.product.name)" == "a34x"* || "$(getprop ro.product.product.name)" == "a54x"* ]]; then
    ui_print "- Using Samsung Galaxy A34 5G or A54 5G"
    ui_print "- Setting up 1080x2340 2024-style boot animation"
    mkdir -p "$MODPATH/system/media"
    tar xvf "$MODPATH/resources/bootanim-1080x2340.tar" -C "$MODPATH/system/media/"
elif [[ "$(getprop ro.product.product.name)" == "a33x"* || "$(getprop ro.product.product.name)" == "a53x"* ]]; then
    ui_print "- Using Samsung Galaxy A33 5G or A53 5G"
    ui_print "- Setting up 1080x2400 2024-style boot animation"
    mkdir -p "$MODPATH/system/media"
    tar xvf "$MODPATH/resources/bootanim-1080x2400.tar" -C "$MODPATH/system/media/"
fi

if [[ "$(getprop ro.product.product.name)" == "a35x"* || "$(getprop ro.product.product.name)" == "a55x"* || "$(getprop ro.product.product.name)" == "a53x"* || "$(getprop ro.product.product.name)" == "a34x"* || "$(getprop ro.product.product.name)" == "a54x"* ]]; then
   ui_print "- Enabling AOD-Lockscreen clock transition..."
   SET_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM" "aodversion=7,clocktransition"
fi

ui_print "- Enabling Camera Assistant"
mkdir -p $MODPATH/system/cameradata
cp /system/cameradata/camera-feature.xml "$MODPATH/system/cameradata/camera-feature.xml"
if grep -q 'CAMERA_ASSISTANT' "$MODPATH/system/cameradata/camera-feature.xml"; then
    ui_print "- - Camera Assistant configuration in camera-feature.xml already present."
    ui_print "- - This means you do not need this feature enabled by oneCompleter or your setup is broken or modifed by other modules."
else
    sed -i '/<\/resources>/d' "$MODPATH/system/cameradata/camera-feature.xml"
    echo "    <local name=\"SUPPORT_CAMERA_ASSISTANT\" value=\"true\"/>" >> "$MODPATH/system/cameradata/camera-feature.xml"
    echo "</resources>" >> "$MODPATH/system/cameradata/camera-feature.xml"
fi

if grep -q 'BATTERY_SUPPORT_BSOH_GALAXYDIAGNOSTICS' "$MODPATH/system/etc/floating_feature.xml"; then
    ui_print "- Enabling advanced battery stats as device is supported..."
    SET_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS" "TRUE"
elif [[ $FORCE_BATTERY_HEALTH == "1" ]]; then
    ui_print "- Enabling advanced battery stats..."
    SET_CONFIG "SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_SETTINGS" "TRUE"
fi

if [[ "$(getprop ro.product.product.name)" == "a34x"* ]]; then
    ui_print "- Enabling OCR v2..."
    tar xvzf "$MODPATH/resources/ocr-mssi.tar.gz" -C "$MODPATH/system/"
    SET_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_STRIDE_OCR_VERSION" "V2"

    ui_print "- Enabling high-end Edge Lighting effect..."
    echo "ro.factory.model=SM-G998B" >> "$MODPATH/system.prop"
    SET_CONFIG "SEC_FLOATING_FEATURE_SYSTEMUI_CONFIG_EDGELIGHTING_FRAME_EFFECT" "frame_effect"

    ui_print "- Enabling better Document Scan..."
    SET_CONFIG "SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS" "CV_DEWARPING,SHADOW_REMOVAL"
    tar xvzf "$MODPATH/resources/camera-mssi.tar.gz" -C "$MODPATH/system/"
    cp /system/etc/public.libraries-camera.samsung.txt "$MODPATH/system/etc/public.libraries-camera.samsung.txt"
    if ! grep -q 'libLttEngine.camera.samsung.so' "$MODPATH/system/etc/public.libraries-camera.samsung.txt"; then
      echo "libLttEngine.camera.samsung.so" >> "$MODPATH/system/etc/public.libraries-camera.samsung.txt"
    fi
    if ! grep -q 'libHIDTSnapJNI.camera.samsung.so' "$MODPATH/system/etc/public.libraries-camera.samsung.txt"; then
      echo "libHIDTSnapJNI.camera.samsung.so" >> "$MODPATH/etc/public.libraries-camera.samsung.txt"
    fi

    if ! grep -q 'SUPPORT_SMART_SCAN_MANUAL_CROP' "$MODPATH/system/cameradata/camera-feature.xml"; then
        sed -i '/<\/resources>/d' "$MODPATH/system/cameradata/camera-feature.xml"
        echo "    <local name=\"SUPPORT_SMART_SCAN_MANUAL_CROP\" value=\"true\"/>" >> "$MODPATH/system/cameradata/camera-feature.xml"
        echo "</resources>" >> "$MODPATH/system/cameradata/camera-feature.xml"
    fi

    if ! grep -q 'SUPPORT_ADDITIONAL_SCENE_DOCUMENT_SCAN' "$MODPATH/system/cameradata/camera-feature.xml"; then
        sed -i '/<\/resources>/d' "$MODPATH/system/cameradata/camera-feature.xml"
        echo "    <local name=\"SUPPORT_ADDITIONAL_SCENE_DOCUMENT_SCAN\" value=\"true\"/>" >> "$MODPATH/system/cameradata/camera-feature.xml"
        echo "</resources>" >> "$MODPATH/system/cameradata/camera-feature.xml"
    fi
fi

ui_print "- Installing new Samsung Smart Suggestions..."
tar xvzf "$MODPATH/resources/SamsungSmartSuggestions-611.tar.gz" -C "$MODPATH/system/"

if grep -q 'SEC_FLOATING_FEATURE_AUDIO_CONFIG_EFFECTS_VIDEOCALL>None' "/system/etc/floating_feature.xml"; then
  if grep -r -q 'l_call_nc_booster_enable' "/vendor"; then
    if grep -r -q 'l_mic_input_control_mode_2mic' "/vendor"; then
      SET_CONFIG "SEC_FLOATING_FEATURE_AUDIO_CONFIG_EFFECTS_VIDEOCALL" "2MIC"
    fi
  fi
fi

rm $MODPATH/sff.sh

ui_print "- Finishing the last things..."
#chmod +x $MODPATH/service.sh

ui_print "- Now clearing temp files and system cache to make everything working..."
rm -rf /data/system/package_cache/*
rm -rf $MODPATH/tmp
rm -rf $MODPATH/resources

pm uninstall --user 0 com.aura.oobe.samsung >> /dev/null
pm uninstall --user 0 com.aura.oobe.samsung.gl >> /dev/null
pm uninstall --user 0 com.ironsource.appcloud.oobe.hutchison >> /dev/null

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH" 0 0 0777 0755

ui_print ""
ui_print "- Done!"
ui_print ""
if [[ $KSU == "true" ]]; then
  ui_print "- Make sure that modules umount feature is disabled"
fi

