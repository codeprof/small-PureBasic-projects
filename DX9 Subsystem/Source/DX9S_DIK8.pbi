;########################################################
;# DX9Subsystem Keyboard commands ©2006 Stefan Moebius  #
;########################################################

;Adapted for PB 4.0

XIncludeFile "DInput8.pbi"

Global DIK8_GuidInst.GUID 
Global DIK8_Inst 
Global *DIK8_DInput.IDirectInput8A 
Global *DIK8_Device.IDirectInputDevice8A 
Global DIK8_Buffer1 
Global DIK8_Buffer2 
Global DIK8_Buffer3
Global Keys.DIK8Keys
Global DIK8_Window
Global DIK8_International


Procedure DIK8_FreeKeyboard()
  If DIK8_Buffer1:GlobalFree_(DIK8_Buffer1):DIK8_Buffer1=0:EndIf 
  If DIK8_Buffer2:GlobalFree_(DIK8_Buffer2):DIK8_Buffer2=0:EndIf 
  If DIK8_Buffer3:GlobalFree_(DIK8_Buffer3):DIK8_Buffer3=0:EndIf 
  If *DIK8_Device:*DIK8_Device\UnAcquire():*DIK8_Device\Release():*DIK8_Device=0:EndIf 
  If *DIK8_DInput:*DIK8_DInput\Release():*DIK8_DInput=0:EndIf 
  If DIK8_Inst:FreeLibrary_(DIK8_Inst):DIK8_Inst=0:EndIf 
  DIK8_International=0
EndProcedure 

Procedure DIK8_FreeDevice()
  If DIK8_Buffer1:GlobalFree_(DIK8_Buffer1):DIK8_Buffer1=0:EndIf 
  If DIK8_Buffer2:GlobalFree_(DIK8_Buffer2):DIK8_Buffer2=0:EndIf 
  If DIK8_Buffer3:GlobalFree_(DIK8_Buffer3):DIK8_Buffer3=0:EndIf 
  If *DIK8_Device:*DIK8_Device\UnAcquire():*DIK8_Device\Release():*DIK8_Device=0:EndIf 
EndProcedure 

Procedure ___DInputCB(*DI.DIDEVICEINSTANCE,dummy) 
  RtlMoveMemory_(DIK8_GuidInst,*DI\GuidInstance,SizeOf(guid)) 
EndProcedure 

Procedure DIK8_InitKeyboard() 
  DIK8_FreeKeyboard()
  
  DIK8_Inst=LoadLibrary_("DInput8.dll") 
  If DIK8_Inst=0:ProcedureReturn 0:EndIf 
  
  Func=GetProcAddress_(DIK8_Inst,"DirectInput8Create") 
  If Func=0:DIK8_FreeKeyboard():ProcedureReturn 0:EndIf 
  
  CallFunctionFast(Func,GetModuleHandle_(0),$800,?___DInput8,@*DIK8_DInput,0) 
  
  If *DIK8_DInput=0:DIK8_FreeKeyboard():ProcedureReturn 0:EndIf 
  
  If *DIK8_DInput\EnumDevices(#DI8DEVCLASS_KEYBOARD,@___DInputCB(),0,0):ProcedureReturn 0:EndIf
ProcedureReturn 1
EndProcedure

  
Procedure DIK8_CreateDevice(hWnd)  
  DIK8_FreeDevice()
  If *DIK8_DInput=0:ProcedureReturn 0:EndIf
  If IsWindow_(hWnd):hWnd=GetForegroundWindow_():EndIf
  DIK8_Window=hWnd
  *DIK8_DInput\CreateDevice(DIK8_GuidInst,@*DIK8_Device,0) 
  
  If *DIK8_Device=0:DIK8_FreeDevice():ProcedureReturn 0:EndIf 
  
  Result=*DIK8_Device\SetCooperativeLevel(hWnd,#DISCL_FOREGROUND|#DISCL_NONEXCLUSIVE|#DISCL_NOWINKEY) 
  If Result:DIK8_FreeDevice():ProcedureReturn 0:EndIf 
  
  i.DIDATAFORMAT 
  i\dwSize=24 

  i\dwObjSize=16 
  i\dwFlags=2 
  i\dwDataSize=256 
  i\dwNumObjs=256 
  i\rgodf=Keys
 
  G.guid 
  G\data1=1433567776 
  G\data2=-11460 
  G\data3=4559 
  G\data4[0]=-65 
  G\data4[1]=-57 
  G\data4[2]=68 
  G\data4[3]=69 
  G\data4[4]=83 
  G\data4[5]=84 
  G\data4[6]=0 
  G\data4[7]=0 
  
  For Nr=0 To 255 
    Keys\Key[Nr]\pguid=G 
    Keys\Key[Nr]\dwOfs=Nr 
    Keys\Key[Nr]\dwType=$8000000C+(Nr*256) 
    Keys\Key[Nr]\dwFlags=0 
  Next 
  
  Result=*DIK8_Device\SetDataFormat(i) 
  If Result:DIK8_FreeDevice():ProcedureReturn 0:EndIf 
  
  Result=*DIK8_Device\Acquire() 
  If Result:DIK8_FreeDevice():ProcedureReturn 0:EndIf 
  
  DIK8_Buffer1=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,256) ;1 buffer would be better...
  DIK8_Buffer2=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,256) 
  DIK8_Buffer3=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,256) 
  
  If DIK8_Buffer1=0 Or DIK8_Buffer2=0 Or DIK8_Buffer3=0:DIK8_FreeDevice():ProcedureReturn 0:EndIf 
  DIK8_International=0
   
  ProcedureReturn *DIK8_Device
EndProcedure 



Procedure DIK8_ExamineKeyboard() 
  If *DIK8_Device=0:DIK8_CreateDevice(0):EndIf
  If *DIK8_Device=0:ProcedureReturn 0:EndIf
  RtlMoveMemory_(DIK8_Buffer2,DIK8_Buffer1,256) 
  If GetKeyboardState_(DIK8_Buffer3)=0:ProcedureReturn 0:EndIf
  *DIK8_Device\Acquire()
  Result=*DIK8_Device\GetDeviceState(256,DIK8_Buffer1) 
  If Result=0:ProcedureReturn 1:EndIf
EndProcedure 

Procedure DIK8_KeyUp(Key) 
  If *DIK8_Device=0:ProcedureReturn 0:EndIf
  If DIK8_International
    Key=MapVirtualKeyEx_(MapVirtualKeyEx_(Key,1,0),0,GetKeyboardLayout_(0))
  EndIf
  If PeekB(DIK8_Buffer1+Key)=0 And PeekB(DIK8_Buffer2+Key)&$80:ProcedureReturn 1:EndIf 
  ProcedureReturn 0 
EndProcedure 

Procedure DIK8_KeyDown(Key) 
  If *DIK8_Device=0:ProcedureReturn 0:EndIf
  If DIK8_International
    Key=MapVirtualKeyEx_(MapVirtualKeyEx_(Key,1,0),0,GetKeyboardLayout_(0))
  EndIf
  If PeekB(DIK8_Buffer1+Key)&$80 And PeekB(DIK8_Buffer2+Key)=0:ProcedureReturn 1:EndIf 
  ProcedureReturn 0
EndProcedure 

Procedure DIK8_KeyPushed(Key) 
  If *DIK8_Device=0:ProcedureReturn 0:EndIf
  If DIK8_International
    Key=MapVirtualKeyEx_(MapVirtualKeyEx_(Key,1,0),0,GetKeyboardLayout_(0))
  EndIf
  If PeekB(DIK8_Buffer1+Key)&$80:ProcedureReturn 1:EndIf 
  ProcedureReturn 0
EndProcedure 

Procedure.s DIK8_Inkey()
  If *DIK8_Device=0:ProcedureReturn "":EndIf

  For VK=0 To 255
    If PeekB(DIK8_Buffer3+VK)&1<<8
      Chars=0
      len=ToAscii_(VK,MapVirtualKey_(VK,0),DIK8_Buffer3,@Chars,0)
      If len>0:ProcedureReturn PeekS(@Chars,4):EndIf
    EndIf
  Next
  ProcedureReturn ""
EndProcedure


Procedure DIK8_SetKeyboardMode(Mode)
  If *DIK8_Device=0:ProcedureReturn 0:EndIf

  If Mode&#PB_Keyboard_Qwerty   
    DIK8_International=0
  Else
    DIK8_International=1
  EndIf      

  If Mode&#PB_Keyboard_AllowSystemKeys
    Result=*DIK8_Device\SetCooperativeLevel(DIK8_Window,#DISCL_FOREGROUND|#DISCL_NONEXCLUSIVE) 
  Else
    Result=*DIK8_Device\SetCooperativeLevel(DIK8_Window,#DISCL_FOREGROUND|#DISCL_NONEXCLUSIVE|#DISCL_NOWINKEY) 
  EndIf
  
  If Result=0:ProcedureReturn 1:EndIf
EndProcedure  


;================================================================== 
; 
;================================================================== 


; IDE Options = PureBasic v4.00 (Windows - x86)
; CursorPosition = 119
; Folding = --