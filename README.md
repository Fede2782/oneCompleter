# oneCompleter

![Version](https://img.shields.io/github/v/release/Fede2782/oneCompleter?style=flat"/>)
![Size](https://img.shields.io/github/repo-size/Fede2782/oneCompleter?style=flat"/>)
![Commit](https://img.shields.io/github/last-commit/Fede2782/oneCompleter/sep-15.x?style=flat-square"/>)

Add missing One UI features to different devices and much more...

You can flash this Magisk module at your own risk. I am not responsible for lost warranty, bootloops, lost data, or any other damage to your device.

## Requirements:
- One UI 6.1 or One UI 6.1.1 device with One UI (One UI Core not supported)
- Latest KernelSU
- Clean system (stock ROM, no modifications to stock ROM with Magisk/KernelSU or other methods)
- 1GB of free storage

## Credits
These amazing features were created by Samsung. None of this would have been possible if Samsung hadn't created these features.

Pixelify for the Zygisk spoofing implementation. BlackMesa123 for floating feature script.

## 💡Little tip

This module installs some big apps and libs. I suggest you use Galaxy App Booster (Samsung official app of Good Guardians suite) after every big module update, so the tablet will not slow down. A "wipe cache" or "Repair apps" in Recovery may be useful in some cases. Moreover, make sure all apps are up-to-date before/after installing this module (Play Store and Galaxy Store).

## Features Now:
- ✅️ Smart Suggestions Widget (thanks to BlackMesa123, only in One UI 6.1.1 and later)
- ✅️ Camera Privacy toggle 
- ✅️ High End animations in stock launcher
- ✅️ Extra Dim
- ✅️ Galaxy Watch Camera controller
- ✅️ SmartView App cast
- ✅️ Screen Curtain
- ✅️ OCR in Samsung apps
- ✅️ Voice Recoder Transcription and Interview mode
- ✅️ Google's Circle to Search
- ✅️ 2024-style bootanimation*¹
- ✅️ Wireless DeX*⁴

*¹ Currently only A34, A54, A33, A53 are supported
*⁴ Requires a proper kernel and system support. 

## Configuration
You can configure the first installation by editing the config.sh file inside the module. 

## ⚠️ Uninstall/Disable and OS updates
Never disable this module because it may create big issues in the system. In this case, install again the module. If you have booted in Safe Mode you should reinstall it too. Never update One UI/Android version (One UI 5 -> 5.1, Android 12 -> 13) with the module installed, uninstall the module before doing the update and then install it again. 

## Other Info
Feel free to contribute if you have some ideas or ways to enable or add these features.

Big files are stored here to reduce zip file size: https://gitlab.com/Fede2782/onecompleter-files/

If you want to test new builds immediately you can download artifacts from Github actions.
