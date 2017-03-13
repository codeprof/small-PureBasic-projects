;License: Public Domain
CompilerIf #PB_Compiler_Unicode = 0
  CompilerError "Should be compiled with Unicode support!"
CompilerEndIf


Global from.s, destination.s,exts.s, idstr.s

idstr.s = Hex(GetTickCount_())

Procedure.s Fit(dir.s)
  If Right(dir,1)<> "\"
    dir = dir + "\"
  EndIf
  ProcedureReturn dir
EndProcedure  

Procedure Logv(text.s)
      OpenFile(1,GetTemporaryDirectory() + "recursive-copy-log"+idstr.s+".txt")
      FileSeek(1,Lof(1))
      WriteStringN(1,text.s)
      CloseFile(1)  
EndProcedure

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
          dst_real.s = destination + Right(file, Len(file) - Len(from)) 
          dst.s = dst_real.s  + ".$$_TMP_$$"
          
          Debug file
          
          
         
          If FindString(exts,"," + UCase(GetExtensionPart(file)) + ",") Or exts=""
          Debug "y"
            If FileSize(file) >= 0  
              If FileSize(file) <> FileSize(dst_real.s)
                
                If FileSize(dst_real.s) >=0 
                  Logv( dst+ " has other size" + Str(FileSize(dst)))
                EndIf  
                SetGadgetText(1, file)
                
  ;               CreateFile(100, destination + "last.log")
  ;               WriteStringN(100,file + "->" + dst)
  ;               FlushFileBuffers(100)
  ;               CloseFile(100)
                Repeat
                  ev = WindowEvent()
                  If ev = #PB_Event_CloseWindow:End:EndIf
                Until ev=0  
                
                SHCreateDirectory_(#Null, GetPathPart(dst))
                If CopyFile(file, dst) = #False
                  Logv("failed to copy:"+ file + " -->" + dst.s)
                Else
                  If RenameFile(dst, dst_real.s) = #False
                      Logv("failed to rename:"+ dst + " -->" + dst_real.s)                  
                  EndIf  
                EndIf  
              Else
                Debug "ALREADY:" + file
              EndIf  
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
      ;MessageRequester("","ERROR: failed To List directory: '" + dir.s + "'")
      Logv("ERROR: failed To List directory: '" + dir.s + "'")
    EndIf
  Else
    Logv("WARN: path '" + dir.s + "' is IGNORED because it is too long.")
    ;MessageRequester("","WARN: path '" + dir.s + "' is IGNORED because it is too long.")  
  EndIf
EndProcedure

OpenWindow(1,0,0,800,60,"")
TextGadget(1,0,0,800,60,"")


from.s = Fit(InputRequester("","Folder to copy files from",""))

destination.s = Fit(InputRequester("","Folder to copy files to",""))

exts.s = UCase(Trim(InputRequester("","Extensions (Empty For all Files)","MP4,MPG,MPEG,OGV,FLV,3GP,F4V,MKV,TS,MTS")))
If exts <> ""
  exts = "," + exts + ","  
EndIf

MessageRequester("Hint","Put a file with name 'STOP.TXT'"+Chr(13)+" into the destination path to stop the process!")

SetWindowTitle(1,from +" -> " + destination)

add_files(from)

MessageRequester("done", "done with " + from.s)


; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 114
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; Executable = RecursiveCopy5.exe