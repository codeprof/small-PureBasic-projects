@echo off

echo Adding icon to test32bit.exe...
pause
IconMod.exe test32bit.exe /ADD MAINICON /ICON sample.ico
echo showing icon groups of test32bit.exe...
IconMod.exe test32bit.exe /NAMES
pause
echo Remove icon from test32bit.exe...
pause
IconMod.exe test32bit.exe /REMOVE MAINICON
echo showing icon groups of test32bit.exe...
IconMod.exe test32bit.exe /NAMES
pause


echo "Adding icon to test64bit.exe..."
pause
IconMod.exe test64bit.exe /ADD "1" /ICON sample.ico
echo "Remove icon from test64bit.exe..."
pause
IconMod.exe test64bit.exe /REMOVE "1"
pause

