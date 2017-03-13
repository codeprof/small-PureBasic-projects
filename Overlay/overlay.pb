;Achtung: 
;Nicht jede Grafikkarte unterstüzt Overlays. 

Import "Kernel32.lib";Hotfix
   GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
 EndImport
 
#DDOVER_SHOW=16384 
#DDSCAPS_OVERLAY=128    
#DDSCAPS_VIDEOMEMORY=16384 
#DDSD_PIXELFORMAT=4096 
#DDSD_CAPS=1 
#DDSD_HEIGHT=2 
#DDSD_WIDTH=4 
#DDPF_RGB=64 
#DDPF_FOURCC=4 
#DDLOCK_WAIT=1 
#DDSCAPS_COMPLEX = 8
#DDSCAPS_FLIP = $10
#DDSD_BACKBUFFERCOUNT = $20
#DDOVER_HIDE = $200
#DDFLIP_WAIT = 1
#DDSCAPS_PRIMARYSURFACE = 512
#DDSCL_NORMAL = 8
#DDSCAPS_BACKBUFFER = $4

Structure DDPIXELFORMAT 
  dwSize.l 
  dwFlags.l 
  dwFourCC.l 
  dwRGBBitCount.l 
  dwRBitMask.l 
  dwGBitMask.l 
  dwBBitMask.l 
  dwRGBAlphaBitMask.l 
EndStructure 

Structure DDCOLORKEY 
  dwColorSpaceLowValue.l 
  dwColorSpaceHighValue.l 
EndStructure 

Structure DDSCAPS2 
  dwCaps.l 
  dwCaps2.l 
  dwCaps3.l 
  dwCaps4.l 
EndStructure 

Structure DDSURFACEDESC2 
  dwSize.l 
  dwFlags.l 
  dwHeight.l 
  dwWidth.l 
  lPitch.l 
  dwBackBufferCount.l 
  dwRefreshRate.l 
  dwAlphaBitDepth.l 
  dwReserved.l 
  lpSurface.l 
  ddckCKDestOverlay.DDCOLORKEY 
  ddckCKDestBlt.DDCOLORKEY 
  ddckCKSrcOverlay.DDCOLORKEY 
  ddckCKSrcBlt.DDCOLORKEY 
  ddpfPixelFormat.DDPIXELFORMAT 
  ddsCaps.DDSCAPS2 
  dwTextureStage.l 
EndStructure 

Enumeration
#OVERLAY_FORMAT_32ARGB
#OVERLAY_FORMAT_16RGB
#OVERLAY_FORMAT_15RGB
#OVERLAY_FORMAT_UYVY
#OVERLAY_FORMAT_YUY2
EndEnumeration

Enumeration
#OVERLAY_FORCEHARDWARE = 1
#OVERLAY_FORCESOFTWARE = 2
#OVERLAY_SOFTWARE_IF_AERO = 4
#OVERLAY_DISABLE_PRINT_KEY = 8
EndEnumeration

#DWM_EC_DISABLECOMPOSITION = 0
#DWM_EC_ENABLECOMPOSITION = 1

#AC_SRC_ALPHA = 1
#ULW_COLORKEY =1
#ULW_ALPHA =2
#ULW_OPAQUE =4

Prototype.i __DwmIsCompositionEnabled(*ptrEnabled)
Prototype.i __DwmEnableComposition(enable.i)  
Prototype.i __UpdateLayeredWindow(p1.i,p2.i,p3.i,p4.i,p5.i,p6.i,p7.i,p8.i,p9.i)

Structure GLOBAL_OVERLAY
bInit.i
UpdateLayeredWindow.__UpdateLayeredWindow
*UserLibrary
bDWMEnabled.i
bDWMWasDisabled.i
bUseAlwaysSoftware.i
iFlags.i
Primary.IDirectDrawSurface7
EndStructure

Structure OVERLAY
bEmulated.i
iWindow.i
bComplexSurface.i
iWidth.i
iHeight.i
SysMemImage.i
OverlayDDS.IDirectDrawSurface7
iFormat.i
bShow.i
iShowX.i
iShowY.i
iShowWidth.i
iShowHeight.i
reClip.rect
EndStructure

Global g_OVERLAY.GLOBAL_OVERLAY

Procedure __GetDDrawBase() 
  !extrn _PB_DDrawBase 
  !MOV Eax,[_PB_DDrawBase] 
  ProcedureReturn 
EndProcedure 

Procedure __IsDWMEnabled()
  bDWMEnabled.i = #False
  DWMLibrary.i = LoadLibrary_("dwmapi.dll")
  If DWMLibrary
    DwmIsCompositionEnabled.__DwmIsCompositionEnabled = GetProcAddress_(DWMLibrary, "DwmIsCompositionEnabled")
    If DwmIsCompositionEnabled
      DwmIsCompositionEnabled(@bDWMEnabled)
    EndIf
    FreeLibrary_(DWMLibrary)
  EndIf
  ProcedureReturn bDWMEnabled
EndProcedure

Procedure __EnableDWM(enable.i)
  iResult.i = #E_FAIL
  DWMLibrary.i = LoadLibrary_("dwmapi.dll")
  If DWMLibrary
    DwmEnableComposition.__DwmEnableComposition = GetProcAddress_(DWMLibrary, "DwmEnableComposition")
    If DwmEnableComposition
      iResult = DwmEnableComposition(enable)
    EndIf
    FreeLibrary_(DWMLibrary)
  EndIf
  ProcedureReturn iResult
EndProcedure


Procedure __DisablePrintHotkeys()
  RegisterHotKey_(0, #IDHOT_SNAPDESKTOP, 0, #VK_SNAPSHOT)
  RegisterHotKey_(0, #IDHOT_SNAPWINDOW, #MOD_ALT, #VK_SNAPSHOT)
  RegisterHotKey_(0, $B000, #MOD_CONTROL, #VK_SNAPSHOT)
EndProcedure

Procedure __EnablePrintHotkeys()
  UnregisterHotKey_( 0, #IDHOT_SNAPDESKTOP)
  UnregisterHotKey_( 0, #IDHOT_SNAPWINDOW)
  UnregisterHotKey_( 0, $B000)
EndProcedure

Procedure __CreateSWOverlay(Width.i, Height.i, *Overlay.OVERLAY)
If *Overlay And g_OVERLAY\UpdateLayeredWindow
  *Overlay\bEmulated = #True
  *Overlay\iFormat = #OVERLAY_FORMAT_32ARGB
  *Overlay\iWindow = OpenWindow(#PB_Any,0,0,Width,Height,"",#PB_Window_ScreenCentered|#PB_Window_BorderLess|#PB_Window_Invisible) 
  If *Overlay\iWindow
    hWnd.i = WindowID(*Overlay\iWindow)
    SetWindowPos_(hWnd, #HWND_TOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE)
    SetWindowLong_(hWnd, #GWL_EXSTYLE, GetWindowLong_(hWnd, #GWL_EXSTYLE) | #WS_EX_LAYERED | #WS_EX_TRANSPARENT | #WS_EX_TOOLWINDOW)     
    ProcedureReturn #S_OK
  EndIf
EndIf
ProcedureReturn #E_FAIL
EndProcedure


Procedure __CreateHWOverlay(bComplex.i, Width.i, Height.i, *Overlay.OVERLAY)
  Result.i = #E_FAIL

  DD.IDirectDraw7 = __GetDDrawBase()
  If DD
    *Overlay\bEmulated = #False
    *Overlay\bComplexSurface = bComplex 
    ddsd.DDSURFACEDESC2 
    ddsd\dwSize = SizeOf(DDSURFACEDESC2) 
    
    If bComplex
      ddsd\ddsCaps\dwCaps = #DDSCAPS_OVERLAY | #DDSCAPS_VIDEOMEMORY | #DDSCAPS_COMPLEX | #DDSCAPS_FLIP
      ddsd\dwFlags = #DDSD_CAPS | #DDSD_HEIGHT | #DDSD_WIDTH | #DDSD_PIXELFORMAT | #DDSD_BACKBUFFERCOUNT
      ddsd\dwBackBufferCount = 1
    Else
      ddsd\ddsCaps\dwCaps = #DDSCAPS_OVERLAY | #DDSCAPS_VIDEOMEMORY
      ddsd\dwFlags = #DDSD_CAPS | #DDSD_HEIGHT | #DDSD_WIDTH | #DDSD_PIXELFORMAT
    EndIf
    
    ddsd\dwWidth = Width 
    ddsd\dwHeight = Height 
  
    ddsd\ddpfPixelFormat\dwSize = SizeOf(DDPIXELFORMAT) 
    ddsd\ddpfPixelFormat\dwFlags = #DDPF_RGB 
    ddsd\ddpfPixelFormat\dwRGBBitCount = 32 
    ddsd\ddpfPixelFormat\dwRBitMask = $FF0000 
    ddsd\ddpfPixelFormat\dwGBitMask = $00FF00 
    ddsd\ddpfPixelFormat\dwBBitMask = $0000FF
    *Overlay\iFormat = #OVERLAY_FORMAT_32ARGB
    Result = DD\CreateSurface(ddsd, @*Overlay\OverlayDDS,0)   
    
    ;If Result
    ;  ddsd\ddpfPixelFormat\dwRBitMask = $0000FF 
    ;  ddsd\ddpfPixelFormat\dwGBitMask = $00FF00 
    ;  ddsd\ddpfPixelFormat\dwBBitMask = $FF0000
    ;  *Overlay\iFormat = #OVERLAY_FORMAT_32ARGB
    ;  Result = DD\CreateSurface(ddsd, @*Overlay\OverlayDDS,0)  
    ;  Debug Result 
    ;EndIf
    
    If Result 
      ddsd\ddpfPixelFormat\dwRGBBitCount = 0 
      ddsd\ddpfPixelFormat\dwRBitMask = 0 
      ddsd\ddpfPixelFormat\dwGBitMask = 0 
      ddsd\ddpfPixelFormat\dwBBitMask = 0 
      ddsd\ddpfPixelFormat\dwFlags = #DDPF_FOURCC 
      ddsd\ddpfPixelFormat\dwFourCC = PeekL(@"UYVY") 
      *Overlay\iFormat = #OVERLAY_FORMAT_UYVY
      Result = DD\CreateSurface(ddsd, @*Overlay\OverlayDDS, 0)      
    EndIf 
    
    If Result 
      *Overlay\iFormat = #OVERLAY_FORMAT_YUY2    
      ddsd\ddpfPixelFormat\dwFourCC = PeekL(@"YUY2") 
      Result = DD\CreateSurface(ddsd, @*Overlay\OverlayDDS, 0) 
    EndIf 
  
    If Result 
      ddsd\ddpfPixelFormat\dwSize = SizeOf(DDPIXELFORMAT)  
      ddsd\ddpfPixelFormat\dwFlags = #DDPF_RGB 
      ddsd\ddpfPixelFormat\dwRGBBitCount = 16 
      ddsd\ddpfPixelFormat\dwRBitMask = $F800 
      ddsd\ddpfPixelFormat\dwGBitMask = $07E0 
      ddsd\ddpfPixelFormat\dwBBitMask = $001F 
      *Overlay\iFormat = #OVERLAY_FORMAT_16RGB
      Result = DD\CreateSurface(ddsd, @*Overlay\OverlayDDS, 0) 
    EndIf
    
    If Result 
      ddsd\ddpfPixelFormat\dwRBitMask = $7C00 
      ddsd\ddpfPixelFormat\dwGBitMask = $03E0 
      ddsd\ddpfPixelFormat\dwBBitMask = $001F 
      *Overlay\iFormat = #OVERLAY_FORMAT_15RGB
      Result = DD\CreateSurface(ddsd, @*Overlay\OverlayDDS, 0) 
    EndIf 
  EndIf
ProcedureReturn Result
EndProcedure


Procedure.i __UpdateSWOverlay(*Overlay.OVERLAY)
  iResult = #False
  memDC.i = CreateCompatibleDC_(0) 
  If memDC
    
    oldObj.i = SelectObject_(memDC, ImageID(*Overlay\SysMemImage))
    sz.SIZE 
    sz\cx = *Overlay\reClip\right - *Overlay\reClip\left
    sz\cy = *Overlay\reClip\bottom - *Overlay\reClip\top 
    offset.POINT 
    offset\x = *Overlay\reClip\left
    offset\y = *Overlay\reClip\top
        
    blendMode.BLENDFUNCTION 
    blendMode\SourceConstantAlpha = 255
    blendMode\AlphaFormat = #AC_SRC_ALPHA
    blendMode\BlendFlags = 0
    ResizeWindow(*Overlay\iWindow, #PB_Ignore, #PB_Ignore, sz\cx, sz\cy)
    iResult.i = g_OVERLAY\UpdateLayeredWindow(WindowID(*Overlay\iWindow), 0, 0, @sz, memDC, @offset, 0, @blendMode, #ULW_OPAQUE) 

    SelectObject_(memDC,oldObj)
    DeleteDC_(memDC)
  EndIf
  ProcedureReturn iResult
EndProcedure


Procedure __UpdateHWOverlay(*Overlay.OVERLAY)
ddsd.DDSURFACEDESC2
ddsd\dwSize = SizeOf(DDSURFACEDESC2) 
If GetObject_(ImageID(*Overlay\SysMemImage),SizeOf(DIBSECTION),ds.DIBSECTION)
  If ds\dsBm\bmBits
    Format.i = *Overlay\iFormat 
    Width.i = ImageWidth(*Overlay\SysMemImage)
    Height.i = ImageHeight(*Overlay\SysMemImage)
    
    DDS.IdirectDrawSurface7 = #Null
   
    If *Overlay\OverlayDDS
      If *Overlay\bComplexSurface
        ddscaps.DDSCAPS2
        ddscaps\dwCaps = #DDSCAPS_BACKBUFFER
        *Overlay\OverlayDDS\GetAttachedSurface(ddscaps, @DDS)
      Else
        DDS = *Overlay\OverlayDDS
        DDS\AddRef()
      EndIf 
       
    EndIf
    
    If DDS
      If DDS\Lock(0,ddsd,#DDLOCK_WAIT,0) = #S_OK
        Addr.i = ddsd\lpSurface 
        Pitch.i = ddsd\lPitch 
        
        For y=0 To Height-1 
          *src.LONG = ds\dsBm\bmBits + ds\dsBm\bmWidthBytes * ((ds\dsBm\bmHeight - 1) - y)
          For x=0 To Width-1 Step 2 
            
            C1 = *src\l
  
            *src + SizeOf(LONG)
            C2 = *src\l
            *src + SizeOf(LONG)
            
            If Format = #OVERLAY_FORMAT_UYVY Or Format = #OVERLAY_FORMAT_YUY2
            Y0=     ( Blue(C1)*29 +Green(C1)*57 +Red(C1)*14)/100 
            U0=128 +(-Blue(C1)*14 -Green(C1)*29 +Red(C1)*43)/100 
            V0=128 +( Blue(C1)*36 -Green(C1)*29 -Red(C1)*07)/100 
            
            Y1=     ( Blue(C2)*29 +Green(C2)*57 +Red(C2)*14)/100 
            U1=128 +(-Blue(C2)*14 -Green(C2)*29 +Red(C2)*43)/100 
            V1=128 +( Blue(C2)*36 -Green(C2)*29 -Red(C2)*07)/100 
            
            Else
              If Format <> #OVERLAY_FORMAT_32ARGB
                B1 = C1 & 255 
                B2 = C2 & 255
                G1 = (C1 >> 8) & 255
                G2 = (C2 >> 8) & 255
                R1 = (C1 >> 16) & 255
                R2 = (C2 >> 16) & 255      
              EndIf       
            EndIf
                   
            Select Format 
              Case #OVERLAY_FORMAT_UYVY
                PokeL(Addr, Y1<<24 + ((V0 + V1)/2)<<16 + Y0<<8 + (U0 + U1)/2):Addr + SizeOf(LONG)
              Case #OVERLAY_FORMAT_YUY2
                PokeL(Addr, ((V0 + V1)/2)<<24 + Y1<<16 + ((U0 + U1)/2)<<8 + Y0):Addr + SizeOf(LONG)         
              Case #OVERLAY_FORMAT_15RGB
                Val.l = (B2 >> 3) + (G2 >> 3) << 5 +  (R2 >> 3) << 10 
                Val.l << 16
                Val.l + (B1 >> 3) + (G1 >> 3) << 5 +  (R1 >> 3) << 10 
                PokeL(Addr, Val):Addr + SizeOf(LONG)
              Case #OVERLAY_FORMAT_16RGB
                Val.l = (B2 >> 3) + (G2 >> 2) << 5 +  (R2 >> 3) << 11 
                Val.l << 16
                Val.l + (B1 >> 3) + (G1 >> 2) << 5 +  (R1 >> 3) << 11 
                PokeL(Addr, Val):Addr + SizeOf(LONG)           
              Case #OVERLAY_FORMAT_32ARGB
                PokeL(Addr, C1):Addr + SizeOf(LONG)
                PokeL(Addr, C2):Addr + SizeOf(LONG)                                             
            EndSelect 
            
          Next 
          
          If Format = #OVERLAY_FORMAT_32ARGB
            Addr + (Pitch - Width * 4)
          Else
            Addr + (Pitch - Width * 2)
          EndIf 
        Next 
        
        DDS\UnLock(0) 
        DDS\Release()
        ProcedureReturn #True
      EndIf
    EndIf
  EndIf
EndIf
ProcedureReturn #False
EndProcedure

Procedure.i __RestoreHWOverlay(*Overlay.OVERLAY)
  If g_OVERLAY\Primary
    If g_OVERLAY\Primary\IsLost()
      If g_OVERLAY\Primary\Restore() <> #S_OK
        ProcedureReturn #False
      EndIf
    EndIf
  Else
    ProcedureReturn #False
  EndIf
  If *Overlay\OverlayDDS
    If *Overlay\OverlayDDS\IsLost()
      If *Overlay\OverlayDDS\Restore() = #S_OK
        ProcedureReturn __UpdateHWOverlay(*Overlay)
      Else
        ProcedureReturn #False
      EndIf
    EndIf
  Else
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure


ProcedureDLL.i OVERLAY_InitContext(iFlags.i)

If g_OVERLAY\bInit = #False
  g_OVERLAY\bInit = #True
  g_OVERLAY\iFlags = iFlags
  g_OVERLAY\UserLibrary = LoadLibrary_("user32.dll")
  g_OVERLAY\UpdateLayeredWindow = GetProcAddress_(g_OVERLAY\UserLibrary, "UpdateLayeredWindow")

  g_OVERLAY\bDWMEnabled = __IsDWMEnabled()
  g_OVERLAY\bDWMWasDisabled = #False
  g_OVERLAY\bUseAlwaysSoftware = #False 
  
  If g_OVERLAY\iFlags & #OVERLAY_FORCESOFTWARE
    g_OVERLAY\bUseAlwaysSoftware = #True
  EndIf
  If g_OVERLAY\iFlags & #OVERLAY_SOFTWARE_IF_AERO And g_OVERLAY\bDWMEnabled
    g_OVERLAY\bUseAlwaysSoftware = #True
  EndIf  
  


  If g_OVERLAY\iFlags & #OVERLAY_DISABLE_PRINT_KEY
    __DisablePrintHotkeys()
  EndIf

  If g_OVERLAY\bUseAlwaysSoftware = #False
    ; We need to create a primary surface
    g_OVERLAY\bUseAlwaysSoftware = #True ; only support hardware if no error happens
    If InitSprite() 
     
      DD.IDirectDraw7 = __GetDDrawBase()
      If DD
        If DD\SetCooperativeLevel(#Null, #DDSCL_NORMAL) = #S_OK
        
          bOk.i = #True
          If g_OVERLAY\bDWMEnabled
            If __EnableDWM(#DWM_EC_DISABLECOMPOSITION) = #S_OK
              g_OVERLAY\bDWMWasDisabled = #True
            Else
              ;In this case the hardware overlay would not be visible
              bOk = #False
            EndIf
          EndIf
        
          If bOk
            DESC.DDSURFACEDESC2
            DESC\dwSize = SizeOf(DDSURFACEDESC2)
            DESC\dwFlags =  #DDSD_CAPS
            DESC\ddsCaps\dwCaps = #DDSCAPS_PRIMARYSURFACE
            DD\CreateSurface(DESC,@g_OVERLAY\Primary,0)
            
            If g_OVERLAY\Primary
              g_OVERLAY\bUseAlwaysSoftware = #False         
            EndIf
            
          EndIf
          
        EndIf
      EndIf
    EndIf  
    
  EndIf
  
  
EndIf

EndProcedure

ProcedureDLL.i OVERLAY_FreeContext()
  g_OVERLAY\bInit = #False
  If g_OVERLAY\UserLibrary
    FreeLibrary_(g_OVERLAY\UserLibrary)
    g_OVERLAY\UserLibrary = #Null
  EndIf

  If g_OVERLAY\iFlags & #OVERLAY_DISABLE_PRINT_KEY
    __EnablePrintHotkeys()
  EndIf

  If g_OVERLAY\Primary
    g_OVERLAY\Primary\Release()
    g_OVERLAY\Primary = #Null        
  EndIf
 
  If g_OVERLAY\bDWMWasDisabled
    __EnableDWM(#DWM_EC_ENABLECOMPOSITION)
  EndIf
EndProcedure



ProcedureDLL.i OVERLAY_Create(Width.i, Height.i) 
  If g_OVERLAY\bInit = #False:ProcedureReturn #False:EndIf
  If Width < 2 Or Height < 1: ProcedureReturn #False:EndIf
  If Width % 2:Width - 1:EndIf

  *Overlay.OVERLAY = AllocateMemory(SizeOf(OVERLAY))
  If *Overlay
    *Overlay\SysMemImage = CreateImage(#PB_Any, Width, Height, 32)
    If *Overlay\SysMemImage
      
      Result.i = #E_FAIL
      If g_OVERLAY\bUseAlwaysSoftware = #False
        Result.i = __CreateHWOverlay(#True, Width, Height, *Overlay)
        If Result
          Result.i = __CreateHWOverlay(#False, Width, Height, *Overlay)        
        EndIf
      EndIf

      If g_OVERLAY\iFlags & #OVERLAY_FORCEHARDWARE = 0 And Result <> #S_OK
        Result.i = __CreateSWOverlay(Width, Height, *Overlay)      
      EndIf 
      
      If Result = #S_OK
        *Overlay\iWidth = Width
        *Overlay\iHeight = Height
        *Overlay\bShow = #False
        *Overlay\reClip\top = 0
        *Overlay\reClip\left = 0
        *Overlay\reClip\right = Width
        *Overlay\reClip\bottom = Height      
        ProcedureReturn *Overlay                         
      EndIf

      FreeImage(*Overlay\SysMemImage)
    EndIf
    FreeMemory(*Overlay)
  EndIf
  
  
  ProcedureReturn #Null
EndProcedure 



ProcedureDLL.i OVERLAY_Hide(*Overlay.OVERLAY)
  If *Overlay
    *Overlay\bShow = #False
    
    If *Overlay\bEmulated
      ProcedureReturn HideWindow(*Overlay\iWindow, #True)
    Else
    
    If __RestoreHWOverlay(*Overlay)  
      *Overlay\OverlayDDS\GetDDInterface(@*DD.IDirectDraw7) 
      If *DD
        *DD\GetGDISurface(@*GDI.IDirectDrawSurface7) 
        If *GDI 
          If *Overlay\OverlayDDS\UpdateOverlay(#Null, *GDI, #Null, #DDOVER_HIDE, 0) = #S_OK
            ProcedureReturn #True
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndIf
  
  EndIf
  ProcedureReturn #False
EndProcedure

;It is not recommended to use this function because scaling is not supported by emulated overlays.
;Also hardware overlays support scalation only to a certain (hardware dependent) factor.
ProcedureDLL.i OVERLAY_HWShow(*Overlay.OVERLAY, x.i, y.i, iWidth.i, iHeight.i) 
  If *Overlay
    *Overlay\bShow = #True
    *Overlay\iShowX = x
    *Overlay\iShowY = y
    *Overlay\iShowWidth = iWidth
    *Overlay\iShowHeight = iHeight
  
    If *Overlay\bEmulated    

      HideWindow(*Overlay\iWindow, #False)
      ResizeWindow(*Overlay\iWindow, x, y, iWidth, iHeight)
      SetWindowPos_(WindowID(*Overlay\iWindow), #HWND_TOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE)
      ProcedureReturn #True
      
    Else    
      dst.RECT 
      dst\left = x 
      dst\right = x + iWidth 
      dst\top = y 
      dst\bottom = y + iHeight 
      
      If __RestoreHWOverlay(*Overlay) 
      
        If *Overlay\OverlayDDS
          *Overlay\OverlayDDS\GetDDInterface(@*DD.IDirectDraw7) 
          If *DD
      
            *DD\GetGDISurface(@*GDI.IDirectDrawSurface7) 
            If *GDI 
              If *Overlay\OverlayDDS\UpdateOverlay(*Overlay\reClip, *GDI, dst, #DDOVER_SHOW, 0) = #S_OK
                ProcedureReturn #True
              EndIf
            EndIf
          EndIf
        EndIf
   
      EndIf
    
    EndIf
    
  EndIf
  ProcedureReturn #False
EndProcedure 

ProcedureDLL.i OVERLAY_Show(*Overlay.OVERLAY, x.i, y.i) 
  ProcedureReturn OVERLAY_HWShow(*Overlay, x, y, *Overlay\reClip\right - *Overlay\reClip\left, *Overlay\reClip\bottom - *Overlay\reClip\top)
EndProcedure 

ProcedureDLL.i OVERLAY_Free(*Overlay.OVERLAY) 
If *Overlay
  
  If *Overlay\iWindow
    CloseWindow(*Overlay\iWindow)
  EndIf
  
  If *Overlay\OverlayDDS
    *Overlay\OverlayDDS\Release()
  EndIf
  If *Overlay\SysMemImage
    FreeImage(*Overlay\SysMemImage)
  EndIf
  FreeMemory(*Overlay)
EndIf
EndProcedure 

ProcedureDLL.i OVERLAY_Output(*Overlay.OVERLAY)
  If *Overlay
    ProcedureReturn ImageOutput(*Overlay\SysMemImage)
  EndIf
  ProcedureReturn #Null
EndProcedure

ProcedureDLL.i OVERLAY_IsEmulated(*Overlay.OVERLAY)
  If *Overlay
    ProcedureReturn *Overlay\bEmulated
  EndIf
  ProcedureReturn #False
EndProcedure


ProcedureDLL.i OVERLAY_SetClipRect(*Overlay.OVERLAY, x.i, y.i, iWidth.i, iHeight.i)
  If *Overlay
    *Overlay\reClip\left = x
    If *Overlay\reClip\left < 0 :*Overlay\reClip\left = 0:EndIf
    If *Overlay\reClip\left > *Overlay\iWidth :*Overlay\reClip\left = *Overlay\iWidth:EndIf
    
    *Overlay\reClip\top = y
    If *Overlay\reClip\top < 0 :*Overlay\reClip\top = 0:EndIf
    If *Overlay\reClip\top > *Overlay\iHeight :*Overlay\reClip\top = *Overlay\iHeight:EndIf 

    *Overlay\reClip\right = x +iWidth
    If *Overlay\reClip\right < 0 :*Overlay\reClip\right = 0:EndIf
    If *Overlay\reClip\right > *Overlay\iWidth :*Overlay\reClip\right = *Overlay\iWidth:EndIf
    
    *Overlay\reClip\bottom = y + iHeight
    If *Overlay\reClip\bottom < 0 :*Overlay\reClip\bottom = 0:EndIf
    If *Overlay\reClip\bottom > *Overlay\iHeight :*Overlay\reClip\bottom = *Overlay\iHeight:EndIf   
    ProcedureReturn #True      
  EndIf
  ProcedureReturn #False
EndProcedure

ProcedureDLL.i OVERLAY_Update(*Overlay.OVERLAY)
  If *Overlay
  
    If *Overlay\bEmulated  
      If __UpdateSWOverlay(*Overlay)
        ProcedureReturn #True
      EndIf
      
    Else
    
      If __RestoreHWOverlay(*Overlay) 
        If __UpdateHWOverlay(*Overlay)
               
          If *Overlay\bComplexSurface
            If *Overlay\OverlayDDS\Flip(#Null, #DDFLIP_WAIT) = #S_OK
              ProcedureReturn #True
            EndIf
                  
          Else
            If *Overlay\bShow
              If OVERLAY_Hide(*Overlay)
                ProcedureReturn OVERLAY_HWShow(*Overlay, *Overlay\iShowX, *Overlay\iShowY, *Overlay\iShowWidth, *Overlay\iShowHeight) 
              EndIf
            Else
              ProcedureReturn #True
            EndIf
            
          EndIf  
        EndIf   
      EndIf
    EndIf
            
  EndIf
  ProcedureReturn #False
EndProcedure




OVERLAY_InitContext(#OVERLAY_FORMAT_32ARGB)

*ss.OVERLAY=OVERLAY_Create(100,50)
OVERLAY_SetClipRect(*ss,5,5,50,20)

*ss2.OVERLAY=OVERLAY_Create(100,50)
Debug OVERLAY_IsEmulated(*ss)
Debug OVERLAY_IsEmulated(*ss2)

StartDrawing(OVERLAY_Output(*ss))
For t=0 To 100
Plot(Random(100-1),Random(50-1),Random($FFFFFF))
Next
Box(5,5,10,10,#Red)
StopDrawing()
OVERLAY_Update(*ss)


StartDrawing(OVERLAY_Output(*ss2))
For t=0 To 100
Plot(Random(100-1),Random(50-1),Random($FFFFFF))
Next
Box(5,5,10,10,#Red)
StopDrawing()
OVERLAY_Update(*ss2)

Repeat 

   OVERLAY_Show(*ss,50,200)
   OVERLAY_Show(*ss2,20,20)
Until WaitWindowEvent(16)=#PB_Event_CloseWindow 
