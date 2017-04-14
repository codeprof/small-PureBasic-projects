Import "uuid.lib" 
  IID_IHTMLDocument2 
  IID_IViewObject 
EndImport 

#MSHTML_WINDOW = 100
#MSHTML_WEBCOONTROL = 101
#MSHTML_TIMEOUT = 5000
#MSHTML_IMAGE = 100

Structure DVASPECTINFO 
  cb.i
  dwFlags.i
EndStructure

Global mshtml_isinitialized = #False
Global mshtml_imgWidth = 0
Global mshtml_imgHeight = 0
Global mshtml_svgWidth = 0
Global mshtml_svgHeight = 0
Global mshtl_workerThread = #Null
Global mshtml_initDoneSemaphore = #Null
Global mshtml_mutexTerminateWorkerThread = #Null
Global mshtml_startRenderSemaphore = #Null
Global mshtml_finishedRenderSemaphore = #Null
Global mshtml_svgString.s = ""
Global *mshtml_svgMemoryPtr = #Null
Global mshtml_svgMemorySize = 0
Global mshtml_renderResult = #False
Global mshtml_WebGadget.IWebBrowser2, mshtml_Document.IHTMLDocument2, mshtml_Dispatch.iDispatch

Procedure.l __CreateVolatileDWORDRegKey(topkey.i, subkey.s, name.s, value.l)
  Protected handle.i , res.i, disposition.i
  res = RegCreateKeyEx_(topkey,@subkey,0,0,#REG_OPTION_VOLATILE,#KEY_CREATE_SUB_KEY|#KEY_SET_VALUE,0,@handle,@disposition)
  If res = #ERROR_SUCCESS 
    res = RegSetValueEx_(handle,@name,0,#REG_DWORD ,@value, 4)
    RegCloseKey_(handle)
  EndIf
  ProcedureReturn res
EndProcedure

Procedure.l __LoadHTMLDocMem(mshtml_Document.IHTMLDocument2, *ptrStart, size)
  ;SVG-File must begin with:
  ;<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
  ;<?xml version="1.0" encoding="UTF-8" standalone="no"?>                   
  Protected *Mem, *Buffer, HTMLStream.IStream, *HTMLPerStrmInit.IPersistStreamInit, bResult = #False  
  If *ptrStart And (size > 0)
    *Mem = GlobalAlloc_(#GMEM_MOVEABLE, size)
    If *Mem
      *Buffer = GlobalLock_(*Mem)
      If *Buffer
        CopyMemory(*ptrStart,*Buffer, size)       
      EndIf
      GlobalUnlock_(*Mem)
      If CreateStreamOnHGlobal_(*Buffer, #True, @HTMLStream.IStream) = #S_OK     
        mshtml_Document\QueryInterface(?IID_IPersistStreamInit, @*HTMLPerStrmInit.IPersistStreamInit) ; query for IPersistStreamInit    
        If *HTMLPerStrmInit        
          *HTMLPerStrmInit\InitNew();
          If *HTMLPerStrmInit\load(HTMLStream) = #S_OK ;load stream
            bResult = #True
          EndIf
          *HTMLPerStrmInit\Release() ;decrease ref. count
        EndIf 
        HTMLStream\Release()
        ;GlobalFree_(*Mem) ;will be freeed automatically
      Else
        GlobalFree_(*Mem) ;free it if CreateStreamOnHGlobal fails
      EndIf
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure MSHTML_Init()
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", GetFilePart(ProgramFilename()), $2AF9)
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_CLIPCHILDREN_OPTIMIZATION", GetFilePart(ProgramFilename()), 1)
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SPELLCHECKING", GetFilePart(ProgramFilename()), 0)
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_NAVIGATION_SOUNDS", GetFilePart(ProgramFilename()), 1)
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_IVIEWOBJECTDRAW_DMLT9_WITH_GDI", GetFilePart(ProgramFilename()), 0)
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_GPU_RENDERING", GetFilePart(ProgramFilename()), 1)
  __CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BLOCK_CROSS_PROTOCOL_FILE_NAVIGATION", GetFilePart(ProgramFilename()), 0)
  ;__CreateVolatileDWORDRegKey(#HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_STATUS_BAR_THROTTLING", GetFilePart(ProgramFilename()), 1)
  ExamineDesktops()
  If OpenWindow(#MSHTML_WINDOW, 0, 0, DesktopWidth(0), DesktopHeight(0), "", #PB_Window_Invisible) 
    If WebGadget(#MSHTML_WEBCOONTROL, 0, 0, 1, 1, "about:") 
      mshtml_WebGadget = GetWindowLong_(GadgetID(#MSHTML_WEBCOONTROL),#GWL_USERDATA)
      If mshtml_WebGadget
        mshtml_WebGadget\put_Silent(#True) 
        mshtml_WebGadget\put_Visible(#False)
        mshtml_WebGadget\put_Offline(#True)
        If mshtml_WebGadget\Get_Document(@mshtml_Dispatch) = #S_OK 
          If mshtml_Dispatch\QueryInterface(@IID_IHTMLDocument2, @mshtml_Document) = #S_OK 
            mshtml_isinitialized = #True
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  SignalSemaphore(mshtml_initDoneSemaphore)
EndProcedure

Procedure MSHTML_Free()
  If mshtml_Document
    mshtml_Document\Release()
  EndIf
  If mshtml_Dispatch
    mshtml_Dispatch\Release() 
  EndIf
  mshtml_Document = #Null
  mshtml_Dispatch = #Null
EndProcedure

Procedure.i RenderHTMLToHDC(hdc, width, height, *mem, size) 
  Protected oViewObject.IViewObject, rc.RECT, info.DVASPECTINFO, result = #False
  If mshtml_isinitialized
    If GadgetWidth(#MSHTML_WEBCOONTROL) <> width Or GadgetHeight(#MSHTML_WEBCOONTROL) <> height
      ResizeGadget(#MSHTML_WEBCOONTROL, 0, 0, width, height)
    EndIf  
    While WindowEvent() 
    Wend  
    If __LoadHTMLDocMem(mshtml_Document, *mem, size)   
      start = ElapsedMilliseconds()
      Repeat 
        mshtml_Document\Get_ReadyState(@bstr) 
        res.s = PeekS(bstr, -1, #PB_Unicode) 
        SysFreeString_(bstr) 
        WindowEvent()
        !PAUSE
      Until (ElapsedMilliseconds() - start > #MSHTML_TIMEOUT) Or res = "complete"
      ;col.VARIANT
      ;col\vt = #VT_BSTR
      ;col\bstrVal = SysAllocString_(@"#FF00FF")     
      ; mshtml_Document\put_bgColor(col)
      If res = "complete"
        If mshtml_Document\Queryinterface(@IID_IViewObject, @oViewObject) = #S_OK  
          SetRect_(rc, 0, 0, width, height) 
          
          info\cb = SizeOf(DVASPECTINFO)
          info\dwFlags = 1;#DVASPECTINFOFLAG_CANOPTIMIZE
          If oViewObject\Draw(#DVASPECT_CONTENT, -1, info, 0, 0, hdc, rc, 0, 0, 0) = #S_OK 
            mshtml_renderResult = #True
          EndIf 
          oViewObject\Release() 
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn result 
EndProcedure 

Procedure worker_thread(dummy)
  MSHTML_Init() 
  Repeat 
    WaitSemaphore(mshtml_startRenderSemaphore)
    mshtml_renderResult = #False
    If (Not IsImage(#MSHTML_IMAGE)) Or mshtml_imgWidth <> mshtml_svgWidth Or mshtml_imgHeight <> mshtml_svgHeight
      mshtml_imgWidth = mshtml_svgWidth
      mshtml_imgHeight = mshtml_svgHeight     
      CreateImage(#MSHTML_IMAGE, mshtml_imgWidth, mshtml_imgHeight, 32) 
    EndIf
    If IsImage(#MSHTML_IMAGE)
      hdc=StartDrawing(ImageOutput(#MSHTML_IMAGE))
      result = RenderHTMLToHDC(hdc, mshtml_imgWidth, mshtml_imgHeight, *mshtml_svgMemoryPtr, mshtml_svgMemorySize) 
      StopDrawing()
    EndIf  
    SignalSemaphore(mshtml_finishedRenderSemaphore)
    !PAUSE
  Until TryLockMutex(mshtml_mutexTerminateWorkerThread)
  MSHTML_Free()
EndProcedure

Procedure SVG_Init()
  mshtml_initDoneSemaphore = CreateSemaphore()
  mshtml_mutexTerminateWorkerThread = CreateMutex()
  mshtml_startRenderSemaphore = CreateSemaphore()
  mshtml_finishedRenderSemaphore = CreateSemaphore()
  LockMutex(mshtml_mutexTerminateWorkerThread)
  mshtl_workerThread = CreateThread(@worker_thread(),0)
  If mshtl_workerThread
    WaitSemaphore(mshtml_initDoneSemaphore)  
  EndIf  
  FreeSemaphore(mshtml_initDoneSemaphore)
  ProcedureReturn mshtml_isinitialized
EndProcedure

Procedure SVG_Free()
  If mshtml_mutexTerminateWorkerThread
    UnlockMutex(mshtml_mutexTerminateWorkerThread)
    FreeMutex(mshtml_mutexTerminateWorkerThread)
  EndIf  
  If mshtml_finishedRenderSemaphore
    FreeSemaphore(mshtml_finishedRenderSemaphore)
  EndIf  
  If mshtml_startRenderSemaphore
    FreeSemaphore(mshtml_startRenderSemaphore)
  EndIf    
  mshtml_mutexTerminateWorkerThread = #Null
  mshtml_finishedRenderSemaphore = #Null
  mshtml_startRenderSemaphore = #Null
  If IsImage(#MSHTML_IMAGE)
    FreeImage(#MSHTML_IMAGE)
  EndIf
  If IsGadget(#MSHTML_WEBCOONTROL)
    FreeGadget(#MSHTML_WEBCOONTROL)
  EndIf
  If IsWindow(#MSHTML_WINDOW)
    CloseWindow(#MSHTML_WINDOW)
  EndIf
EndProcedure

Procedure SVG_Render(width, height, resizeWidth, resizeHeight, *mem, size)
  mshtml_svgWidth = width
  mshtml_svgHeight = height
  *mshtml_svgMemoryPtr = *mem
  mshtml_svgMemorySize = size 
  SignalSemaphore(mshtml_startRenderSemaphore)
  ;wait until thread finished rendering
  WaitSemaphore(mshtml_finishedRenderSemaphore)       
  
  If width <> resizeWidth Or height <> resizeHeight
    If ResizeImage(#MSHTML_IMAGE, resizeWidth, resizeHeight, #PB_Image_Smooth)
      mshtml_imgWidth = resizeWidth
      mshtml_imgHeight = resizeHeight       
    EndIf
  EndIf
EndProcedure



SVG_Init()
If OpenWindow(0, 0, 0, 600, 480, "test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget) 
  
  a=ElapsedMilliseconds()
  For k=0 To 1000
    SVG_Render(WindowWidth(0), WindowHeight(0), WindowWidth(0), WindowHeight(0), ?A,?B-?A)
  Next
  MessageRequester("",Str(ElapsedMilliseconds()-a))  
  ImageGadget(3,0,0,0,0,ImageID(#MSHTML_IMAGE))
  
  Repeat 
    eventID = WaitWindowEvent() 
    Select eventID 
      Case #PB_Event_SizeWindow
        SVG_Render(WindowWidth(0), WindowHeight(0), WindowWidth(0), WindowHeight(0), ?A,?B-?A)
        ImageGadget(3,0,0,0,0,ImageID(#MSHTML_IMAGE))  
    EndSelect 
    
  Until eventID = #PB_Event_CloseWindow 
EndIf 


DataSection
  A:
  IncludeBinary "C:\Users\admin\Downloads\test.svg"
  B:
EndDataSection


DataSection 
  IID_IPersistStreamInit:
  Data.q $101B4E077FD52380,$13C72E2B00082DAE
  
  IID_IConnectionPointContainer:
  Data.l $B196B284
  Data.w $BAB4, $101A
  Data.b $B6, $9C, $00, $AA, $00, $34, $1D, $07
EndDataSection
