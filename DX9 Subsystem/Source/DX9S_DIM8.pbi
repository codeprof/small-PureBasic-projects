;########################################################
;#   DX9Subsystem Mouse commands ©2006 Stefan Moebius   #
;########################################################

;Adapted for PB 4.0

XIncludeFile "DInput8.pbi" 

Global DIM8_Inst 
Global *DIM8_DInput.IDirectInput8A 
Global *DIM8_Device.IDirectInputDevice8A 

Global DIM8_State.DIMOUSESTATE2 
Global DIM8_Window
Global DIM8_MouseX
Global DIM8_MouseY
Global DIM8_Released

Procedure DIM8_FreeMouse()
  If *DIM8_Device:*DIM8_Device\UnAcquire():*DIM8_Device\Release():*DIM8_Device=0:EndIf 
  If *DIM8_DInput:*DIM8_DInput\Release():*DIM8_DInput=0:EndIf 
  If DIM8_PrevCursor:SetCursor_(DIM8_PrevCursor):EndIf
  If DIM8_Inst:FreeLibrary_(DIM8_Inst):DIM8_Inst=0:EndIf 
EndProcedure 

Procedure DIM8_FreeDevice()
  DIM8_HideMouseCount=0
  If *DIM8_Device:*DIM8_Device\UnAcquire():*DIM8_Device\Release():*DIM8_Device=0:EndIf 
  If DIM8_PrevCursor:SetCursor_(DIM8_PrevCursor):EndIf
EndProcedure 

Procedure DIM8_InitMouse() 
  DIM8_FreeMouse()
  
  DIM8_Inst=LoadLibrary_("DInput8.dll") 
  If DIM8_Inst=0:ProcedureReturn 0:EndIf 
  
  Func=GetProcAddress_(DIM8_Inst,"DirectInput8Create") 
  If Func=0:DIM8_FreeMouse():ProcedureReturn 0:EndIf 
  
  CallFunctionFast(Func,GetModuleHandle_(0),$800,?___DInput8,@*DIM8_DInput,0) 
  
  If *DIM8_DInput=0:DIM8_FreeMouse():ProcedureReturn 0:EndIf 
  
  ProcedureReturn 1
EndProcedure

  
Procedure DIM8_CreateDevice(hWnd)  
  DIM8_FreeDevice()
  If *DIM8_DInput=0:ProcedureReturn 0:EndIf
  If IsWindow_(hWnd)=0:hWnd=GetForegroundWindow_():EndIf
  DIM8_Window=hWnd
  *DIM8_DInput\CreateDevice(?GUID_SysMouse,@*DIM8_Device,0) 
  
  If *DIM8_Device=0:DIM8_FreeDevice():ProcedureReturn 0:EndIf 
  
  Result=*DIM8_Device\SetCooperativeLevel(hWnd,#DISCL_FOREGROUND|#DISCL_EXCLUSIVE) 
  If Result:DIM8_FreeDevice():ProcedureReturn 0:EndIf 
  
  dfDIMouse2.dfDIMouse2\dfDIMouse2[0]\pguid=0;GUID_XAxis 
  dfDIMouse2\dfDIMouse2[1]\pguid=0;GUID_YAxis 
  dfDIMouse2\dfDIMouse2[2]\pguid=0;GUID_ZAxis 
  
  For i=3 To 10
    dfDIMouse2\dfDIMouse2[i]\pguid=0;GUID_Button 
  Next
  
  dfDIMouse2\dfDIMouse2[0]\dwType=#DIDFT_ANYINSTANCE|#DIDFT_AXIS
  dfDIMouse2\dfDIMouse2[1]\dwType=#DIDFT_ANYINSTANCE|#DIDFT_AXIS
  dfDIMouse2\dfDIMouse2[2]\dwType=#DIDFT_OPTIONAL|#DIDFT_ANYINSTANCE|#DIDFT_AXIS  
  
  For i=5 To 10
    dfDIMouse2\dfDIMouse2[i]\dwType=#DIDFT_OPTIONAL|#DIDFT_ANYINSTANCE|#DIDFT_BUTTON
  Next
  
  dfDIMouse2\dfDIMouse2[4]\dwType=#DIDFT_ANYINSTANCE|#DIDFT_BUTTON 
  dfDIMouse2\dfDIMouse2[3]\dwType=#DIDFT_ANYINSTANCE|#DIDFT_BUTTON 
  
  dfDIMouse2\dfDIMouse2[0]\dwOfs=OffsetOf(DIMOUSESTATE2\lx)  
  dfDIMouse2\dfDIMouse2[1]\dwOfs=OffsetOf(DIMOUSESTATE2\ly) 
  dfDIMouse2\dfDIMouse2[2]\dwOfs=OffsetOf(DIMOUSESTATE2\lz)  
  dfDIMouse2\dfDIMouse2[3]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons) 
  dfDIMouse2\dfDIMouse2[4]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+1 
  dfDIMouse2\dfDIMouse2[5]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+2
  dfDIMouse2\dfDIMouse2[6]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+3 
  dfDIMouse2\dfDIMouse2[7]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+4
  dfDIMouse2\dfDIMouse2[8]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+5 
  dfDIMouse2\dfDIMouse2[9]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+6
  dfDIMouse2\dfDIMouse2[10]\dwOfs=OffsetOf(DIMOUSESTATE2\rgbButtons)+7
  
  c_dfDIMouse2.DIDATAFORMAT \dwSize=SizeOf(DIDATAFORMAT) 
  c_dfDIMouse2\dwObjSize=SizeOf(DIOBJECTDATAFORMAT) 
  c_dfDIMouse2\dwFlags=2 ;DIDF_RELAXIS
  c_dfDIMouse2\dwDataSize=20 
  c_dfDIMouse2\dwNumObjs=11
  c_dfDIMouse2\rgodf=dfDIMouse2
  
  Result=*DIM8_Device\SetDataFormat(c_dfDIMouse2) 
  If Result:DIM8_FreeDevice():ProcedureReturn 0:EndIf 
  
  Result=*DIM8_Device\Acquire() 
  If Result:DIM8_FreeDevice():ProcedureReturn 0:EndIf  
  
  ProcedureReturn *DIM8_Device
EndProcedure 


Procedure DIM8_ExamineMouse(ScreenWidth,ScreenHeight) 
  If *DIM8_Device=0:DIM8_CreateDevice(0):EndIf
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf
  *DIM8_Device\Acquire()
  Result=*DIM8_Device\GetDeviceState(SizeOf(DIMOUSESTATE2),@DIM8_State.DIMOUSESTATE2)
  DIM8_MouseX+DIM8_State\lx
  DIM8_MouseY+DIM8_State\ly
  If DIM8_MouseX<0:DIM8_MouseX=0:EndIf
  If DIM8_MouseY<0:DIM8_MouseY=0:EndIf
  
  If DIM8_MouseX>ScreenWidth-1:DIM8_MouseX=ScreenWidth-1:EndIf
  If DIM8_MouseY>ScreenHeight-1:DIM8_MouseY=ScreenHeight-1:EndIf
  
  If Result=0:ProcedureReturn 1:EndIf
EndProcedure 

Procedure DIM8_MouseButton(Button)
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf
  If Button<1 Or Button>8:ProcedureReturn 0:EndIf
  ProcedureReturn DIM8_State\rgbButtons[Button-1]&$80
EndProcedure 

Procedure DIM8_MouseX()
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf
  ProcedureReturn DIM8_MouseX
EndProcedure

Procedure DIM8_MouseY()
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf
  ProcedureReturn DIM8_MouseY
EndProcedure

Procedure DIM8_MouseDeltaX()
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf
  ProcedureReturn DIM8_State\lx
EndProcedure

Procedure DIM8_MouseDeltaY()
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf
  ProcedureReturn DIM8_State\ly
EndProcedure

Procedure DIM8_MouseWheel()
  If *DIM8_Device=0 Or DIM8_Released:ProcedureReturn 0:EndIf

dipdw.DIPROPDWORD\diph\dwSize=SizeOf(DIPROPDWORD)
dipdw\diph\dwHeaderSize=SizeOf(DIPROPHEADER)
dipdw\diph\dwObj=8; offset
dipdw\diph\dwHow=#DIPH_BYOFFSET

*DIM8_Device\GetProperty(#DIPROP_GRANULARITY,dipdw)
  
  ProcedureReturn DIM8_State\lz/dipdw\dwData
EndProcedure

Procedure DIM8_ReleaseMouse(State)
  If *DIM8_Device=0:ProcedureReturn 0:EndIf
  
  If State
    
    Result=*DIM8_Device\UnAcquire()
    If Result:ProcedureReturn 0:EndIf
    DIM8_Released=1
    
  Else
    
    Result=*DIM8_Device\Acquire()
    If Result:ProcedureReturn 0:EndIf
    DIM8_Released=0
    
  EndIf
  
  
  ProcedureReturn 1
EndProcedure




Procedure DIM8_MouseLocate(X,Y,ScreenWidth,ScreenHeight)
  If *DIM8_Device=0:ProcedureReturn 0:EndIf
  
  DIM8_MouseX=X
  DIM8_MouseY=Y
  If DIM8_MouseX<0:DIM8_MouseX=0:EndIf
  If DIM8_MouseY<0:DIM8_MouseY=0:EndIf
  
  If DIM8_MouseX>ScreenWidth-1:DIM8_MouseX=ScreenWidth-1:EndIf
  If DIM8_MouseY>ScreenHeight-1:DIM8_MouseY=ScreenHeight-1:EndIf
  ProcedureReturn 1
EndProcedure



;================================================================== 
; 
;================================================================== 


; IDE Options = PureBasic v4.00 (Windows - x86)
; CursorPosition = 163
; FirstLine = 151
; Folding = ---