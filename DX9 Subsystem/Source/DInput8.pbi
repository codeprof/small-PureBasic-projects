#DISCL_BACKGROUND=8 
#DISCL_NONEXCLUSIVE=2 
#DISCL_EXCLUSIVE=1 
#DISCL_FOREGROUND=4 
#DISCL_NOWINKEY=16 

#DIDFT_BUTTON=12
#DIDFT_AXIS=3 
#DIDFT_ANYINSTANCE=16776960
#DIDFT_OPTIONAL=2147483648

#DI8DEVCLASS_KEYBOARD=3;Keyboard
#DI8DEVCLASS_GAMECTRL=4


Structure DIDEVICEINSTANCE 
  dwSize.l 
  GuidInstance.guid 
  GuidProduct.guid 
  dwDevType.l 
  tszInstanceName.b[#MAX_PATH] 
  tszProductName.b[#MAX_PATH] 
  guidFFDriver.guid 
  wUsagePage.w 
  wUsage.w 
EndStructure 

Structure DIOBJECTDATAFORMAT 
  pguid.l 
  dwOfs.l 
  dwType.l 
  dwFlags.l 
EndStructure 

Structure DIDATAFORMAT 
  dwSize.l 
  dwObjSize.l 
  dwFlags.l 
  dwDataSize.l 
  dwNumObjs.l 
  rgodf.l 
EndStructure 

Structure DIMOUSESTATE2 
  lx.l 
  ly.l 
  lz.l 
  rgbButtons.b[8] 
EndStructure 

    
Structure DIPROPHEADER
  dwSize.l
  dwHeaderSize.l
  dwObj.l
  dwHow.l
EndStructure

Structure DIPROPDWORD
  diph.DIPROPHEADER
  dwData.l
EndStructure

#DIPH_BYOFFSET=1
#DIPROP_GRANULARITY=3

Structure dfDIMouse2
dfDIMouse2.DIOBJECTDATAFORMAT[11]
EndStructure

Structure DIK8Keys
Key.DIOBJECTDATAFORMAT[256]
EndStructure

Structure DIJOYSTATE 
    lX.l
    lY.l
    lZ.l
    lRx.l
    lRy.l
    lRz.l
    rglSlider.l[2]
    rgdwPOV.l[4]
    rgbButtons.b[32]
EndStructure


DataSection 
___DInput8:;GUID 
Data.b 48,-128,121,-65,58,72,-94,77,-86,-103,93,100,-19,54,-105,0 

GUID_SysMouse:
Data.l $6F1D2B60
Data.w $D5A0,$11CF
Data.b $BF,$C7,$44,$45,$53,$54,$00,$00
EndDataSection 
; IDE Options = PureBasic v4.02 (Windows - x86)
; CursorPosition = 95
; FirstLine = 61
; Folding = -