

Prototype.i DllRegisterServer()
;Prototype.i DllUnRegisterServer()


Global iExitCode.i = #ERROR_SUCCESS, iResult.i, iErrCode.i
Global sDLLFilename.s = ""
Global bRegister.i= #True, bRegisterAllUsers.i = #False, bSilent = #False, bDialog = #False

#TITLE = "RegSvr32User"

Enumeration
#ERR_OK
#ERR_INIT_FAILED
#ERR_DLLLOAD_FAILED
#ERR_FUNCTION_NOTFOUND
#ERR_FUNCTION_FAILED
#ERR_UNEXPECTED
EndEnumeration


#ADMIN_VERSION = #False
;=================================================================================
;                             HOOKING FUNCTIONS
;=================================================================================



Structure IMAGE_IMPORT_DESCRIPTOR
  OriginalFirstThunk.l
  TimeDateStamp.l
  ForwarderChain.l
  Name.l
  FirstThunk.l
EndStructure

Structure IMAGE_THUNK_DATA
  *Function.i
EndStructure

#TH32CS_SNAPMODULE = $8 

Prototype.l _ImageDirectoryEntryToData(ImageBase.l,MappedAsImage.l,DirectoryEntry.l,Size.l)


Procedure __GetModuleIATLastByte(*Module.IMAGE_DOS_HEADER)
Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  If *Module
    *Img_NT_Headers = *Module + *Module\e_lfanew
    If *Img_NT_Headers
      If *Img_Nt_Headers\OptionalHeader
        If *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]
          ProcedureReturn  *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]\Size + *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]\VirtualAddress
        EndIf
      EndIf
    EndIf
  EndIf
ProcedureReturn #Null
EndProcedure

Procedure.i __HOOKAPI_SetMemoryProtection(*Addr, iProtection)
  If VirtualQuery_(*addr,mbi.MEMORY_BASIC_INFORMATION,SizeOf(MEMORY_BASIC_INFORMATION))
    If VirtualProtect_(mbi\BaseAddress, mbi\RegionSize, iProtection, @iOldProtection)
      ProcedureReturn iOldProtection
    EndIf
  EndIf
  ProcedureReturn -1
EndProcedure

Procedure.i __HOOKAPI_GetImportTable(*Module.IMAGE_DOS_HEADER)
  Protected ImageDirectoryEntryToData._ImageDirectoryEntryToData
  Protected *Imagehlp
  Protected iErrMode.i
  
  Protected *ptr.LONG,*pEntryImports.IMAGE_IMPORT_DESCRIPTOR
  Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  
  If *Module
  
;     ;iErrMode = SetErrorMode_(#SEM_FAILCRITICALERRORS) ; Don't display error messages
;     *Imagehlp = GetModuleHandle_("imagehlp.dll")
;     
;     ;First try To use imagehlp API (2000/XP/Vista)
;     If *Imagehlp
;       ImageDirectoryEntryToData = GetProcAddress_(*Imagehlp,"ImageDirectoryEntryToData")
;       If ImageDirectoryEntryToData
;         *pEntryImports = ImageDirectoryEntryToData(*Module, #True, #IMAGE_DIRECTORY_ENTRY_IMPORT, @lSize)    
;         If *pEntryImports
;           ProcedureReturn *pEntryImports
;         EndIf
;       EndIf   
;     EndIf
    
    ;If imagehlp api is not available
    *Img_NT_Headers = *Module + *Module\e_lfanew
    If *Img_NT_Headers
      *ptr = *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IMPORT]
      If *ptr
        *pEntryImports = *Module + *ptr\l
        ProcedureReturn *pEntryImports
      EndIf
    EndIf
  
  EndIf
  ProcedureReturn #Null
EndProcedure

Procedure.i __HOOKAPI_GetExportTable(*Module.IMAGE_DOS_HEADER)
  Protected ImageDirectoryEntryToData._ImageDirectoryEntryToData
  Protected *Imagehlp
  Protected iErrMode.i
  
  Protected *ptr.LONG,*pEntryExports.IMAGE_EXPORT_DIRECTORY
  Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  
  If *Module
  
;     ;iErrMode = SetErrorMode_(#SEM_FAILCRITICALERRORS) ; Don't display error messages
;     *Imagehlp = GetModuleHandle_("imagehlp.dll")
;     ;SetErrorMode_(iErrMode)
;     
;     ; First try to use imagehlp API (2000/XP/Vista)
;      If *Imagehlp
;        ImageDirectoryEntryToData = GetProcAddress_(*Imagehlp,"ImageDirectoryEntryToData")
;        If ImageDirectoryEntryToData
;          *pEntryExports = ImageDirectoryEntryToData(*Module, #True, #IMAGE_DIRECTORY_ENTRY_EXPORT, @lSize)    
;          If *pEntryExports
;            ProcedureReturn *pEntryExports
;          EndIf
;        EndIf   
;      EndIf
    
    ;If imagehlp api is not available
    *Img_NT_Headers = *Module + *Module\e_lfanew
    If *Img_NT_Headers
      *ptr = *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_EXPORT]
      If *ptr
        *pEntryExports = *Module + *ptr\l
        ProcedureReturn *pEntryExports
      EndIf
    EndIf
  
  EndIf
  ProcedureReturn #Null
EndProcedure

Procedure.i __HOOKAPI_ReplaceImportedFunctionInModule(hModule.i,sModuleName.s, sFunction.s, *NewFunctionPtr.i)


*OldFunction.i = GetProcAddress_(GetModuleHandle_(sModuleName.s), sFunction)
If *OldFunction

  *ImportedDLLs.IMAGE_IMPORT_DESCRIPTOR = __HOOKAPI_GetImportTable(hModule)
  If *ImportedDLLs
    LastByte.i = __GetModuleIATLastByte(hModule) + hModule
  
  
    While *ImportedDLLs\Name And *ImportedDLLs\FirstThunk
      
      sName.s = ""
      If *ImportedDLLs\Name And *ImportedDLLs\FirstThunk
      
        addr1 = *ImportedDLLs\Name + hModule;RvaToVa(hModule,*ImportedDLLs\Name)
        If *ImportedDLLs\Name And LastByte - (*ImportedDLLs\FirstThunk + hModule) > 0 And hModule
        ;XXXDebug = *ImportedDLLs\Name
        ;sName.s = UCase(PeekS(hModule + *ImportedDLLs\Name))
        sName.s = UCase(PeekS(addr1))
        EndIf
        
      EndIf
      ;__MyDebug( sName
      
    
      If UCase(sName) = UCase(sModuleName)
        *itd.IMAGE_THUNK_DATA = *ImportedDLLs\FirstThunk + hModule
        If *ImportedDLLs\FirstThunk
        
        
        ;*itd.IMAGE_THUNK_DATA = RvaToVa(hModule,*ImportedDLLs\FirstThunk)
        ;If *itd 
                
        While *itd\Function
          If *itd\Function = *OldFunction
            iOldProtection.i = __HOOKAPI_SetMemoryProtection(*itd, #PAGE_EXECUTE_READWRITE)

            If iOldProtection <> -1
              *itd\Function = *NewFunctionPtr ; Set new Function pointer

              __HOOKAPI_SetMemoryProtection(*itd, iOldProtection)
            EndIf
            
          EndIf
          *itd + SizeOf(IMAGE_THUNK_DATA)
        Wend
        EndIf
        
      EndIf
      
      *ImportedDLLs + SizeOf(IMAGE_IMPORT_DESCRIPTOR)
    Wend
  
  Else

  EndIf

Else

EndIf

EndProcedure



Procedure.i __HOOKAPI_ReplaceExportedFunctionInModule(sModuleName.s, sFunction.s, *NewFunctionPtr.i)
hModule.i = GetModuleHandle_(sModuleName.s)
*OldFunction.i = GetProcAddress_(hModule, sFunction)

If *OldFunction And *NewFunctionPtr And hModule


  *ExportedFunctions.IMAGE_EXPORT_DIRECTORY = __HOOKAPI_GetExportTable(hModule)
  If *ExportedFunctions
  
    *Addr.Integer = *ExportedFunctions\AddressOfFunctions + hModule
    
    If *Addr
      For i = 0 To *ExportedFunctions\NumberOfFunctions - 1
   
        If *Addr\i + hModule = *OldFunction

          iOldProtection.i = __HOOKAPI_SetMemoryProtection(*Addr, #PAGE_EXECUTE_READWRITE)
          If iOldProtection <> -1
            ;k= *Addr\i
            ;MessageBox_(0,Str(*Addr),Str(IsBadWritePtr_(*addr,4)),#MB_OK)
            
            *Addr\i = *NewFunctionPtr - hModule
            ;new = k;*NewFunctionPtr - hModule
            ;WriteProcessMemory_(GetCurrentProcess_(),*Addr,@new,4,#Null)
            
            __HOOKAPI_SetMemoryProtection(*Addr, iOldProtection)
          EndIf
        EndIf
        *Addr + SizeOf(Integer)
      Next
    EndIf
      
  EndIf
EndIf

EndProcedure

Procedure.i __HOOKAPI_ReplaceImportedFunctionInAllModules(sModuleName.s, sFunction.s, *NewFunctionPtr.i)

    iResult.i = #False
    snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE, 0) 
    If snapshot 
    
        module.MODULEENTRY32
        module\dwSize = SizeOf(MODULEENTRY32) 
        
        If Module32First_(snapshot, @module) 
            While Module32Next_(snapshot, @module)         
              If module\hModule
                iResult = __HOOKAPI_ReplaceImportedFunctionInModule(module\hModule, sModuleName, sFunction, *NewFunctionPtr)             
              EndIf
            Wend
        EndIf    
        CloseHandle_(snapshot)
    EndIf 
     
    iResult = __HOOKAPI_ReplaceImportedFunctionInModule(GetModuleHandle_(0), sModuleName, sFunction, *NewFunctionPtr)             
    
  ProcedureReturn iResult
EndProcedure


Procedure.i __HookApi(sModule.s, sFunction.s, *NewFunction.i)
If *NewFunction
  *OldFunction = GetProcAddress_(GetModuleHandle_(sModule), sFunction)
  __HOOKAPI_ReplaceImportedFunctionInAllModules(sModule.s, sFunction.s, *NewFunction)
  __HOOKAPI_ReplaceExportedFunctionInModule(sModule.s, sFunction.s, *NewFunction)
  ProcedureReturn *OldFunction
EndIf
EndProcedure

;=================================================================================







Prototype.i OaEnablePerUserTLibRegistration()
Prototype.i RegOverridePredefKey(hKey.i,hNewKey.i)


Structure APIHOOKS
bRegisterTypeLibHooked.i
OrgRegisterTypeLib.i
NewRegisterTypeLib.i
EndStructure

Structure LOADEDDLL
oleaut32.i
advapi32.i
EndStructure

Global g_DLLs.LOADEDDLL
Global g_Hooks.APIHOOKS


Procedure.i Init()
  bResult.i = #True
  g_DLLs\oleaut32 = LoadLibrary_("oleaut32.dll")
  g_DLLs\advapi32 = LoadLibrary_("advapi32.dll")
  If g_DLLs\oleaut32 = #Null Or g_DLLs\advapi32 = #Null
    bResult = #False
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure.i OverrideClassesRoot()
bResult.i = #False
RegOverridePredefKey.RegOverridePredefKey = GetProcAddress_(g_DLLs\advapi32, "RegOverridePredefKey")
If RegOverridePredefKey
  If RegOpenKeyEx_(#HKEY_CURRENT_USER, "Software\Classes", 0 ,#KEY_ALL_ACCESS, @hNewKey) = #ERROR_SUCCESS
    If RegOverridePredefKey(#HKEY_CLASSES_ROOT, hNewKey) = #ERROR_SUCCESS
      bResult = #True
      RegCloseKey_(hNewKey)
    EndIf
  EndIf  
EndIf
ProcedureReturn bResult 
EndProcedure

Procedure RestoreClassesRoot()
RegOverridePredefKey.RegOverridePredefKey = GetProcAddress_(g_DLLs\advapi32, "RegOverridePredefKey")
If RegOverridePredefKey
  RegOverridePredefKey(#HKEY_CLASSES_ROOT, #Null)
EndIf
EndProcedure

Procedure.i EnablePerUserRegistration()
bResult.i =  #True

OaEnablePerUserTLibRegistration.OaEnablePerUserTLibRegistration = GetProcAddress_(g_DLLs\oleaut32, "OaEnablePerUserTLibRegistration")
If OaEnablePerUserTLibRegistration ; erst ab Windows Vista ohne SP1 verfügbar
  OaEnablePerUserTLibRegistration()
Else
  If OSVersion() = #PB_OS_Windows_Vista
    ; Hooking ist nur notwendig bei Windows Vista ohne SP1 und nur wenn UAC angeschalten ist(?)
    g_Hooks\NewRegisterTypeLib = GetProcAddress_(g_DLLs\oleaut32, "RegisterTypeLibForUser")
    If g_Hooks\NewRegisterTypeLib
      g_Hooks\OrgRegisterTypeLib = __HookApi("oleaut32.dll", "RegisterTypeLib", g_Hooks\NewRegisterTypeLib)
      g_Hooks\bRegisterTypeLibHooked = #True
    Else
     bResult = #False
    EndIf
  Else
    g_Hooks\bRegisterTypeLibHooked = #False
  EndIf
EndIf
ProcedureReturn bResult
EndProcedure

Procedure Free()
RestoreClassesRoot()
If g_Hooks\bRegisterTypeLibHooked
  __HookApi("oleaut32.dll", "RegisterTypeLib", g_Hooks\OrgRegisterTypeLib)
EndIf
If g_DLLs\oleaut32:FreeLibrary_(g_DLLs\oleaut32):EndIf
If g_DLLs\advapi32:FreeLibrary_(g_DLLs\advapi32):EndIf
EndProcedure

Procedure ErrorMsg(iCode.i)
  sDLL.s = Chr(34) + sDLLFilename+ Chr(34)
  iMsgIcon .i = #MB_ICONERROR
  sText.s = ""
  Select iCode
  Case #ERR_INIT_FAILED
    sText = "Can not load necessary system dlls!"
    iExitCode = #ERROR_NOT_SUPPORTED
  Case #ERR_DLLLOAD_FAILED
    sText = "Failed to load dll/ocx file " + sDLL
    iExitCode = #ERROR_DLL_INIT_FAILED
  Case #ERR_FUNCTION_NOTFOUND
    If bRegister
      sText = "The function DllRegisterServer was not found in: " + sDLL 
    Else
      sText = "The function DllUnregisterServer was not found in: " + sDLL
    EndIf
    iExitCode = #ERROR_NOT_SUPPORTED
  Case #ERR_UNEXPECTED
     sText = #TITLE +" failed with unexpected error: " + ErrorMessage()
    iExitCode = -1
  Case #ERR_FUNCTION_FAILED  
    If bRegister
      sText = "DllRegisterServer for " + sDLL + " failed with error code: "+Str(iResult) 
    Else
      sText = "DllUnregisterServer for " + sDLL + " failed with error code: "+Str(iResult) 
    EndIf
    iExitCode = iResult
  Case #ERR_OK
    If bRegister
      sRegister.s = " registered"
    Else
      sRegister.s = " unregistered"  
    EndIf
    If bRegisterAllUsers
      sUser.s = "all users."
    Else
       sUser.s = "the current user." 
    EndIf
    sText = sDLL + sRegister +" sucessfully for " + sUser
    iExitCode = #ERROR_SUCCESS
    iMsgIcon = #MB_ICONINFORMATION
  Default
    sText = #TITLE +" failed with unknown error!"
    iExitCode = -1
  EndSelect
  If bSilent = #False
    MessageRequester(#TITLE,sText, iMsgIcon)
  EndIf
EndProcedure

Procedure.i IsParamString(sStringToCheck.s, sParam.s)
  sStringToCheck.s = UCase(Trim(sStringToCheck))
  sParam.s = UCase(Trim(sParam))
  If sStringToCheck = "/" + sParam Or sStringToCheck = "\" + sParam Or sStringToCheck = "-" + sParam
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure AnalyzeParams()
For i = 0 To CountProgramParameters() - 1
  sParam.s = ProgramParameter(i)
  bPath = #True 
  If IsParamString(sParam, "U")
    bPath = #False
    bRegister = #False
  EndIf
  If IsParamString(sParam, "I")
    bPath = #False
    bSilent = #True
  EndIf 
  If IsParamString(sParam, "D")
    bPath = #False
    bDialog = #True
  EndIf
  If IsParamString(sParam, "G")
    bPath = #False
    bRegisterAllUsers = #True
  EndIf 
  
  CompilerIf #ADMIN_VERSION = #False
  If IsParamString(sParam, "EXTRACTSOURCE")
  
    iFile = CreateFile(#PB_Any, GetTemporaryDirectory()+"RegSvr32User-Source.zip")
    If iFile
      WriteData(iFile, ?Src, ?SrcEnd - ?Src)
      CloseFile(iFile)
      RunProgram(GetTemporaryDirectory())
    EndIf
    Free()
    End
  EndIf 
  CompilerEndIf

  If bPath = #True And Trim(sParam)<> ""
    sDLLFilename = sParam
  EndIf
Next

  If IsParamString(sParam, "A")
    MessageRequester(#TITLE , #TITLE +" - register dll/ocx without admin rights" + #LF$ + Chr(9) + "© 2009 Stefan Moebius"+#LF$+ #LF$ + "You use this software at your own risk!", #MB_ICONINFORMATION)
    Free()
    End
  EndIf 
  
 If bDialog And bSilent = #False
    Pattern.s = "Dynamic-Link Libraries(*.dll)|*.dll|ActiveX controls(*.ocx)|*.ocx|Alle Files (*.*)|*.*"
    If Trim(sDLLFilename) = ""
      sDLLFilename= "*.dll"
    EndIf
    sDLLFilename.s = OpenFileRequester("", sDLLFilename, Pattern, 0)
  EndIf
  
  If bSilent = #False And Trim(sDLLFilename) = ""  

    sText.s = #TITLE + " - register dll/ocx without admin rights" + #LF$
    sText + "------------------------" + #LF$
    sText + "No path to a dll/ocx file declared!" + #LF$
    sText + "------------------------" + #LF$
    sText + "/u"+ Chr(9) +"unregister dll/ocx" + #LF$
    sText + "/i"+ Chr(9) +"silent mode" + #LF$ 
    sText + "/g"+ Chr(9) +"register for all users(admin rights necessary)"+ #LF$ 
    sText + Chr(9) + "in contrast to RegSvr32 this will ask for" + #LF$
    sText + Chr(9) + "administrator mode if UAC is enabled" + #LF$
    sText + "/a"+ Chr(9) +"show about window" + #LF$ 
    sText + "/d"+ Chr(9) +"show dialog to select a file" + #LF$    
    MessageRequester(#TITLE, sText, #MB_ICONINFORMATION)
    Free()
    End
  EndIf
  

EndProcedure


Procedure.s GetParam(str.s, iIndex.i)
sResult.s = ""
str + " "
For i = 1 To Len(str)

  lch.s = ch.s
  ch.s = Mid(str, i, 1)
  
  If ch = Chr(34)
    bInQuote = ~bInQuote
  EndIf
  
  If ch = " " And bInQuote = #False And lch <> " "
    If iIndex = idx
      ProcedureReturn Trim(sResult)
    EndIf
    idx+1
    sResult = ""
  EndIf
  sResult + ch
Next
EndProcedure

Procedure.s GetCMDParams()
sResult.s=""
sOrgCmd.s = PeekS(GetCommandLine_())
For i = 0 To CountProgramParameters() - 1

If IsParamString(GetParam(sOrgCmd, i + 1), "D")
  sResult + Chr(34) + sDLLFilename + Chr(34) + " "
Else
  sResult + GetParam(sOrgCmd, i + 1) + " "
EndIf

Next
 ProcedureReturn sResult
EndProcedure

CompilerIf #ADMIN_VERSION = #False
Procedure ExtractAndRunAdminVersion()
  sEXEName.s = GetTemporaryDirectory()+"RegSvr32Admin.exe"
  iFile = CreateFile(#PB_Any, sEXEName)
  If iFile = #Null
    sEXEName.s = GetTemporaryDirectory()+"RegSvr32Admin"+Hex(Random($FFFFFF))+".exe"
    iFile = CreateFile(#PB_Any, sEXEName)
  EndIf
  
  If iFile = #Null
    ProcedureReturn #False
  EndIf
  
  WriteData(iFile, ?RegSvr32AdminExe, ?RegSvr32AdminExeEnd - ?RegSvr32AdminExe)
  CloseFile(iFile)
  Program = RunProgram(sExeName, GetCMDParams(), GetCurrentDirectory(),  #PB_Program_Open ) ; return the program handle
    If Program
    WaitProgram(Program)
    iExitCode = ProgramExitCode(Program)
    CloseProgram(Program)
  Else
    iExitCode = GetLastError_()
  EndIf
  DeleteFile(sEXEName)
  ;Delete File later...
  ;MoveFileEx_(sExeName,"",#MOVEFILE_DELAY_UNTIL_REBOOT)
  Free()
  End iExitCode
EndProcedure
CompilerEndIf

Procedure.i CallRegister(sFunction.s)
  If bRegisterAllUsers = #False
    If EnablePerUserRegistration() = #False
      ProcedureReturn #ERR_INIT_FAILED
    EndIf
    If OverrideClassesRoot() = #False
      ProcedureReturn #ERR_INIT_FAILED
    EndIf
  Else
    CompilerIf #ADMIN_VERSION = #False
      ExtractAndRunAdminVersion() 
      ;We know that something failed in this case, but we will continue anyway 
    CompilerEndIf
  EndIf
  hModule.i = LoadLibrary_(sDLLFilename)
  If hModule
    registerFunction.DllRegisterServer = GetProcAddress_(hModule, sFunction)
    If registerFunction
      iResult = registerFunction()
      If iResult <> #S_OK
        ProcedureReturn #ERR_FUNCTION_FAILED
      EndIf
    Else
      ProcedureReturn #ERR_FUNCTION_NOTFOUND
    EndIf
    FreeLibrary_(hModule)
  Else
    ProcedureReturn #ERR_DLLLOAD_FAILED
  EndIf
  ProcedureReturn #ERR_OK
EndProcedure

Procedure Err()
  ErrorMsg(#ERR_UNEXPECTED)
  End iExitCode
EndProcedure

OnErrorCall(@Err())


AnalyzeParams()

If Init()
  If bRegister
    ErrorMsg(CallRegister("DllRegisterServer"))
  Else
    ErrorMsg(CallRegister("DllUnregisterServer"))
  EndIf
Else
  ErrorMsg(#ERR_INIT_FAILED)
EndIf

Free()
End iExitCode

CompilerIf #ADMIN_VERSION = #False
DataSection
RegSvr32AdminExe:
IncludeBinary "RegSvr32Admin.exe"
RegSvr32AdminExeEnd:
Src:
IncludeBinary "RegSvr32User-Source.zip"
SrcEnd:
EndDataSection
CompilerEndIf
; IDE Options = PureBasic 4.40 Beta 5 (Windows - x86)
; CursorPosition = 28
; Folding = ----
; EnableXP
; UseIcon = Icon-Database.ico
; Executable = RegSvr32Admin.exe