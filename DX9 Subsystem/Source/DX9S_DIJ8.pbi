;########################################################
;# DX9Subsystem Joystick commands ©2006 Stefan Moebius  #
;########################################################

;Adapted for PB 4.0

XIncludeFile "DInput8.pbi" 

Global DIJ8_Inst 
Global *DIJ8_DInput.IDirectInput8A 
Global *DIJ8_Device.IDirectInputDevice8A 

Global DIJ8_State.DIJOYSTATE
Global DIJ8_Window
Global DIJ8_DevGUID.guid

Structure dfDIJoystick
dfDIJoystick.DIOBJECTDATAFORMAT[44]
EndStructure

Procedure ___DInputJoyCB(*DI.DIDEVICEINSTANCE,dummy) 
  RtlMoveMemory_(DIJ8_DevGUID,*DI\GuidInstance,SizeOf(guid)) 
EndProcedure 

Procedure DIJ8_FreeJoystick()
  If *DIJ8_Device:*DIJ8_Device\UnAcquire():*DIJ8_Device\Release():*DIJ8_Device=0:EndIf 
  If *DIJ8_DInput:*DIJ8_DInput\Release():*DIJ8_DInput=0:EndIf 
  If DIJ8_Inst:FreeLibrary_(DIJ8_Inst):DIJ8_Inst=0:EndIf 
EndProcedure 

Procedure DIJ8_FreeDevice()
  If *DIJ8_Device:*DIJ8_Device\UnAcquire():*DIJ8_Device\Release():*DIJ8_Device=0:EndIf 
EndProcedure 

Procedure DIJ8_InitJoystick() 
  DIJ8_FreeJoystick()
  
  DIJ8_Inst=LoadLibrary_("DInput8.dll") 
  If DIJ8_Inst=0:ProcedureReturn 0:EndIf 
  
  Func=GetProcAddress_(DIJ8_Inst,"DirectInput8Create") 
  If Func=0:DIJ8_FreeJoystick():ProcedureReturn 0:EndIf 
  
  CallFunctionFast(Func,GetModuleHandle_(0),$800,?___DInput8,@*DIJ8_DInput,0) 
  
  If *DIJ8_DInput=0:DIJ8_FreeJoystick():ProcedureReturn 0:EndIf 
  
  If *DIJ8_DInput\EnumDevices(#DI8DEVCLASS_GAMECTRL,@___DInputJoyCB(),0,0):ProcedureReturn 0:EndIf
  
  ProcedureReturn 1
EndProcedure

  
Procedure DIJ8_CreateDevice(hWnd)  
  DIJ8_FreeDevice()
  If *DIJ8_DInput=0:ProcedureReturn 0:EndIf
  
  If IsWindow_(hWnd)=0:hWnd=GetForegroundWindow_():EndIf
  DIJ8_Window=hWnd
  
  *DIJ8_DInput\CreateDevice(DIJ8_DevGUID,@*DIJ8_Device,0) 
  
  If *DIJ8_Device=0:DIJ8_FreeDevice():ProcedureReturn 0:EndIf 
  
  Result=*DIJ8_Device\SetCooperativeLevel(hWnd,#DISCL_FOREGROUND|#DISCL_EXCLUSIVE) 
  If Result:DIJ8_FreeDevice():ProcedureReturn 0:EndIf 
  
  dfDIJoystick.dfDIJoystick
dfDIJoystick\dfDIJoystick[0]\pguid=0;GUID_XAxis
dfDIJoystick\dfDIJoystick[1]\pguid=0;GUID_YAxis
dfDIJoystick\dfDIJoystick[2]\pguid=0;GUID_ZAxis
dfDIJoystick\dfDIJoystick[3]\pguid=0;GUID_RxAxis
dfDIJoystick\dfDIJoystick[4]\pguid=0;GUID_RyAxis
dfDIJoystick\dfDIJoystick[5]\pguid=0;GUID_RzAxis
dfDIJoystick\dfDIJoystick[6]\pguid=0;GUID_Slider
dfDIJoystick\dfDIJoystick[7]\pguid=0;GUID_Slider
dfDIJoystick\dfDIJoystick[8]\pguid=0;GUID_POV
dfDIJoystick\dfDIJoystick[9]\pguid=0;GUID_POV
dfDIJoystick\dfDIJoystick[10]\pguid=0;GUID_POV
dfDIJoystick\dfDIJoystick[11]\pguid=0;GUID_POV

dfDIJoystick\dfDIJoystick[0]\dwOfs=0
dfDIJoystick\dfDIJoystick[1]\dwOfs=4
dfDIJoystick\dfDIJoystick[2]\dwOfs=8
dfDIJoystick\dfDIJoystick[3]\dwOfs=12
dfDIJoystick\dfDIJoystick[4]\dwOfs=16
dfDIJoystick\dfDIJoystick[5]\dwOfs=20
dfDIJoystick\dfDIJoystick[6]\dwOfs=24
dfDIJoystick\dfDIJoystick[7]\dwOfs=28
dfDIJoystick\dfDIJoystick[8]\dwOfs=32
dfDIJoystick\dfDIJoystick[9]\dwOfs=36
dfDIJoystick\dfDIJoystick[10]\dwOfs=40
dfDIJoystick\dfDIJoystick[11]\dwOfs=44

For c=0 To 7
dfDIJoystick\dfDIJoystick[c]\dwType=$80FFFF03
dfDIJoystick\dfDIJoystick[c]\dwFlags=$00000100 
Next

For c=8 To 11
dfDIJoystick\dfDIJoystick[c]\dwType=$80FFFF10
dfDIJoystick\dfDIJoystick[c]\dwFlags=0 
Next

For c=12 To 43
dfDIJoystick\dfDIJoystick[c]\pguid=0
dfDIJoystick\dfDIJoystick[c]\dwOfs=c-12+48
dfDIJoystick\dfDIJoystick[c]\dwType=$80FFFF0C
dfDIJoystick\dfDIJoystick[c]\dwFlags=0

Next


c_dfDIJoystick.DIDATAFORMAT 
c_dfDIJoystick\dwSize=24
c_dfDIJoystick\dwObjSize=16 
c_dfDIJoystick\dwFlags=1
c_dfDIJoystick\dwDataSize=80
c_dfDIJoystick\dwNumObjs=44 
c_dfDIJoystick\rgodf=dfDIJoystick
 
  
  Result=*DIJ8_Device\SetDataFormat(c_dfDIJoystick) 
  If Result:DIJ8_FreeDevice():ProcedureReturn 0:EndIf 
  
  Result=*DIJ8_Device\Acquire() 
  If Result:DIJ8_FreeDevice():ProcedureReturn 0:EndIf  
  
  ProcedureReturn *DIJ8_Device
EndProcedure 


Procedure DIJ8_ExamineJoystick() 
  If *DIJ8_Device=0:DIJ8_CreateDevice(0):EndIf
  If *DIJ8_Device=0:ProcedureReturn 0:EndIf
  *DIJ8_Device\Acquire()
  *DIJ8_Device\Poll()
  Result=*DIJ8_Device\GetDeviceState(SizeOf(DIJOYSTATE),@DIJ8_State)
  If Result=0:ProcedureReturn 1:EndIf
EndProcedure 

Procedure DIJ8_Button(Button)
  If *DIJ8_Device=0:ProcedureReturn 0:EndIf
  If Button<1 Or Button>32:ProcedureReturn 0:EndIf
  ProcedureReturn DIJ8_State\rgbButtons[Button-1]&$80
EndProcedure 

Procedure DIJ8_AxisX()
  If *DIJ8_Device=0:ProcedureReturn $7FFF:EndIf
  ProcedureReturn DIJ8_State\lx
EndProcedure 

Procedure DIJ8_AxisY()
  If *DIJ8_Device=0:ProcedureReturn $7FFF:EndIf
  ProcedureReturn DIJ8_State\ly
EndProcedure 




;================================================================== 
; 
;================================================================== 





; IDE Options = PureBasic v4.00 (Windows - x86)
; CursorPosition = 1
; Folding = --