

realprog.s = GetFilePart(ProgramFilename()) + "_xxx"


Debug realprog.s

If CreateFile(1,"/root/test891250299534")
  CloseFile(1)
  DeleteFile("/root/test891250299534")
  MessageRequester("WINE", "Wine darf nicht als Admin ausgeführt werden!")
  End
EndIf

;allow_direct = #False
param$ = ""
For i=0 To CountProgramParameters()
  new$ = ProgramParameter(i)
  ;If new$ = "/allow_direct_run"
  ;  allow_direct=#True
  ;EndIf
  If FindString(new$, " ") > 0
    new$ = Chr(34) + new$ + Chr(34)
  EndIf
  param$ = param$ + new$ + " "
Next
param$=Trim(param$);+ " /allow_direct_run"

;If allow_direct
;    RunProgram("/usr/bin/" + realprog, param$, GetCurrentDirectory(), #PB_Program_Wait)  
;Else
  If MessageRequester("WINE", "Start WINE application?" +Chr(13)+"Commandline:"+Chr(13) + param$, #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes 
    ;MessageRequester("WINE", "/usr/bin/" + realprog) 
    RunProgram("/usr/bin/" + realprog, param$, GetCurrentDirectory(), #PB_Program_Wait)
  EndIf
;EndIf
; IDE Options = PureBasic 5.22 LTS Beta 2 (Linux - x64)
; ExecutableFormat = Console
; CursorPosition = 33
; FirstLine = 11
; EnableUnicode
; EnableXP
; Executable = wine_sec
; CommandLine = wine