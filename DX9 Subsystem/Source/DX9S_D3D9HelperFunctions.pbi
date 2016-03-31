;######################################################
;# DX9Subsystem Helper functions ©2006 Stefan Moebius #
;######################################################


#H_DEVICE_TRIPLEBUFFERING=1
#H_DEVICE_QUADRUPLEBUFFERING=2
#H_DEVICE_DISABLEVSYNC=4
#H_DEVICE_ZBUFFER=8
#H_DEVICE_STENCILBUFFER=16
#H_DEVICE_LOCKABLE=32

IncludeFile "d3d9_inc.pbi"

Global _H_Timer_Init
Global _H_Timer_Freq.q
Global _H_Timer_Start.q

Global _H_VSync_LastTimeStamp
Global _H_VSync_RestTime

Global _H_ClassRegistered,_H_ClassWindowcount,_H_wc.WNDCLASS 

Global _H_D3DXInst,_H_D3DX8Used

Global timecaps.TIMECAPS


;Procedure H_GetScreenFormat(*D3D.IDirect3D9,bpp,Windowed)
;  Select bpp
;    Case 32
;      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_X8R8G8B8,#D3DFMT_X8R8G8B8,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_X8R8G8B8:EndIf
;      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_A8R8G8B8,#D3DFMT_A8R8G8B8,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_A8R8G8B8:EndIf
;      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_A2R10G10B10,#D3DFMT_A2R10G10B10,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_A2R10G10B10:EndIf
;    Case 16
;      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_R5G6B5,#D3DFMT_R5G6B5,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_R5G6B5:EndIf
;      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_X1R5G5B5,#D3DFMT_X1R5G5B5,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_X1R5G5B5:EndIf
;      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_A1R5G5B5,#D3DFMT_A1R5G5B5,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_A1R5G5B5:EndIf
;  EndSelect
;  ProcedureReturn 0
;EndProcedure

;Only 2DDrawing compatible formats
Procedure H_GetScreenFormat(*D3D.IDirect3D9,bpp,Windowed) 
  Select bpp
    Case 32
      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_X8R8G8B8,#D3DFMT_X8R8G8B8,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_X8R8G8B8:EndIf
    Case 16
      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_R5G6B5,#D3DFMT_R5G6B5,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_R5G6B5:EndIf
      If *D3D\CheckDeviceType(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,#D3DFMT_X1R5G5B5,#D3DFMT_X1R5G5B5,Windowed)=#D3D_OK:ProcedureReturn #D3DFMT_X1R5G5B5:EndIf
  EndSelect
  ProcedureReturn 0
EndProcedure

Procedure H_DepthStencil(*D3D.IDirect3D9,Format,StencilBuffer) 
  If StencilBuffer
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D15S1)=#D3D_OK:DepthStencil=#D3DFMT_D15S1:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D24X4S4)=#D3D_OK:DepthStencil=#D3DFMT_D24X4S4:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D24S8)=#D3D_OK:DepthStencil=#D3DFMT_D24S8:EndIf
  Else
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D16_LOCKABLE)=#D3D_OK:DepthStencil=#D3DFMT_D16_LOCKABLE:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D15S1)=#D3D_OK:DepthStencil=#D3DFMT_D15S1:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D32)=#D3D_OK:DepthStencil=#D3DFMT_D32:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D24X4S4)=#D3D_OK:DepthStencil=#D3DFMT_D24X4S4:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D24S8)=#D3D_OK:DepthStencil=#D3DFMT_D24S8:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D24X8)=#D3D_OK:DepthStencil=#D3DFMT_D24X8:EndIf
    If *D3D\CheckDepthStencilMatch(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,Format,Format,#D3DFMT_D16)=#D3D_OK:DepthStencil=#D3DFMT_D16:EndIf ; prefer 16Bit Z-Buffer (for compartibility reason (X1R5G5B5 RT-Surfaces))
  EndIf
  
  ProcedureReturn DepthStencil
EndProcedure

Procedure H_Fill_D3DPRESENT_PARAMETERS(*d3dpp.D3DPRESENT_PARAMETERS,*D3D.IDirect3D9,hWnd,Width,Height,Windowed,bpp,Flags)
  ScreenInfo.D3DDISPLAYMODE
  
  If Width=<0 Or Height=<0 Or IsWindow_(hWnd)=0 Or *D3D=0:ProcedureReturn #E_FAIL:EndIf
  *d3dpp\BackBufferWidth=Width
  *d3dpp\BackBufferHeight=Height
  *d3dpp\hDeviceWindow=hWnd
  *d3dpp\BackBufferFormat=H_GetScreenFormat(*D3D,bpp,Windowed)
  
  If Windowed
    If *D3D\GetAdapterDisplayMode(#D3DADAPTER_DEFAULT,ScreenInfo):ProcedureReturn #E_FAIL:EndIf
    *d3dpp\BackBufferFormat=ScreenInfo\Format
  EndIf
  
  *d3dpp\Windowed=Windowed
  *d3dpp\BackBufferCount=1
  If Flags&#H_DEVICE_TRIPLEBUFFERING:*d3dpp\BackBufferCount=2:EndIf
  If Flags&#H_DEVICE_QUADRUPLEBUFFERING:*d3dpp\BackBufferCount=3:EndIf
  
  *d3dpp\SwapEffect=#D3DSWAPEFFECT_FLIP
  If Windowed
    *d3dpp\BackBufferCount=1
    *d3dpp\SwapEffect=#D3DSWAPEFFECT_COPY
  EndIf
  
  *d3dpp\PresentationInterval=#D3DPRESENT_INTERVAL_ONE
  If Flags&#H_DEVICE_DISABLEVSYNC
    *d3dpp\PresentationInterval=#D3DPRESENT_INTERVAL_IMMEDIATE
  EndIf
  
  *d3dpp\hDeviceWindow=hWnd
  If Flags&#H_DEVICE_ZBUFFER Or Flags&#H_DEVICE_STENCILBUFFER
    *d3dpp\EnableAutoDepthStencil=-1
    *d3dpp\AutoDepthStencilFormat=H_DepthStencil(*D3D,*d3dpp\BackBufferFormat,Flags&#H_DEVICE_STENCILBUFFER)
    If *d3dpp\AutoDepthStencilFormat=0:ProcedureReturn #E_FAIL:EndIf
  Else
    *d3dpp\EnableAutoDepthStencil=0
    *d3dpp\AutoDepthStencilFormat=0
  EndIf
  
  If Flags&#H_DEVICE_LOCKABLE:*d3dpp\Flags=#D3DPRESENTFLAG_LOCKABLE_BACKBUFFER:EndIf
  
  ProcedureReturn 0
EndProcedure

Procedure H_D3DFormatToBPP(Format) ;returns the bpp of the pixelformat
  Select Format
    Case #D3DFMT_A16B16G16R16
      ProcedureReturn 64
    Case #D3DFMT_X8R8G8B8
      ProcedureReturn 32
    Case #D3DFMT_A8R8G8B8
      ProcedureReturn 32
    Case #D3DFMT_A2R10G10B10
      ProcedureReturn 32
    Case #D3DFMT_A2B10G10R10
      ProcedureReturn 32
    Case #D3DFMT_G16R16
      ProcedureReturn 32
    Case #D3DFMT_R8G8B8
      ProcedureReturn 24
    Case #D3DFMT_R5G6B5
      ProcedureReturn 16
    Case #D3DFMT_X1R5G5B5
      ProcedureReturn 16
    Case #D3DFMT_A1R5G5B5
      ProcedureReturn 16
    Case #D3DFMT_A4R4G4B4
      ProcedureReturn 16
    Case #D3DFMT_A8R3G3B2
      ProcedureReturn 16
    Case #D3DFMT_X4R4G4B4
      ProcedureReturn 16
    Case #D3DFMT_A4R4G4B4
      ProcedureReturn 16
    Case #D3DFMT_R3G3B2
      ProcedureReturn 8
    Case #D3DFMT_A8
      ProcedureReturn 8
  EndSelect
EndProcedure


Procedure H_GetTimer()
  Select _H_Timer_Init
    Case 1
      QueryPerformanceCounter_(@Counter.q)
      ProcedureReturn (Counter-_H_Timer_Start)/_H_Timer_Freq
    Case 2
    
    ;timeBeginPeriod_(timecaps\wPeriodMin)
    Result=timeGetTime_()-_H_Timer_Start
    ;timeEndPeriod_(timecaps\wPeriodMin)
    
      ProcedureReturn Result
  EndSelect
  ;Init timer
  Result=QueryPerformanceFrequency_(@_H_Timer_Freq)
  _H_Timer_Freq/1000
  If Result
    _H_Timer_Init=1
    QueryPerformanceCounter_(@_H_Timer_Start)
  Else
  ;timeBeginPeriod_(timecaps\wPeriodMin)
    _H_Timer_Start=timeGetTime_()
    ;timeEndPeriod_(timecaps\wPeriodMin)
    _H_Timer_Init=2
  EndIf
  ProcedureReturn H_GetTimer()
EndProcedure


Procedure H_IsInVBlank(*D3DDevice.IDirect3DDevice9) ; Make sure that Monitor is in VBlank 
     Result=*D3DDevice\GetRasterStatus(0,d3drs.D3DRASTER_STATUS)
     If d3drs\InVBlank Or Result
     ProcedureReturn #True
     EndIf
EndProcedure


Procedure H_Wait(*D3DDevice.IDirect3DDevice9,RefreshRate,FrameRate,CPUOptimized)

If RefreshRate And FrameRate
TimeToWait=1000/FrameRate
If H_IsInVBlank(*D3DDevice) And (H_GetTimer()- _H_VSync_LastTimeStamp)=>TimeToWait
 _H_VSync_LastTimeStamp=H_GetTimer()
ProcedureReturn #True
EndIf

Repeat
!PAUSE
WaitTime.l=(H_GetTimer()- _H_VSync_LastTimeStamp)
If CPUOptimized And (TimeToWait-WaitTime)=>timecaps\wPeriodMin
Sleep_(1)
EndIf    
Until H_IsInVBlank(*D3DDevice) And WaitTime=>TimeToWait 
_H_VSync_LastTimeStamp=H_GetTimer()
ProcedureReturn #True    
EndIf



If FrameRate
TimeToWait=1000/FrameRate
If (H_GetTimer()- _H_VSync_LastTimeStamp)=>TimeToWait
 _H_VSync_LastTimeStamp=H_GetTimer()
ProcedureReturn #True
EndIf

Repeat
!PAUSE
WaitTime.l=(H_GetTimer()- _H_VSync_LastTimeStamp)
If CPUOptimized And (TimeToWait-WaitTime)=>timecaps\wPeriodMin
Sleep_(1)
EndIf    
Until WaitTime=>TimeToWait 
_H_VSync_LastTimeStamp=H_GetTimer()
ProcedureReturn #True    
EndIf



If RefreshRate
TimeToWait=1000/RefreshRate
If H_IsInVBlank(*D3DDevice)
 _H_VSync_LastTimeStamp=H_GetTimer()
ProcedureReturn #True
EndIf

Repeat
!PAUSE
WaitTime.l=(H_GetTimer()- _H_VSync_LastTimeStamp)
If CPUOptimized And (TimeToWait-WaitTime)=>timecaps\wPeriodMin
Sleep_(1)
EndIf    
Until H_IsInVBlank(*D3DDevice)
_H_VSync_LastTimeStamp=H_GetTimer()
ProcedureReturn #True    
EndIf

ProcedureReturn #True  
EndProcedure



Procedure H_CreateScreenWindow(Width,Height,windowed,Title.s)
  ;register the windowclass
  If _H_ClassRegistered=0
    
    _H_wc\style=#CS_OWNDC|#CS_NOCLOSE ; |#CS_BYTEALIGNWINDOW
    _H_wc\lpfnWndProc=GetProcAddress_(GetModuleHandle_("User32.dll"),"DefWindowProcA") 
    _H_wc\hInstance=GetModuleHandle_(0)
    _H_wc\hIcon=LoadIcon_(0,#IDI_APPLICATION)
    _H_wc\hCursor=LoadCursor_(0,#IDC_ARROW)
    _H_wc\hbrBackground=CreateSolidBrush_(0)
    _H_wc\lpszClassName=@"DXScreenClass" 
    
    If RegisterClass_(_H_wc)=0  ; If the class can't be registered
      DeleteObject_(_H_wc\hbrBackground)
      DestroyIcon_(_H_wc\hIcon)
      DestroyCursor_(_H_wc\hCursor)
      ProcedureReturn 0
    EndIf
    
    _H_ClassRegistered=-1
  EndIf
  
  If windowed=0
    Result=CreateWindowEx_(0,"DXScreenClass",Title,#WS_POPUP,0,0,Width,Height,0,0,GetModuleHandle_(0),0) 
  Else  
    
    X=GetSystemMetrics_(#SM_CXSCREEN)/2-Width/2
    Y=GetSystemMetrics_(#SM_CYSCREEN)/2-Height/2
    Result=CreateWindowEx_(0,"DXScreenClass",Title,#WS_CAPTION,X,Y,Width,Height,0,0,GetModuleHandle_(0),0) 
    
    If Result
      GetWindowRect_(Result,@re.rect)
      GetClientRect_(Result,@cre.rect)
      DestroyWindow_(Result)
      Width+(re\right-re\left)-(cre\right-cre\left)
      Height+(re\Bottom-re\Top)-(cre\Bottom-cre\Top)
      
      X=GetSystemMetrics_(#SM_CXSCREEN)/2-Width/2
      Y=GetSystemMetrics_(#SM_CYSCREEN)/2-Height/2
      Result=CreateWindowEx_(0,"DXScreenClass",Title,#WS_CAPTION,X,Y,Width,Height,0,0,GetModuleHandle_(0),0) 
      
    EndIf
    
  EndIf
  
  If Result
    UpdateWindow_(Result)
    ShowWindow_(Result,#SW_SHOWNORMAL)
    _H_ClassWindowcount+1
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure H_FreeScreenWindow(hWnd)
  If IsWindow_(hWnd)
    DestroyWindow_(hWnd)
    _H_ClassWindowcount-1
  Else
    ProcedureReturn 0
  EndIf
  If _H_ClassRegistered And _H_ClassWindowcount<=0
    UnregisterClass_("DXScreenClass",GetModuleHandle_(0))
    _H_ClassRegistered=0
    DeleteObject_(_H_wc\hbrBackground)
    DestroyIcon_(_H_wc\hIcon)
    DestroyCursor_(_H_wc\hCursor)
  EndIf
  ProcedureReturn -1
EndProcedure


;--------------------------------------------------------------------------------------
; Functions to convert X1R5G5B5 to A1R5G5B5
;--------------------------------------------------------------------------------------

Global *_H_X1RGB15ToA1RGB15Buffer.word
Global _H_TransColor

Procedure H_Init();X1RGB15ToA1RGB15Buffer()
timeGetDevCaps_(timecaps,SizeOf(TIMECAPS))  ;change procname...
timeBeginPeriod_(timecaps\wPeriodMin)

  If *_H_X1RGB15ToA1RGB15Buffer:ProcedureReturn *_H_X1RGB15ToA1RGB15Buffer:EndIf
  *_H_X1RGB15ToA1RGB15Buffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,$FFFF*2)
  If *_H_X1RGB15ToA1RGB15Buffer=0:ProcedureReturn 0:EndIf

  *ptr.word=*_H_X1RGB15ToA1RGB15Buffer
  For c=0 To $FFFF ; -1 is wrong here (?)
  cn=c&%11111+((c>>6)&%11111)<<5+((c>>11)&%11111)<<10
    *ptr\w=cn|(1<<15)
    *ptr+2
  Next
  ;set black as transparent
  *_H_X1RGB15ToA1RGB15Buffer\w=0
  *ptr=*_H_X1RGB15ToA1RGB15Buffer+(1<<15)
  *ptr\w=0
  _H_TransColor=#Black
  ProcedureReturn *_H_X1RGB15ToA1RGB15Buffer
EndProcedure

Procedure H_Free(); X1RGB15ToA1RGB15Buffer()
timeEndPeriod_(timecaps\wPeriodMin)
  If *_H_X1RGB15ToA1RGB15Buffer
    GlobalFree_(*_H_X1RGB15ToA1RGB15Buffer)
    *_H_X1RGB15ToA1RGB15Buffer=0
  EndIf
EndProcedure


Procedure H_SetX1RGB15ToA1RGB15TransColor(TransparentColor)
  TransColor=(TransparentColor>>16)>>3+(((TransparentColor&$FF00)>>8)>>2)<<5+((TransparentColor&$FF)>>3)<<11
  If TransColor<>_H_TransColor

    ;reset old transparent color:
    *ptr.word=*_H_X1RGB15ToA1RGB15Buffer+_H_TransColor*2
    *ptr\w=*ptr\w|(1<<15)
    *ptr.word=*_H_X1RGB15ToA1RGB15Buffer+_H_TransColor|(1<<15)*2
    *ptr\w=*ptr\w|(1<<15)

    ;set new transparent color:
    *ptr.word=*_H_X1RGB15ToA1RGB15Buffer+TransColor*2
    *ptr\w=*ptr\w&($FFFF>>1)
    *ptr.word=*_H_X1RGB15ToA1RGB15Buffer+TransColor|(1<<15)*2
    *ptr\w=*ptr\w&($FFFF>>1)

    _H_TransColor=TransColor
  EndIf
EndProcedure

Procedure H_ConvertX1RGB15ToA1RGB15(*SAddr.word,*DAddr.word,NumPixel)
  !PUSH ESI
  !PUSH EDI
  !PUSH ECX
  !PUSH EDX

  !MOV ESI,[Esp+4+16];[p.p_SAddr+16] ;*SAddr
  !MOV EDI,[Esp+8+16];[p.p_DAddr+16] ;*DAddr
  !MOV ECX,[Esp+12+16];[p.v_NumPixel+16] ;NumPixel
  !MOV EDX,[p__H_X1RGB15ToA1RGB15Buffer]

  !X1RGB15ToA1RGB15ConvertLoop:
  !MOVZX EAX,word[ESI]
  !LEA EAX,[EDX+EAX*2]
  !MOV AX,[EAX]
  !MOV [EDI],AX
  !ADD ESI,2
  !ADD EDI,2

  !DEC ECX
  !JNZ X1RGB15ToA1RGB15ConvertLoop

  !POP EDX
  !POP ECX
  !POP EDI
  !POP ESI
EndProcedure


;old version:
;Procedure H_ConvertX1RGB15ToA1RGB15_Old(*SAddr.word,*DAddr.word,NumPixel)
;TransColor=Blue(TransparentColor)>>3+(Green(TransparentColor)>>3)<<5+(Red(TransparentColor)>>3)<<10
;If TransColor<>_H_TransColor
;
;;reset old transparent color:
;*ptr.word=*_H_X1RGB15ToA1RGB15Buffer+_H_TransColor*2
;*ptr\w=*ptr\w|(1<<15)
;*ptr.word=*_H_X1RGB15ToA1RGB15Buffer+_H_TransColor|(1<<15)*2
;*ptr\w=*ptr\w|(1<<15)
;
;;set new transparent color:
;*ptr.word=*_H_X1RGB15ToA1RGB15Buffer+TransColor*2
;*ptr\w=*ptr\w&($FFFF>>1)
;*ptr.word=*_H_X1RGB15ToA1RGB15Buffer+TransColor|(1<<15)*2
;*ptr\w=*ptr\w&($FFFF>>1)
;
;_H_TransColor=TransColor
;EndIf

;;--> Replace by ASM
;*ptr.word
;For c=0 To NumPixel-1
;*ptr=*_H_X1RGB15ToA1RGB15Buffer+(*SAddr\w&$FFFF)*2
;*DAddr\w=*ptr\w
;*SAddr+2
;*DAddr+2
;Next
;EndProcedure


Procedure H_CompareBytes(*Src1.BYTE,*Src2.BYTE,NumBytes.l)
NumLongs.l=NumBytes>>2
If NumLongs
!PUSH EAX
!PUSH EDX
!PUSH ESI
!PUSH EDI
!PUSH ECX

!MOV ECX,[p.v_NumLongs+4*5]
!INC ECX
!MOV ESI,[p.p_Src1+4*5]
!MOV EDI,[p.p_Src2+4*5]

!H_CompareBytes_loop:
!DEC ECX
!JZ H_CompareBytes_loopEnd

!MOV EAX,[ESI]
!MOV EDX,[EDI]

!ADD ESI,4
!ADD EDI,4
!AND EAX,EDX
!CMP EAX,0

!JE H_CompareBytes_loop

!POP ECX
!POP EDI
!POP ESI
!POP EDX
!POP EAX
ProcedureReturn #True

!H_CompareBytes_loopEnd:
!POP ECX
!POP EDI
!POP ESI
!POP EDX
!POP EAX
EndIf

RestBytes.l=NumBytes%4
If RestBytes
*Src1=*Src1+NumBytes-RestBytes
*Src2=*Src2+NumBytes-RestBytes
For c=0 To RestBytes-1
If *Src1\b And *Src2\b:ProcedureReturn #True:EndIf
*Src1+1
*Src2+1
Next
EndIf
ProcedureReturn #False
EndProcedure

;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------

;Procedure H_LoadD3DXDLL()
;_H_D3DX8Used=0
;If _H_D3DXInst
;FreeLibrary_(_H_D3DXInst)
;_H_D3DXInst=0
;EndIf

;_H_D3DXInst=LoadLibrary_("d3dx9_30.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9_29.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9_28.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9_27.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9_26.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9_25.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9_24.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf

;_H_D3DXInst=LoadLibrary_("d3dx9d_30.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9d_29.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9d_28.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9d_27.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9d_26.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9d_25.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("d3dx9d_24.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;
;_H_D3DXInst=LoadLibrary_("d3dx9d.dll")
;If _H_D3DXInst:ProcedureReturn _H_D3DXInst:EndIf
;_H_D3DXInst=LoadLibrary_("dx8vb.dll") ; DX8 !!!... but it provides at least some math functions (should be always available)
;_H_D3DX8Used=1
;ProcedureReturn _H_D3DXInst
;EndProcedure

;Procedure H_GetD3DXFunc(FuncName.s)
;If _H_D3DX8Used
;ProcedureReturn GetProcAddress_(_H_D3DXInst,"VB_"+FuncName.s)
;Else
;ProcedureReturn GetProcAddress_(_H_D3DXInst,FuncName.s)
;EndIf
;EndProcedure

;Procedure H_FreeD3DXDLL()
;_H_D3DX8Used=0
;If _H_D3DXInst
;FreeLibrary_(_H_D3DXInst)
;_H_D3DXInst=0
;EndIf
;EndProcedure

; IDE Options = PureBasic 4.10 Beta 1 (Windows - x86)
; CursorPosition = 374
; FirstLine = 334
; Folding = ---