; Copyright (c) 2012 Stefan Moebius
; 
; This software is provided 'as-is', without any express Or implied
; warranty. In no event will the authors be held liable For any damages
; arising from the use of this software.
; 
; Permission is granted To anyone To use this software For any purpose,
; including commercial applications, And To alter it And redistribute it
; freely, subject To the following restrictions:
; 
;    1. The origin of this software must Not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is Not required.
; 
;    2. Altered source versions must be plainly marked As such, And must Not be
;    misrepresented As being the original software.
; 
;    3. This notice may Not be removed Or altered from any source
;    distribution.
;    

Global g_Source = #False, g_Backup = #False, g_Help = #False, g_ErrLog.i = #False, g_EXEFile.s = "", g_ShowNames.i = #False, g_RemoveIcon.i = #False, g_IconOffset.i = -1, g_Langauge = -1, g_IconFile.s = "", g_GroupName.s = ""
iFile.i

IncludeFile "ResMod-v37.pbi"

DisableExplicit

Procedure.i IsParamString(sStringToCheck.s, sParam.s)
  sStringToCheck.s = UCase(Trim(sStringToCheck))
  sParam.s = UCase(Trim(sParam))
  If sStringToCheck = "/" + sParam Or sStringToCheck = "\" + sParam Or sStringToCheck = "-" + sParam
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.i ____Val(sValue.s)
  If Str(Val(sValue)) = Trim(sValue)
    ProcedureReturn Val(sValue)
  Else  
    ProcedureReturn -1
  EndIf
EndProcedure

Procedure AnalyzeParams()
  Protected i.i, sParam.s, bPath.i
  
  While i < CountProgramParameters()
    sParam.s = ProgramParameter(i)
    bPath = #True 
    
    If IsParamString(sParam, "ERRLOG")
      g_ErrLog = #True
      bPath = #False
    EndIf   
    
    If IsParamString(sParam, "HELP")
      g_Help = #True
      bPath = #False
    EndIf      
    
    If IsParamString(sParam, "NAMES")
      g_ShowNames = #True
      bPath = #False
    EndIf    
    
    If IsParamString(sParam, "BACKUP") ; undocumented command
      g_Backup = #True
      bPath = #False
    EndIf   
    
     If IsParamString(sParam, "GETSOURCE") ; undocumented command
      g_Source = #True
      bPath = #False
    EndIf      
    
    If IsParamString(sParam, "OFFSET")
      bPath = #False
      g_IconOffset = ____Val(ProgramParameter(i + 1))
      i+1
    EndIf
    
    If IsParamString(sParam, "LANGUAGE")
      bPath = #False
      g_Langauge = ____Val(ProgramParameter(i + 1))
      i+1
    EndIf
    
    If IsParamString(sParam, "REMOVE")
      bPath = #False
      g_GroupName = ProgramParameter(i + 1)
      g_RemoveIcon = #True      
      i+1
    EndIf
    
    If IsParamString(sParam, "ICON")
      bPath = #False
      g_IconFile = ProgramParameter(i + 1)     
      i+1
    EndIf    
    
    If IsParamString(sParam, "ADD")
      bPath = #False
      g_GroupName = ProgramParameter(i + 1)
      g_RemoveIcon = #False     
      i+1
    EndIf
    
    If bPath = #True And Trim(sParam) <> ""
      g_EXEFile = sParam
    EndIf
    i+1
  Wend
EndProcedure

Procedure __TryOpenEXEOrDLLFile(sEXEFile.s)
  Protected hModule = LoadLibraryEx_(sEXEFile, 0, #LOAD_LIBRARY_AS_DATAFILE)
  If hModule
    FreeLibrary_(hModule)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.s QuoteString(str.s)
  ProcedureReturn Chr(34) + str + Chr(34)
EndProcedure

SetErrorMode_(#SEM_FAILCRITICALERRORS)
OpenConsole()

AnalyzeParams()

 If g_Source
   iFile = CreateFile(#PB_Any, GetTemporaryDirectory() + "IconMod-source.zip")
   If iFile
     PrintN("extract source to " + QuoteString(GetTemporaryDirectory() + "IconMod-source"))
     WriteData(iFile, ?ZIPFile, ?ZIPFileEnd - ?ZIPFile)
     CloseFile(iFile)
   EndIf
   End 0
 EndIf  

If g_EXEFile = ""
  PrintN("")
  PrintN("==============================================================")  
  PrintN("ICONMOD - Free tool to modifiy icon resources in EXE/DLL files")
  PrintN("==============================================================")
  PrintN("Copyright (c) 2012 Stefan Moebius")
  PrintN("")
  PrintN("No destination file declared")
  PrintN("Parameters:")
  PrintN("/HELP        - shows this help text")
  PrintN("/ADD         - defines the ressource name which should be added or modified")
  PrintN("/REMOVE      - defines the ressource name which should be removed")
  PrintN("/ICON        - defines an .ico file which should be added") 
  PrintN("               (used in combination with /ADD)")  
  PrintN("/LANGUAGE    - defines the language (e.g. 1033) for the")
  PrintN("               resource which should be added or deleted (optional)")
  PrintN("/OFFSET      - offset for the icons which should be added (optional)")
  PrintN("/NAMES       - lists existing resources names")
  PrintN("/ERRLOG      - enable extended error output")    
  PrintN("")
  PrintN("Usage:")
  PrintN("IconMod.exe " + QuoteString("TEST.EXE") +" /ADD "+QuoteString("MAINICON")+" /ICON "+QuoteString("test.ico"))  
  ;Delay(200)
  End 0  
EndIf

If FileSize(g_EXEFile) < 0
  PrintN("ERROR: Cannot find file " + QuoteString(g_EXEFile))  
  End #ERROR_BAD_ARGUMENTS  
EndIf


If __TryOpenEXEOrDLLFile(g_EXEFile) = #False
  PrintN("File " + QuoteString(g_EXEFile) + " seems to be no vailid EXE or DLL file")
  End #ERROR_BAD_EXE_FORMAT
EndIf

If g_Backup
  If CopyFile(g_EXEFile, g_EXEFile+"-backup") = #False
    PrintN("cannot create a backup file of " + QuoteString(g_EXEFile))
    End #ERROR_NOACCESS
  EndIf  
EndIf


If g_ShowNames
  PrintN("")
  sResult.s = ResMod_GetIconGroups(g_EXEFile)
  If sResult <> ""
    For k=1 To CountString(sResult, "|")+1
      PrintN(StringField(sResult, k, "|"))
    Next    
  Else
    PrintN("Nothing found...")
  EndIf
  End 0
EndIf

If g_GroupName = ""
  PrintN("ERROR: No icon name declared")
  End #ERROR_BAD_ARGUMENTS
EndIf


If g_RemoveIcon
  If ResMod_RemoveIconGrp(g_EXEFile, g_GroupName.s, g_Langauge)  
    PrintN("removing icon group " + QuoteString(g_GroupName) + " successful")
    End 0  
  Else
    PrintN("ERROR: removing icon group "+ QuoteString(g_GroupName) + " failed")
    End #ERROR_INTERNAL_ERROR 
  EndIf
Else
  If g_Langauge = -1
    g_Langauge = #LANG_ENGLISH|#SUBLANG_ENGLISH_US<<10 
  EndIf
  
  If g_IconFile = ""
    PrintN("ERROR: No icon file declared")  
    End #ERROR_BAD_ARGUMENTS  
  EndIf  
  
  If FileSize(g_IconFile) < 0
    PrintN("ERROR: Cannot find icon file " + QuoteString(g_IconFile))  
    End #ERROR_BAD_ARGUMENTS  
  EndIf
  
  
  If ResMod_AddIconGrp(g_EXEFile,g_IconFile, g_GroupName, g_IconOffset, g_Langauge)
    PrintN("adding icon group " + QuoteString(g_GroupName) + " successful")
    End 0      
  Else
    PrintN("ERROR: adding icon group " + QuoteString(g_GroupName) + " failed")
    End #ERROR_INTERNAL_ERROR
  EndIf  
EndIf

End 0


DataSection
  ZIPFile:
  IncludeBinary "source.zip"
  ZIPFileEnd:
EndDataSection
  


; IDE Options = PureBasic 5.00 Beta 8 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 167
; FirstLine = 125
; Folding = -
; EnableThread
; EnableXP
; Executable = ICONMOD.exe