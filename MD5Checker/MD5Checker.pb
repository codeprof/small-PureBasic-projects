
CompilerIf #PB_Compiler_Unicode = 0
  CompilerError "Should be compiled with Unicode support!"
CompilerEndIf


Global Dim buffer.b($FFFF)
Global MD5ErrorString.s = ""

#INDEX_FILENAME = "md5_check_index.lst"

#WINDOW_WIDTH = 800
#WINDOW_HEIGHT = 630

#GADGET_LOG = 20

#GADGET_STRING_GENERATE = 1
#GADGET_STRING_CHECK = 2

#GADGET_BUTTON_GENERATE_LIST = 3
#GADGET_BUTTON_CHECK_LIST = 4
#GADGET_BUTTON_SAVE_TO_FILE = 5



#FILE_MD5_GENERATED_LIST = 100
#FILE_MD5_CHECK = 101
#FILE_LOG = 102

Procedure ErrorHandler()
 
  ErrorMessage$ = "A program error was detected:" + Chr(13) 
  ErrorMessage$ + Chr(13)
  ErrorMessage$ + "Error Message:   " + ErrorMessage()      + Chr(13)
  ErrorMessage$ + "Error Code:      " + Hex(ErrorCode())    + Chr(13)  
  ErrorMessage$ + "Code Address:    " + Hex(ErrorAddress()) + Chr(13)
 
  If ErrorCode() = #PB_OnError_InvalidMemory   
    ErrorMessage$ + "Target Address:  " + Str(ErrorTargetAddress()) + Chr(13)
  EndIf
 
  ErrorMessage$ + "Sourcecode line: " + Str(ErrorLine()) + Chr(13)
  ErrorMessage$ + "Sourcecode file: " + ErrorFile() + Chr(13)
 
  ErrorMessage$ + Chr(13)
 
  MessageRequester("OnError example", ErrorMessage$)
  End
 
EndProcedure
 
; Setup the error handler.
;
OnErrorCall(@ErrorHandler())


Procedure.s Fit(dir.s)
  If Right(dir,1)<> "\"
    dir = dir + "\"
  EndIf
  ProcedureReturn dir
EndProcedure  


Procedure SelectFileGadget(Id, x, y, width, text$, def$)
  TextGadget(#PB_Any, x, y,      width, 21, text$)
  StringGadget(Id,    x, y + 21, width-21, 21, def$,  #PB_String_ReadOnly )
  ButtonGadget(1000+Id, x + width - 21, y + 21, 21,21 , "...")
EndProcedure


Procedure EndApp()
  If IsFile(#FILE_MD5_GENERATED_LIST)
    CloseFile(#FILE_MD5_GENERATED_LIST)
  EndIf  
  End
EndProcedure  

Procedure LogOut(text.s)
  If IsGadget(#GADGET_LOG)
    AddGadgetItem(#GADGET_LOG, -1, text)  
  EndIf  
EndProcedure  


Procedure ProcessDialog(event)
  If event = #PB_Event_Gadget
    If EventGadget() > 1000     
      result.s = PathRequester("Select folder to check...", "")
      If result <> "" And result <> "\"
        SetGadgetText(EventGadget() - 1000, Fit(result))
      EndIf  
      
    EndIf  
  EndIf
EndProcedure  

Procedure SimpleMessageProcess()
  Repeat
    event = WindowEvent()
    If event = #PB_Event_CloseWindow:EndApp():EndIf
  Until event = 0  
EndProcedure  

Procedure.s MD5OfFile(file.s)
  Protected sz.q, pos.q, length.q, ok = #True, MD5$=""
  MD5ErrorString = ""
  If ReadFile(#FILE_MD5_CHECK, file)
    length.q = Lof(#FILE_MD5_CHECK)
    If ExamineMD5Fingerprint(1)
      
      While (pos < length) And ok = #True
        
        StatusBarProgress(0, 1, Int((pos * 100.0) / (length * 1.0)),#PB_StatusBar_Raised ,0,100)
             
        SimpleMessageProcess()
        FileSeek(#FILE_MD5_CHECK, pos)
        
        sz = (length - pos)
        If sz > $FFFF:sz = $FFFF:EndIf
        
        result = ReadData(#FILE_MD5_CHECK, @buffer(0), sz)
        
        If result > 0
          NextFingerprint(1, @buffer(0), result)
        Else
          LogOut("ERROR: IO read error at position " + Hex(pos) + " in file '" + file.s + "'")
          ok = #False
        EndIf 
        pos + sz  
      Wend
      If ok
        MD5$ = FinishFingerprint(1)
      EndIf
    Else
      LogOut("ERROR: Internal MD5 function error")
    EndIf
    CloseFile(#FILE_MD5_CHECK)  
  Else
    LogOut("ERROR: Cannot open file '"+file+"'")    
  EndIf
  ProcedureReturn MD5$
EndProcedure 


Procedure generate_md5_for_folder(dir.s, path_without_base.s)
  If Len(dir.s) < #MAX_PATH
    id = ExamineDirectory(#PB_Any, dir, "*.*")
    If id <> 0
      While NextDirectoryEntry(id)
        FileName$ = DirectoryEntryName(id)
        If DirectoryEntryType(id) = #PB_DirectoryEntry_Directory
          If DirectoryEntryName(id) <> "." And DirectoryEntryName(id) <> ".."
            generate_md5_for_folder(Fit(dir) + DirectoryEntryName(id), Fit(path_without_base + DirectoryEntryName(id))) 
          EndIf  
        EndIf    
        If DirectoryEntryType(id) = #PB_DirectoryEntry_File
          
          SimpleMessageProcess()
          
          ;Debug path_without_base + DirectoryEntryName(id)
          

          If Trim(LCase(DirectoryEntryName(id))) <> LCase(#INDEX_FILENAME) ; don't list the index file
            StatusBarText(0, 0, path_without_base + DirectoryEntryName(id))
            MD5$= MD5OfFile(Fit(dir.s)+ DirectoryEntryName(id))
            If MD5$ <> ""
              WriteStringN(#FILE_MD5_GENERATED_LIST, path_without_base + DirectoryEntryName(id) + "::" + MD5OfFile(Fit(dir.s) + DirectoryEntryName(id)), #PB_UTF8)         
            EndIf  
          EndIf
        EndIf  
      Wend
      FinishDirectory(id)
    Else
      LogOut("ERROR: failed to list directory: '" + dir.s + "'")
    EndIf
  Else
    LogOut("WARN: path '" + dir.s + "' is IGNORED because it is too long.")  
  EndIf
EndProcedure

Procedure check_md5_of_folder(path.s)
  
  If ReadFile(#FILE_MD5_GENERATED_LIST, Fit(path) + #INDEX_FILENAME)
    
    Repeat
      Line.s = ReadString(#FILE_MD5_GENERATED_LIST, #FILE_MD5_GENERATED_LIST)
      Filename.s = StringField(Line.s, 1, "::")
      org_MD5.s = StringField(Line.s, 2, "::")   
      
      StatusBarText(0, 0, Filename.s)
      MD5.s = MD5OfFile(Fit(path.s)+ Filename.s)
      
      If MD5.s <> org_MD5.s
        LogOut("MD5 CHANGE:" + Fit(path.s)+ Filename.s + " has changed ( new: " + MD5 + " old: " +  org_MD5.s+" )")  
      Else
        LogOut("OK: " + Fit(path.s)+ Filename.s + "  ( MD5: " + MD5 + " )")
      EndIf  
      
    Until Eof(#FILE_MD5_GENERATED_LIST)
    CloseFile(#FILE_MD5_GENERATED_LIST)
  Else
    LogOut("ERROR: failed to open file: '" + Fit(path) + #INDEX_FILENAME + "'")    
  EndIf  
EndProcedure  



OpenWindow(0, 0, 0, #WINDOW_WIDTH, #WINDOW_HEIGHT, "MD5 File check", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget)

PanelGadget (0, 8, 8, #WINDOW_WIDTH-16, 100)
AddGadgetItem (0, -1, "Test MD5's")

SelectFileGadget(#GADGET_STRING_CHECK, 5,5,#WINDOW_WIDTH - 16 - 20,"Select folder to check (including sub folders). The file '"+#INDEX_FILENAME+"' must already exist.", "")
ButtonGadget(#GADGET_BUTTON_CHECK_LIST, 5, 50, 100,21, "Start")

AddGadgetItem (0, -1,"Generate MD5's")
SelectFileGadget(#GADGET_STRING_GENERATE,5,5,#WINDOW_WIDTH - 16 - 20,"Select a folder to generate a MD5 list (including sub folders). The file '"+#INDEX_FILENAME+"' will be created automatically in this directory.", "")
ButtonGadget(#GADGET_BUTTON_GENERATE_LIST, 5, 50, 100,21, "Start")

CloseGadgetList()

ListIconGadget(#GADGET_LOG, 5, 120, #WINDOW_WIDTH-10, 450, "Log", 6000, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)

ButtonGadget(#GADGET_BUTTON_SAVE_TO_FILE, 5, 120+450+5, 100,21, "Save Log")



If CreateStatusBar(0, WindowID(0))
  AddStatusBarField(#WINDOW_WIDTH-50)
  AddStatusBarField(50)
  
EndIf

Repeat
  
  event = WaitWindowEvent()
  ProcessDialog(event)
  
  If event = #PB_Event_Gadget
    
    
    If EventGadget() = #GADGET_BUTTON_SAVE_TO_FILE
      Pattern$ = "Text (*.txt)|*.txt|All files (*.*)|*.*"
      Pattern = 0 
      File$ = SaveFileRequester("Please choose file to save", "log.txt", Pattern$, Pattern)
      If File$
        If CreateFile(#FILE_LOG, File$) And FileSize(File$) <= 0
          For i = 0 To CountGadgetItems(#GADGET_LOG)-1
            WriteStringN(#FILE_LOG, GetGadgetItemText(#GADGET_LOG,i), #PB_UTF8) 
          Next  
          CloseFile(#FILE_LOG)
        Else
          MessageRequester("Error","Cannot create or overwrite file '"+File$+"'")
        EndIf
      EndIf      
    EndIf  
    
    If EventGadget() = #GADGET_BUTTON_CHECK_LIST
      DisableGadget(#GADGET_BUTTON_GENERATE_LIST, #True)
      DisableGadget(#GADGET_BUTTON_CHECK_LIST, #True)      
            
      If GetGadgetText(#GADGET_STRING_CHECK) <> ""
        If FileSize(GetGadgetText(#GADGET_STRING_CHECK)+ #INDEX_FILENAME) > 0
          ClearGadgetItems(#GADGET_LOG)
          check_md5_of_folder(GetGadgetText(#GADGET_STRING_CHECK))
          StatusBarProgress(0, 1, 0,#PB_StatusBar_Raised ,0,100)          
          LogOut("Done")
        Else
          MessageRequester("Error", "Cannot find file '"+#INDEX_FILENAME+"'!")
        EndIf  
      Else
        MessageRequester("Error","Please select a folder!")
      EndIf  
      DisableGadget(#GADGET_BUTTON_GENERATE_LIST, #False)
      DisableGadget(#GADGET_BUTTON_CHECK_LIST, #False)        
    EndIf
    
    If EventGadget() = #GADGET_BUTTON_GENERATE_LIST
      DisableGadget(#GADGET_BUTTON_GENERATE_LIST, #True)
      DisableGadget(#GADGET_BUTTON_CHECK_LIST, #True)      
      
      If GetGadgetText(#GADGET_STRING_GENERATE) <> ""
        If FileSize(GetGadgetText(#GADGET_STRING_GENERATE)+ #INDEX_FILENAME) > 0
          MessageRequester("Error","The file '" + #INDEX_FILENAME +"' is already existing! Please delete it first.")            
        Else            
          If CreateFile(#FILE_MD5_GENERATED_LIST, GetGadgetText(#GADGET_STRING_GENERATE) + #INDEX_FILENAME)
            ClearGadgetItems(#GADGET_LOG)
            generate_md5_for_folder(GetGadgetText(#GADGET_STRING_GENERATE),"")
            CloseFile(#FILE_MD5_GENERATED_LIST)
            StatusBarProgress(0, 1, 0,#PB_StatusBar_Raised ,0,100)
            LogOut("Done")
          Else           
            MessageRequester("Error", "Cannot create file: '" + GetGadgetText(#GADGET_STRING_GENERATE) + #INDEX_FILENAME+"'")
          EndIf
        EndIf  
      Else
        MessageRequester("Error","Please select a folder!")
      EndIf 
      DisableGadget(#GADGET_BUTTON_GENERATE_LIST, #False)
      DisableGadget(#GADGET_BUTTON_CHECK_LIST, #False)      
    EndIf
    
  EndIf  
  
Until event = #PB_Event_CloseWindow

EndApp()

; IDE Options = PureBasic 5.10 (Windows - x86)
; CursorPosition = 55
; FirstLine = 10
; Folding = --
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; Executable = MD5Checker.exe