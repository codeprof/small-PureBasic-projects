EnableExplicit



Enumeration
  #PROTECTION_ERR_OK
  #PROTECTION_ERR_NOLAYEREDWINDOW
  ;#PROTECTION_ERR_CANTCREATETEMPFILE
  ;#PROTECTION_ERR_CANTLOADTEMPFILE
  ;#PROTECTION_ERR_CANTINSTALLHOOK
  #PROTECTION_ERR_NOVALIDWINDOWHANDLE
  #PROTECTION_ERR_INITIALIZATIONFALIED
  #PROTECTION_ERR_ALREADYPROTECTED
  #PROTECTION_ERR_INVALIDPARAMETER
EndEnumeration


#PROTECT_DISABLEPRINTHOTKEYS = 1
;It is highly recommended to use this flag. However this completly deactivates the printscreen hotkeys.

#PROTECT_FORCELAYEREDWINDOW = 2
;Turns the window handle in a layered window 

#PROTECT_ENABLECONTENTPROTECTION = 4
;Turns the window into a mirrored window (Vista and above) or turns on new Windows  7 / Server 2008 R2 protection


#PROTECT_DETECTMIRRORDRIVERS = 16
;Detect if mirror driver are active and calls the callback funtion in this case


#DWMFLIP3D_DEFAULT = 0
#DWMFLIP3D_EXCLUDEBELOW = 1
#DWMFLIP3D_EXCLUDEABOVE = 2

#DWMWA_FLIP3D_POLICY = 8
#DWMWA_FORCE_ICONIC_REPRESENTATION = 7

#DWM_EC_DISABLECOMPOSITION = 0
#DWM_EC_ENABLECOMPOSITION = 1

#DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = $1 
#DISPLAY_DEVICE_MULTI_DRIVER        = $2 
#DISPLAY_DEVICE_PRIMARY_DEVICE      = $4 
#DISPLAY_DEVICE_MIRRORING_DRIVER    = $8 
#DISPLAY_DEVICE_VGA_COMPATIBLE      = $10 
#DISPLAY_DEVICE_REMOVABLE           = $20 
#DISPLAY_DEVICE_MODESPRUNED         = $8000000 
#DISPLAY_DEVICE_REMOTE              = $4000000 
#DISPLAY_DEVICE_DISCONNECT          = $2000000 
#DISPLAY_DEVICE_ACTIVE              = $1 
#DISPLAY_DEVICE_ATTACHED            = $2 

#OWNER_SECURITY_INFORMATION    =   $00000001
#GROUP_SECURITY_INFORMATION    =   $00000002
#DACL_SECURITY_INFORMATION     =   $00000004
#SACL_SECURITY_INFORMATION     =   $00000008
#LABEL_SECURITY_INFORMATION    =   $00000010
 
#PROTECTED_DACL_SECURITY_INFORMATION   =  $80000000
#PROTECTED_SACL_SECURITY_INFORMATION   =  $40000000
#UNPROTECTED_DACL_SECURITY_INFORMATION =  $20000000
#UNPROTECTED_SACL_SECURITY_INFORMATION =  $10000000


Procedure ProtectProcess()
  Protected *pACL.ACL
  Protected cbACL = 1024;
   
  ; Initialize a security descriptor.
  Protected *pSD.SECURITY_DESCRIPTOR = AllocateMemory(#SECURITY_DESCRIPTOR_MIN_LENGTH)
  InitializeSecurityDescriptor_(*pSD, #SECURITY_DESCRIPTOR_REVISION)
  *pACL = AllocateMemory(cbACL);
  InitializeAcl_(*pACL, cbACL, #ACL_REVISION2)
  SetSecurityDescriptorDacl_(*pSD, #True, *pACL, #False)
   
  ;SetFileSecurity_("C:\TEST.TXT",#DACL_SECURITY_INFORMATION, *pSD) ; <-- remove all rights from a certain file
  SetKernelObjectSecurity_(GetCurrentProcess_(), #DACL_SECURITY_INFORMATION, *pSD) ; <-- now you cannot close the process with the task manager
EndProcedure

;#ENUM_CURRENT_SETTINGS = -1 
;#ENUM_REGISTRY_SETTINGS = -2 

#WDA_MONITOR = 1

Prototype.i __DwmIsCompositionEnabled(*ptrEnabled)
Prototype.i __DwmEnableComposition(enable.i)  
Prototype.i __DwmSetWindowAttribute(hwnd.i ,dwAttribute.i ,pvAttribute.i ,iSize.i)
Prototype.i __MagInitialize() 
Prototype.i __MagUnInitialize() 
Prototype SetWindowDisplayAffinity(hwnd.i, dwAffinity)

Structure GLOBAL_DWM
  DWMModule.i
  DwmIsCompositionEnabled.__DwmIsCompositionEnabled
  DwmEnableComposition.__DwmEnableComposition
  DwmSetWindowAttribute.__DwmSetWindowAttribute
EndStructure

Structure GLOBAL_USER
  user32.i
  SetWindowDisplayAffinity.SetWindowDisplayAffinity
EndStructure

Structure GLOBAL_PROTECTION
  bInitalized.i
  ;hModule.i
  bDWMDisabled.i
  bHotkeysDisabled.i
  iCountProtectedWindows.i
  iErrorCode.i
EndStructure

Global g_Protection.GLOBAL_PROTECTION
Global g_DWM.GLOBAL_DWM
Global g_MagnModule.i
Global g_USER.GLOBAL_USER 


Declare __ChangeDWMProtection(hWnd)

Procedure DWM_IsEnabled()
  Protected bDWMEnabled.i
  bDWMEnabled.i = #False
  If g_DWM\DwmIsCompositionEnabled
    g_DWM\DwmIsCompositionEnabled(@bDWMEnabled)
  EndIf
  ProcedureReturn bDWMEnabled
EndProcedure

Procedure DWM_Enable(enable.i)
  Protected iResult.i
  iResult = #E_FAIL 
  If g_DWM\DwmEnableComposition
    iResult = g_DWM\DwmEnableComposition(enable)
  EndIf
  ProcedureReturn iResult
EndProcedure


Procedure DWM_Init()
  If g_DWM\DWMModule = #Null
    g_DWM\DWMModule = LoadLibrary_("dwmapi.dll")
    If g_DWM\DWMModule
      g_DWM\DwmIsCompositionEnabled = GetProcAddress_(g_DWM\DWMModule, "DwmIsCompositionEnabled")
      g_DWM\DwmEnableComposition = GetProcAddress_(g_DWM\DWMModule, "DwmEnableComposition")
      g_DWM\DwmSetWindowAttribute = GetProcAddress_(g_DWM\DWMModule, "DwmSetWindowAttribute")
    EndIf
  EndIf
EndProcedure

Procedure DWM_Free()
  If g_DWM\DWMModule
    FreeLibrary_(g_DWM\DWMModule)
    g_DWM\DwmIsCompositionEnabled = #Null
    g_DWM\DwmEnableComposition = #Null
    g_DWM\DwmSetWindowAttribute = #Null
  EndIf
EndProcedure

Procedure DisablePrintHotkeys()
  RegisterHotKey_(0, #IDHOT_SNAPDESKTOP, 0, #VK_SNAPSHOT)
  RegisterHotKey_(0, #IDHOT_SNAPWINDOW, #MOD_ALT, #VK_SNAPSHOT)
  RegisterHotKey_(0, $C000, #MOD_ALT|#MOD_CONTROL, #VK_SNAPSHOT)
  RegisterHotKey_(0, $B000, #MOD_CONTROL, #VK_SNAPSHOT)
EndProcedure

Procedure EnablePrintHotkeys()
  UnregisterHotKey_( 0, #IDHOT_SNAPDESKTOP)
  UnregisterHotKey_( 0, #IDHOT_SNAPWINDOW)
  UnregisterHotKey_( 0, $B000)
  UnregisterHotKey_( 0, $C000)
EndProcedure

Procedure ForceLayeredWindow(hWnd.i)
  If GetWindowLongPtr_(hWnd, #GWL_EXSTYLE) & #WS_EX_LAYERED
    ProcedureReturn #True
  Else
    If SetProp_(hWnd, "LayerAdd", #True)
      If SetWindowLongPtr_(hWnd, #GWL_EXSTYLE, GetWindowLongPtr_(hWnd, #GWL_EXSTYLE) | #WS_EX_LAYERED)
        If SetLayeredWindowAttributes_(hWnd, 0, 255, #LWA_ALPHA)
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure RestoreLayeredWindow(hWnd.i)
  If GetProp_(hWnd, "LayerAdd")
    If RemoveProp_(hWnd, "LayerAdd")
      If SetWindowLongPtr_(hWnd, #GWL_EXSTYLE, GetWindowLongPtr_(hWnd, #GWL_EXSTYLE) &  (~#WS_EX_LAYERED))
        RedrawWindow_(hWnd, #Null, #Null, #RDW_ERASE | #RDW_INVALIDATE | #RDW_FRAME | #RDW_ALLCHILDREN)
        ProcedureReturn #True
      EndIf
    EndIf
  Else
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Init()
  Protected MagInitialize.__MagInitialize
  ;Debug "call init"
  If g_MagnModule = #Null
    g_MagnModule = LoadLibrary_("Mag"+ReplaceString("nPort fPort catPort on", "Port ", "i")+".dll" ); "Magnification.dll"
    ;Debug g_MagnModule
    If g_MagnModule
      ;Debug "0"
      MagInitialize.__MagInitialize = GetProcAddress_(g_MagnModule, ReplaceString("CoInitialize", "Co", "Mag") ); "MagInitialize"
      If MagInitialize
        ;Debug "1"
        If MagInitialize()
          ;Debug "init ok"
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
    
    If g_MagnModule
      FreeLibrary_(g_MagnModule)
      g_MagnModule = #Null
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Free()
  Protected MagUnInitialize.__MagUnInitialize
  If g_MagnModule 
    MagUnInitialize.__MagUnInitialize = GetProcAddress_(g_MagnModule, ReplaceString("CoUnInitialize", "Co", "Mag") ); "MagUnInitialize"
    If MagUnInitialize
      MagUnInitialize()
    EndIf
    FreeLibrary_(g_MagnModule)
    g_MagnModule = #Null
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Add(hWnd)
  Protected hWndChild
  If hWnd And g_MagnModule 
    hWndChild = CreateWindowEx_(0,"Magnifier","",#WS_CHILD,0,0,1,1,hWnd,0,0,0)
    If hWndChild
      ;Debug "ok"
      SetProp_(hWnd, "MagWnd", hWndChild)
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Remove(hWnd)
  Protected hWndChild
  If hWnd And g_MagnModule
    hWndChild = GetProp_(hWnd, "MagWnd")
    If hWndChild
      RemoveProp_(hWnd, "MagWnd")
      DestroyWindow_(hWndChild)
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure USER_Init()
  g_USER\user32 = LoadLibrary_("user32.dll")
  If g_USER\user32
    g_USER\SetWindowDisplayAffinity = GetProcAddress_(g_USER\user32, ReplaceString("SetName", "Name", "Window") + ReplaceString(ReplaceString("Volume Information", "Volume", "Display"), " Information", "Affinity") ); "SetWindowDisplayAffinity"
  EndIf
  ProcedureReturn g_USER\SetWindowDisplayAffinity
EndProcedure

Procedure USER_EnableHWNDProtection(hWnd) ;This function succeeds only when the window is layered and Desktop Windows Manager is composing the desktop. 
  Protected bResult = #False
  If DWM_IsEnabled()
    If g_USER\SetWindowDisplayAffinity
      If g_USER\SetWindowDisplayAffinity(hWnd, #WDA_MONITOR)
        SetProp_(hWnd, "Win7Protection", #True)
        bResult = #True
      EndIf  
    EndIf  
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure USER_DisableHWNDProtection(hWnd)
  Protected bResult = #False
  If g_USER\SetWindowDisplayAffinity
    If GetProp_(hWnd, "Win7Protection")
      If g_USER\SetWindowDisplayAffinity(hWnd, 0)
        RemoveProp_(hWnd, "Win7Protection")
        bResult = #True
      EndIf  
    EndIf
  EndIf  
  ProcedureReturn bResult  
EndProcedure

Procedure USER_IsProtectionPossible()
  If g_USER\SetWindowDisplayAffinity
    If DWM_IsEnabled()
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure USER_Free()
  If g_USER\user32
    g_USER\SetWindowDisplayAffinity = #Null
    FreeLibrary_(g_USER\user32)
  EndIf  
  g_USER\user32 = #Null
EndProcedure


;Detects mirror drivers
Procedure __SearchMirrorDrivers()
  Protected bResult, device.DISPLAY_DEVICE, settings.DEVMODE, n.i, DC.i
  bResult = #False
  device.DISPLAY_DEVICE
  device\cb = SizeOf(DISPLAY_DEVICE) 
  settings.DEVMODE
  settings\dmSize = SizeOf(settings) 
  settings\dmDriverExtra = 0 
  
  While EnumDisplayDevices_(0,n,@device,0) > 0
    n + 1
    If device\StateFlags & #DISPLAY_DEVICE_MIRRORING_DRIVER And device\StateFlags & #DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
      ; Active mirror driver!
      If EnumDisplaySettings_(@device\DeviceName, #ENUM_CURRENT_SETTINGS, @settings)     
        If settings\dmPelsWidth > 1 Or settings\dmPelsHeight > 1  
          ;           ;First draw a black box on the mirror driver
          ;           DC.i = CreateDC_(@device\DeviceName,0,0,0)
          ;           If DC 
          ;             BitBlt_(DC, 0, 0, settings\dmPelsWidth, settings\dmPelsHeight, 0 , 0, 0, #BLACKNESS)
          ;             DeleteDC_(DC)
          ;           EndIf
          ;           ;then change the resolution of the mirror driver
          ;           settings\dmFields = #DM_PELSWIDTH | #DM_PELSHEIGHT
          ;           settings\dmPelsWidth = 1
          ;           settings\dmPelsHeight = 1
          ;           ChangeDisplaySettingsEx_(@device\DeviceName, settings, #Null, 0, #Null)     
          bResult = #True    
        EndIf     
      EndIf 
    EndIf
  Wend
  ProcedureReturn bResult
EndProcedure

Procedure __cbWnd(hWnd.i, Msg.i, wParam.i, lParam.i)
  Protected *CB, oldCB.i
  
  ;Debug "protection callback running...."
  If Msg = #WM_PRINT ;Or #WM_PRINTCLIENT  ;WM_PRINTCLIENT hangs application
    If GetProp_(hWnd, "Win7Protection") = #False ; 2011-04-08 only if no new win 7 protection active...
      ;Do nothing
      ProcedureReturn #True
    EndIf
  EndIf
  
  If Msg = #WM_TIMER And wParam = 1349993282 ;'PwCB'
    ;Debug "protection timer running..."
    
    If GetProp_(hWnd, "DetectMirrorDrivers")
      ;Debug "Check Mirror Drivers"
      ;Time to detect mirror devices
      If __SearchMirrorDrivers()
        *CB = GetProp_(hWnd, "EndAppCB")
        If *CB
          CallFunctionFast(*CB)
        EndIf
      EndIf  
    EndIf
    
    If GetProp_(hWnd, "CheckDWM")
      ;Debug "Check DWM"
      If DWM_IsEnabled() = #False And GetProp_(hWnd, "Win7Protection")
        
        SetProp_(hWnd, "CheckDWM", #False)
        ;First try to swith to Vista protection....
        If __ChangeDWMProtection(hWnd) = #False   
          ; If failed then terminate!
          *CB = GetProp_(hWnd, "EndAppCB")
          If *CB
            CallFunctionFast(*CB)
          EndIf                        
        EndIf  
        
      EndIf  
    EndIf  
    ProcedureReturn #False   
  EndIf
  
  oldCB.i = GetProp_(hWnd, "ProtectWndCB")
  If oldCB
    ProcedureReturn CallWindowProc_(oldCB, hWnd.i, Msg.i, wParam.i, lParam.i)
  Else
    ProcedureReturn DefWindowProc_(hWnd.i, Msg.i, wParam.i, lParam.i)
  EndIf
EndProcedure

Procedure InstallCallBack(hWnd.i, bDetectMirrorDriver.i, bCheckDWM.i, *EndAppCB)
  Protected oldCB.i
  If hWnd
    
    oldCB = GetWindowLongPtr_(hWnd, #GWLP_WNDPROC)
    
    If oldCB
      SetProp_(hWnd, "ProtectWndCB", oldCB)
      SetProp_(hWnd, "EndAppCB", *EndAppCB)
      
      If bCheckDWM
        SetProp_(hWnd, "CheckDWM", #True)
      Else
        SetProp_(hWnd, "CheckDWM", #False)        
      EndIf  
      
      SetWindowLongPtr_(hWnd, #GWLP_WNDPROC, @__cbWnd())
      If bDetectMirrorDriver
        SetProp_(hWnd, "DetectMirrorDrivers" ,#True)
        If __SearchMirrorDrivers()
          If *EndAppCB
            CallFunctionFast(*EndAppCB)
          EndIf
        EndIf
      Else
        SetProp_(hWnd, "DetectMirrorDrivers" ,#False)
      EndIf
      SetTimer_(hWnd, 1349993282, 50, #Null)   ; 'PwCB'    
      ProcedureReturn #True   
    EndIf
    
  EndIf
  ProcedureReturn #False
EndProcedure


Procedure UnInstallCallBack(hWnd.i)
  Protected oldCB.i
  If hWnd
    oldCB.i = GetProp_(hWnd, "ProtectWndCB")
    If oldCB
      If SetWindowLongPtr_(hWnd, #GWLP_WNDPROC, oldCB)
        RemoveProp_(hWnd, "ProtectWndCB")
        RemoveProp_(hWnd, "EndAppCB")
        RemoveProp_(hWnd, "DetectMirrorDrivers")
        RemoveProp_(hWnd, "CheckDWM")
      EndIf
    EndIf
    KillTimer_(hWnd, 1349993282) ; 'PwCB'
  EndIf
EndProcedure

Procedure __ChangeDWMProtection(hWnd)
  Protected bResult.i = #False
  If IsWindow_(hWnd)   
    USER_DisableHWNDProtection(hWnd)   
    If MAGNIFICATION_Add(hWnd)
      If g_Protection\bDWMDisabled = #False
        If DWM_Enable(#False) = #S_OK
          g_Protection\bDWMDisabled = #True
          bResult = #True
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure

ProcedureDLL.i ProtectWindow(hWnd.i, iFlags.i, *EndAppCB)
  Protected iErrorCode = #PROTECTION_ERR_OK, bWin7Protection = #False
  If g_Protection\bInitalized
    If IsWindow_(hWnd)
      
      If GetProp_(hWnd, "ProtectWndCB") = #Null
        
        If (iFlags & #PROTECT_ENABLECONTENTPROTECTION) Or (iFlags & #PROTECT_FORCELAYEREDWINDOW)
          If ForceLayeredWindow(hWnd) = #False
            iErrorCode = #PROTECTION_ERR_NOLAYEREDWINDOW
          EndIf
        EndIf
        
        If iErrorCode = #PROTECTION_ERR_OK          
          
          If iFlags & #PROTECT_ENABLECONTENTPROTECTION     
            ;Use new WIndows 7 protection if possible
            If USER_IsProtectionPossible()
              bWin7Protection = #True
            Else   
              bWin7Protection = #False
            EndIf  
            
            If bWin7Protection
              USER_EnableHWNDProtection(hWnd)
            Else         
              ;Disable DWM if not already disabled
              If g_Protection\bDWMDisabled = #False
                DWM_Enable(#False)
                g_Protection\bDWMDisabled = #True
              EndIf
              
              If DWM_IsEnabled() = #False
                MAGNIFICATION_Add(hWnd) ; Call only if aero is disabled or no aero!!!! (flackert ansonsten!)
              EndIf 
            EndIf           
          EndIf  
          
          If iFlags & #PROTECT_DISABLEPRINTHOTKEYS And g_Protection\bHotkeysDisabled = #False
            g_Protection\bHotkeysDisabled = #True
            DisablePrintHotkeys()
          EndIf
          
          If iFlags & #PROTECT_DETECTMIRRORDRIVERS
            InstallCallBack(hWnd, #True, bWin7Protection, *EndAppCB)
          Else
            InstallCallBack(hWnd, #False, bWin7Protection, *EndAppCB)
          EndIf
          
          SetProp_(hWnd, "Protect", #True)
          g_Protection\iCountProtectedWindows + 1                            
        EndIf       
        
      Else
        iErrorCode = #PROTECTION_ERR_ALREADYPROTECTED
      EndIf  
      
    Else
      iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
    EndIf
  Else
    iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED    
  EndIf  
  
  If iErrorCode <> #PROTECTION_ERR_OK
    g_Protection\iErrorCode = iErrorCode
    ProcedureReturn #False
  Else
    g_Protection\iErrorCode = #PROTECTION_ERR_OK
    ProcedureReturn #True    
  EndIf  
EndProcedure


ProcedureDLL.i UnProtectWindow(hWnd.i)
  Protected iErrorCode.i = #PROTECTION_ERR_OK
  
  If g_Protection\bInitalized
    If IsWindow_(hWnd)
      If GetProp_(hWnd, "Protect") = #True
        
        UnInstallCallBack(hWnd)     
        ;DWM_EnableFlip3DAndThumbnail(hWnd)      
        ;If GetProp_(hWnd, "Win7Protection")
        USER_DisableHWNDProtection(hWnd)  
        ;Else  
        MAGNIFICATION_Remove(hWnd)
        ;EndIf  
        RestoreLayeredWindow(hWnd)
        
        RemoveProp_(hWnd, "Protect")
        
        g_Protection\iCountProtectedWindows - 1
        
        If g_Protection\iCountProtectedWindows <= 0     
          If g_Protection\bDWMDisabled
            DWM_Enable(#True)
            g_Protection\bDWMDisabled = #False
          EndIf     
          
          If g_Protection\bHotkeysDisabled
            EnablePrintHotkeys()
            g_Protection\bHotkeysDisabled = #False
          EndIf      
        EndIf
        ProcedureReturn #True
      EndIf
      
    Else
      iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
    EndIf
  Else
    iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED
  EndIf
  
  If iErrorCode <> #PROTECTION_ERR_OK
    g_Protection\iErrorCode = iErrorCode
    ProcedureReturn #False
  Else
    g_Protection\iErrorCode = #PROTECTION_ERR_OK
    ProcedureReturn #True    
  EndIf   
EndProcedure


ProcedureDLL.i GetProtectionLastError()
  ProcedureReturn g_Protection\iErrorCode
EndProcedure


ProcedureDLL InitWindowProtector()
  DWM_Init()
  MAGNIFICATION_Init()
  USER_Init()
  g_Protection\bDWMDisabled = #False
  g_Protection\bHotkeysDisabled = #False
  ;g_Protection\hModule = #Null  
  g_Protection\iCountProtectedWindows = 0
  g_Protection\bInitalized = #True
EndProcedure

ProcedureDLL FreeWindowProtector()
  If g_Protection\bDWMDisabled
    DWM_Enable(#True)
    g_Protection\bDWMDisabled = #False
  EndIf
  
  If g_Protection\bHotkeysDisabled
    EnablePrintHotkeys()
    g_Protection\bHotkeysDisabled = #False
  EndIf
  
  g_Protection\bInitalized = #False
  g_Protection\iCountProtectedWindows = 0
  
  USER_Free()
  MAGNIFICATION_Free()
  DWM_Free()
EndProcedure

#INTERNET_REQFLAG_CACHE_WRITE_DISABLED = 23
;#INTERNET_OPTION_REQUEST_FLAGS = $00000040

Structure StartParameter
  bScreenshotProtection.i
  bFullscreen.i
  bDisableContexMenu.i
  bDisableShortcuts.i
  bResizeable.i
  bTopmost.i
  bPopup.i
  sStartFile.s
  sTitle.s
  iWidth.i
  iHeight.i
EndStructure

DisableExplicit

#ICON_SMALL = 0
#ICON_BIG = 1
#PROTECTOR_SHORTCUT_ESCAPE = 100
#PROTECTOR_SHORTCUT_F11 = 101

Prototype.i WinApiAtlAxCreateControl(lpszName.p-unicode, hWnd,*pStream.IStream, *ppUnkContainer.Integer)
Prototype.i WinApiAtlAxGetControl(hWnd, retObject)
Prototype.i WinApiCreateWindowExA(dwExStyle.i, lpClassName.i, lpWindowName.i, dwStyle, x, y , nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)


Global NewList StartedProcesses.i()
Global _g_bCloseApp = #False
Global _g_bDisableScreenshots = #False, _g_bDisableContextMenu = #False, _g_bDisableHotkey = #False
Global _g_iWidth = 640, _g_iHeight = 480, _g_bWindowed = #False, _g_bFullscreen = #False, _g_bMaximized = #True
Global _g_sStartFile.s  = "index.html"
Global _g_sTitle.s = "HTML Viewer"
Global _g_bDisableDrag = #False, _g_isInFullscreenMode = #False, _g_lastStyle = 0, _g_bNoResize = #False, _g_bCanToggle = #True, _g_bHiddenProcesses = #False
Global _g_bSticky = #False

Global WinApi_AtlAxCreateControl.WinApiAtlAxCreateControl
Global WinApi_CreateWindowExA.WinApiCreateWindowExA
Global WinApi_AtlAxGetControl.WinApiAtlAxGetControl

Procedure __Hooked_OleInitialize(reserved)
  Debug "OLE"
  ProcedureReturn #S_OK
EndProcedure  

Procedure __CBStatic(hWnd, Message, WParam, LParam)
 If Message = #WM_CTLCOLORSTATIC
     SetBkMode_(wParam, #TRANSPARENT)
     ProcedureReturn GetStockObject_(#HOLLOW_BRUSH)
   Else     
     If GetProp_(hWnd, "OldCB")
       ProcedureReturn CallWindowProc_(GetProp_(hWnd, "OldCB"), hWnd, Message, WParam, LParam)
     Else
       ProcedureReturn DefWindowProc_(hWnd, Message, WParam, LParam)
     EndIf  
 EndIf    
EndProcedure 
 

Procedure __Hooked_CreateWindowEx(dwExStyle.i, lpClassName.i, lpWindowName.i, dwStyle, x, y , nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)
  Debug "CREATE"
  If lpClassName <> #Null 
    If PeekS(lpClassName) = "AtlAxWin"  
      hWnd = WinApi_CreateWindowExA(0, @"static", @"", #WS_CHILD | #WS_VISIBLE | #WS_CLIPCHILDREN, x, y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)
      
      SetProp_(hWnd, "OldCB", GetWindowLong_(hWnd, #GWL_WNDPROC))
      SetWindowLong_(hWnd, #GWL_WNDPROC, @__CBStatic())
      
      WinApi_AtlAxCreateControl("Shell.Explorer.1", hWnd, 0, @Container.IUnknown)
      ProcedureReturn hWnd
    EndIf
  EndIf   
  ProcedureReturn WinApi_CreateWindowExA(dwExStyle, lpClassName, lpWindowName, dwStyle, x, y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam)
EndProcedure


Procedure DisableInternetCache()
  Protected val.l = #INTERNET_REQFLAG_CACHE_WRITE_DISABLED
  InternetSetOption_(#Null,#INTERNET_OPTION_REQUEST_FLAGS, @val, 4)
EndProcedure  


Procedure EndApp()
  HideWindow(0, #True)
  MessageRequester("Protector","An active mirror driver was detected." + #CRLF$ + "The application will end now.", #MB_ICONWARNING)
  _g_bCloseApp = #True
EndProcedure  




Procedure.s ProgramFilename2() ; wegen BoxedApp
  file.s = PeekS(GetCommandLine_()) 
  If Left(file, 1)=Chr(34)
    file = Right(file, Len(file)-1)
    file = Left(file, FindString(file, Chr(34), 1) - 1)
  Else
    file = StringField(file, 1, " ")
  EndIf
  
  If Trim(GetPathPart(file)) = ""
    file = GetCurrentDirectory() + file
  EndIf  
  
  If FileSize(file) <= 0
    file = ProgramFilename()
  EndIf  
  ProcedureReturn file
EndProcedure
;exec://%25EXE_DIR%25test.exe?param1=open&param2=%25EXE_DIR%25readme.txt

Procedure.s AdaptURL(URL$,replaceSlash)
  
  If Right(URL$,1) = "/"
    URL$ = Left(URL$, Len(URL$)-1)
  EndIf  
  URL$ = URLDecoder(Trim(URL$))
  URL$ = ReplaceString(URL$, "%CURRENT_DIR%", GetCurrentDirectory())
  URL$ = ReplaceString(URL$, "%EXE_DIR%", GetPathPart(ProgramFilename2())) 
  URL$ = ReplaceString(URL$, "%TEMP_DIR%", GetTemporaryDirectory()) 
  URL$ = ReplaceString(URL$, "%HOME_DIR%", GetHomeDirectory())     
  
  syspath.s = Space(#MAX_PATH+1)
  GetSystemDirectory_(@syspath,#MAX_PATH)
  
  URL$ = ReplaceString(URL$, "%SYSTEM_DIR%", syspath + "\")  
  If replaceSlash
    URL$ = ReplaceString(URL$, "\", "/")
  EndIf  
  ProcedureReturn Trim(URL$)  
EndProcedure  

Procedure.s GetParametersFromURL(URL$)
  
  If Left(LCase(URL$), Len("exec://")) = "exec://" Or Left(LCase(URL$), Len("execc://")) = "execc://"   
    If Right(URL$,1) = "/"
      URL$ = Left(URL$, Len(URL$)-1)
    EndIf  
    paramIdx = 1
    params.s = "" 
    While GetURLPart(URL$, "param" + Str(paramIdx)) <> ""
      
      param.s = GetURLPart(URL$, "param" + Str(paramIdx)) 
      
      params + param+ " "
      paramIdx+1
    Wend  
    ProcedureReturn AdaptURL(params,#False)
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure.s GetFileFromURL(URL$)
  do = #False
  If Left(LCase(URL$), Len("exec://")) = "exec://"
    do = #True
    URL$ = Right(URL$, Len(URL$) - Len("exec://"))
  EndIf
  If Left(LCase(URL$), Len("execc://")) = "execc://"
    do = #True
    URL$ = Right(URL$, Len(URL$) - Len("execc://"))
  EndIf  
  If do  
    If Right(URL$,1) = "/"
      URL$ = Left(URL$, Len(URL$)-1)
    EndIf
    If FindString(URL$, "?")
      URL$ = Left(URL$, FindString(URL$, "?") - 1)
    EndIf   
    ProcedureReturn ReplaceString(AdaptURL(URL$,#False), "/", "\")
  Else
    ProcedureReturn URL$
  EndIf
EndProcedure


Procedure ToggleFullscreen()
  If _g_bCanToggle
    If IsWindow(0)
      If _g_isInFullscreenMode      
        ;StickyWindow(0,#False)             
        SetWindowLong_(WindowID(0),#GWL_STYLE, _g_lastStyle)       
        ShowWindow_(WindowID(0),#SW_SHOWNORMAL) ;Nötig!
        ShowWindow_(WindowID(0),#SW_SHOWMAXIMIZED)
        
        _g_isInFullscreenMode = #False
      Else
        _g_lastStyle = GetWindowLong_(WindowID(0), #GWL_STYLE)
        ;StickyWindow(0,#True)         
        SetWindowLong_(WindowID(0), #GWL_STYLE, #WS_VISIBLE | #WS_POPUP)
        ShowWindow_(WindowID(0),#SW_SHOWMAXIMIZED)
        _g_isInFullscreenMode = #True
      EndIf
    EndIf
  EndIf
EndProcedure 


Procedure Start(url.s)
  If Left(LCase(url), Len("execc://")) = "execc://"  
    ;Close always after executing
    _g_bCloseApp = #True  
  Else
  EndIf  
  start.s = GetFileFromURL(url)
  params.s = GetParametersFromURL(url)
  
  Debug start
  Debug params
  
  If LCase(start) = "close"
    _g_bCloseApp = #True
    
  ElseIf LCase(start) = "toggle"
    ToggleFullscreen()
  Else  
    If start <> ""
      If _g_bHiddenProcesses
        process = RunProgram(start,params,"", #PB_Program_Open|#PB_Program_Hide )        
        
      Else
        process = RunProgram(start,params,"", #PB_Program_Open)
      EndIf  
      If process <> 0
        AddElement(StartedProcesses())
        StartedProcesses() = process
      EndIf  
    EndIf  
  EndIf
EndProcedure

Procedure NavigationCallback(Gadget, Url$)
  Debug Url$
  If Left(LCase(Url$), Len("exec://")) = "exec://" Or Left(LCase(Url$), Len("execc://")) = "execc://"  
    Start(Url$)
    ProcedureReturn #False
  EndIf  
  
  ProcedureReturn #True
EndProcedure

Procedure.s PrepareConfig(str.s)
  str = Trim(ReplaceString(str, "{/###space###}", " "))
  If Left(str,1)=Chr(34)
    str = Right(str,Len(str)-1)
  EndIf  
  If Right(str,1)=Chr(34)
    str = Left(str,Len(str)-1)
  EndIf   
  ProcedureReturn str
EndProcedure  

Procedure ProcessParameter(param.s,nextparam.s)
  param.s = Trim(UCase(param))
  
  If Left(param,1) ="-"
    param = "/" + Right(param,Len(param)-1)
  EndIf  
  If Left(param,1) ="\"
    param = "/" + Right(param,Len(param)-1)
  EndIf    
  
  If param = "/NOSCREENSHOT"
    _g_bDisableScreenshots = #True
  EndIf  
  
  If param = "/NOMENU"
    _g_bDisableContextMenu = #True
  EndIf  
  
  If param = "/NOHOTKEYS"
    _g_bDisableHotkey = #True    
  EndIf  
  
  If param = "/NODRAG" 
    _g_bDisableDrag = #True
  EndIf
  
  If param = "/STICKY" 
    _g_bSticky = #True
  EndIf  

  If param = "/NORESIZE"
    _g_bNoResize = #True
  EndIf  
  
  If param = "/PROTECT"
    _g_bDisableScreenshots = #True
    _g_bDisableContextMenu = #True
    _g_bDisableHotkey = #True 
    _g_bDisableDrag = #True    
  EndIf  
  
  If param = "/PROTECTPROCESS"
    ProtectProcess()
  EndIf
  
  If param = "/TITLE"
    _g_sTitle = nextparam
  EndIf    
  
  If param = "/START"
    _g_sStartFile = AdaptURL(nextparam, #True)
  EndIf    
  
  If param = "/STARTFILE"
    _g_sStartFile = AdaptURL("file://%25EXE_DIR%25" + nextparam, #True)
  EndIf    
  
  If param = "/HIDDENPROCESSES"
    _g_bHiddenProcesses = #True
  EndIf  
  
  If param = "/WIDTH"
    _g_iWidth = Val(nextparam)
    _g_bMaximized = #False
    _g_bFullscreen = #False
    _g_bWindowed = #True
  EndIf    
  
  If param = "/HEIGHT"
    _g_iHeight = Val(nextparam)
    _g_bMaximized = #False
    _g_bFullscreen = #False
    _g_bWindowed = #True   
  EndIf 
  
  If param = "/FULLSCREEN"
    _g_bMaximized = #False
    _g_bFullscreen = #True
    _g_bWindowed = #False
  EndIf  
EndProcedure


If FileSize(GetPathPart(ProgramFilename2()) + "index.html") > 0
  _g_sStartFile = AdaptURL("file://%25EXE_DIR%25index.html", #True)  
EndIf  

If FileSize(GetPathPart(ProgramFilename2()) + "index.htm") > 0
  _g_sStartFile = AdaptURL("file://%25EXE_DIR%25index.htm", #True)
EndIf  


If FileSize(ReplaceString(ProgramFilename2(), ".exe", ".config"))
  If ReadFile(1,ReplaceString(ProgramFilename2(), ".exe", ".config"))
    
    line.s = ReadString(1)
    For i = 1 To Len(line)
      If Mid(line,i, 1) = Chr(34)
        inside = ~inside
      EndIf  
      
      If Mid(line,i, 1) = " " And inside
        newline.s + "{/###space###}" 
      Else
        newline.s + Mid(line,i, 1)
      EndIf   
    Next    
    
    For i = 1 To CountString(newline, " ")+1
      ProcessParameter(PrepareConfig(StringField(newline,i, " ")), PrepareConfig(StringField(newline,i+1, " ")) )
    Next  
    CloseFile(1)
  EndIf  
EndIf  

i = 0
While i < CountProgramParameters()  
  ProcessParameter(ProgramParameter(i), ProgramParameter(i+1))
  i+1
Wend

If _g_bDisableDrag
  hAtl = LoadLibrary_("atl.dll")
  hUser = LoadLibrary_("user32.dll")
  
  If hAtl And hUser
    WinApi_AtlAxCreateControl = GetProcAddress_(hAtl, "AtlAxCreateControl")
    WinApi_AtlAxGetControl = GetProcAddress_(hAtl, "AtlAxGetControl")    
    WinApi_CreateWindowExA = GetProcAddress_(hUser, "CreateWindowExA")
    
    If WinApi_AtlAxCreateControl And WinApi_CreateWindowExA ; only if possible...
      !extrn __imp__OleInitialize@4
      !MOV eax,__imp__OleInitialize@4
      !MOV [v__g_imp__OleInitialize],eax
      _g_new_imp_OleInitialize = @__Hooked_OleInitialize()
      WriteProcessMemory_(GetCurrentProcess_(), _g_imp__OleInitialize, @_g_new_imp_OleInitialize, SizeOf(Integer), #Null)  
      
      !extrn __imp__CreateWindowExA@48
      !MOV eax,__imp__CreateWindowExA@48
      !MOV [v__g_imp__CreateWindowEx],eax
      _g_new_imp_CreateWindowEx = @__Hooked_CreateWindowEx()
      WriteProcessMemory_(GetCurrentProcess_(), _g_imp__CreateWindowEx, @_g_new_imp_CreateWindowEx, SizeOf(Integer), #Null)  
    EndIf
  EndIf
  CoInitialize_(0) 
EndIf  

If _g_bDisableScreenshots
  InitWindowProtector()
EndIf

DisableInternetCache()

If _g_bDisableHotkey
  ;Vorsichthalber deaktiveren, obwohl scheinbar nicht aktiviert
  RegisterHotKey_(0, $C000, #MOD_CONTROL, #VK_C)
  RegisterHotKey_(0, $C001, #MOD_CONTROL, #VK_X) 
  RegisterHotKey_(0, $C002, #MOD_CONTROL, #VK_P)      
EndIf  


If _g_bNoResize
  flags = 0
Else
  flags = #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget
EndIf  

If _g_bMaximized Or _g_bFullscreen
  SystemParametersInfo_(#SPI_GETWORKAREA,0,re.rect,0)
  OpenWindow(0, re\left, re\top, re\right - re\left, re\bottom - re\top, _g_sTitle, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | flags | #PB_Window_Maximize)
Else
  OpenWindow(0, 0, 0, _g_iWidth, _g_iHeight, _g_sTitle, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | flags)  
EndIf  

sIconFile.s = GetPathPart(ProgramFilename2()) + "icon.ico"
If FileSize(sIconFile) > 0
  hIcon = LoadImage_(#Null,sIconFile, #IMAGE_ICON,0,0,#LR_LOADFROMFILE)
  SendMessage_(WindowID(0), #WM_SETICON, #ICON_BIG, hIcon)
  SendMessage_(WindowID(0), #WM_SETICON, #ICON_SMALL, hIcon)
EndIf  

If _g_bFullscreen
  ToggleFullscreen()
EndIf  

If _g_bNoResize
  _g_bCanToggle = #False
EndIf  

AddKeyboardShortcut(0, #PB_Shortcut_Escape, #PROTECTOR_SHORTCUT_ESCAPE)
AddKeyboardShortcut(0, #PB_Shortcut_F11, #PROTECTOR_SHORTCUT_F11)

If _g_bDisableScreenshots
  ProtectWindow(WindowID(0), #PROTECT_DISABLEPRINTHOTKEYS|#PROTECT_FORCELAYEREDWINDOW|#PROTECT_ENABLECONTENTPROTECTION|#PROTECT_DETECTMIRRORDRIVERS, @EndApp())
  StickyWindow(0,#True)
  StickyWindow(0,#False) ;sonst ist das fenster hinter dem explorer   
EndIf 

WebGadget(0, 0, 0, WindowWidth(0), WindowHeight(0), _g_sStartFile)    

If IsGadget(0)
  If _g_bDisableContextMenu
    SetGadgetAttribute(0,#PB_Web_BlockPopupMenu, #True)
  EndIf

  SetGadgetAttribute(0, #PB_Web_NavigationCallback, @NavigationCallback())  

  WebObject.IWebBrowser2 = GetWindowLong_(GadgetID(0), #GWL_USERDATA) 
  WebObject\put_RegisterAsDropTarget(#VARIANT_FALSE)
EndIf

Repeat
Until WindowEvent() = 0
SetForegroundWindow_(WindowID(0))

If _g_bSticky
  StickyWindow(0,#True) 
EndIf  

Repeat

  event = WaitWindowEvent(1)
  
  If event = #PB_Event_Menu
    If EventMenu() = #PROTECTOR_SHORTCUT_ESCAPE And _g_isInFullscreenMode
      ToggleFullscreen()
      ResizeGadget(0, #PB_Ignore,#PB_Ignore, WindowWidth(0), WindowHeight(0))
      ;SendMessage_(GadgetID(0),#WM_PAINT,0,0)
    EndIf  
    If EventMenu() = #PROTECTOR_SHORTCUT_F11
      ToggleFullscreen()
      ResizeGadget(0, #PB_Ignore,#PB_Ignore, WindowWidth(0), WindowHeight(0))
      ;SendMessage_(GadgetID(0),#WM_PAINT,0,0)
    EndIf     
    
  EndIf  
  
  If event = #PB_Event_SizeWindow Or event = #PB_Event_MinimizeWindow Or event = #PB_Event_MaximizeWindow
    ResizeGadget(0, #PB_Ignore,#PB_Ignore, WindowWidth(0), WindowHeight(0))
    ;SendMessage_(GadgetID(0),#WM_PAINT,0,0)
  EndIf  
  
  If event = #PB_Event_CloseWindow
    _g_bCloseApp = #True   
  EndIf  
Until _g_bCloseApp

RemoveKeyboardShortcut(0,#PB_Shortcut_All) 

If _g_bDisableHotkey
  ;Vorsichthalber deaktiveren, obwohl scheinbar nicht aktiviert
  UnregisterHotKey_(0, $C000)
  UnregisterHotKey_(0, $C001) 
  UnregisterHotKey_(0, $C002)  
EndIf

If _g_bDisableScreenshots
  UnProtectWindow(WindowID(0))
  CloseWindow(0)
  FreeWindowProtector()
Else
  CloseWindow(0)
EndIf

ForEach StartedProcesses()
  WaitProgram(StartedProcesses())
Next

If hAtl
  FreeLibrary_(hAtl)
EndIf  

If hUser
  FreeLibrary_(hUser)
EndIf  
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 670
; FirstLine = 658
; Folding = --------
; EnableXP
; Executable = ..\HTML.exe
; CommandLine = /WIDTH 1024 /HEIGHT 768 /NODRAG /NOMENU /PROTECT /PROTECTPROCESS /STARTFILE "../testData/index.html"
; CompileSourceDirectory
; Debugger = Standalone