;License: Public Domain
CompilerIf #PB_Compiler_Unicode = 0
  CompilerError "Should be compiled with Unicode support!"
CompilerEndIf

Global from.s, destination.s

Procedure.s Fit(dir.s)
  If Right(dir,1)<> "\"
    dir = dir + "\"
  EndIf
  ProcedureReturn dir
EndProcedure  


Global Dim test.b(1000000)

Procedure add_files(dir.s)
  If Len(dir.s) < #MAX_PATH
    id = ExamineDirectory(#PB_Any, dir, "*.*")
    If id <> 0
      While NextDirectoryEntry(id)
        FileName$ = DirectoryEntryName(id)
        If DirectoryEntryType(id) = #PB_DirectoryEntry_Directory
          If DirectoryEntryName(id) <> "." And DirectoryEntryName(id) <> ".."
            add_files(Fit(dir) + DirectoryEntryName(id)) 
          EndIf  
        EndIf    
        If DirectoryEntryType(id) = #PB_DirectoryEntry_File
          
          file.s = Fit(dir.s)+ DirectoryEntryName(id)             
          
          If FileSize(file) >= 1000000  
            
            SetGadgetText(1, file)  
            Repeat
              ev = WindowEvent()
              If ev = #PB_Event_CloseWindow:End:EndIf
            Until ev=0  
            
            ok = #False
            ReadFile(1,file)
            FileSeek(1,Lof(1)-1000000)
            ReadData(1, @test(), 1000000)
            For i = 0 To 999999
              If test(i) <> 0:ok = #True:EndIf
            Next  
            CloseFile(1)
            If ok = #False
              MessageRequester("info","Maybe copy error: " + file)
            EndIf  
          EndIf
          
          If FileSize(destination + "STOP.TXT") >=0
            End
          EndIf  
          
          Repeat
            ev = WindowEvent()
            If ev = #PB_Event_CloseWindow:End:EndIf
          Until ev=0  
          
        EndIf  
      Wend
      FinishDirectory(id)
    Else
      MessageRequester("","ERROR: failed To List directory: '" + dir.s + "'")
    EndIf
  Else
    MessageRequester("","WARN: path '" + dir.s + "' is IGNORED because it is too long.")  
  EndIf
EndProcedure

OpenWindow(1,0,0,800,60,"")
TextGadget(1,0,0,800,60,"")

destination.s = Fit(InputRequester("","Folder to check",""))

SetWindowTitle(1,"check " +destination)

add_files(destination)



; IDE Options = PureBasic 5.11 beta 3 (Windows - x86)
; CursorPosition = 45
; FirstLine = 21
; Folding = -
; EnableUnicode
; EnableXP