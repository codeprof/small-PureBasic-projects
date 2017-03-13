
Dim file.s(3000)

  If OpenWindow(0, 0, 0, 420, 100, "Media-Combiner", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ButtonGadget(0, 10, 10, 200, 80, "Transport Stream")
    ButtonGadget(1, 210, 10, 200, 80, "MPEG")
    Repeat 
    ev = WaitWindowEvent()
    
    If ev=#PB_Event_Gadget
      If EventGadget()= 0
        name.s = "Transport Stream"
        ending.s = ".ts"
        ending2.s = ".ts"
        do = #True
      EndIf
      If EventGadget()= 1
        name.s = "MPEG video"
        ending.s = ".mpg;*.mpeg"
        ending2.s = ".mpg"
        do=#True
      EndIf
      
    EndIf   
    
    If ev = #PB_Event_CloseWindow
      End
    EndIf   
        
    Until do
    CloseWindow(0)
  EndIf
  
  do=0

  If OpenWindow(0, 0, 0, 422, 200, name+"-Combiner", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ButtonGadget(0, 10, 10, 100, 20, "Add...")
    ButtonGadget(1, 110, 10, 100, 20, "Create")
    ListViewGadget(2,10,30,400,170)
    Repeat 
    ev = WaitWindowEvent()
    
    If ev=#PB_Event_Gadget
      If EventGadget()= 0

        File$ = OpenFileRequester("select file", "", name.s+" (*"+ending+")|*"+ending+"|Alle Dateien (*.*)|*.*",0)
        If FileSize(File$) > 0
          AddGadgetItem(2,-1,GetFilePart(File$))
          file(index)= File$
          index +1
        EndIf
        
      EndIf
      If EventGadget()= 1
      
        File$ = SaveFileRequester("save file", "", name.s+" (*"+ending+")|*"+ending+"|Alle Dateien (*.*)|*.*",0)
  
        If GetExtensionPart(File$) ="":File$ + ending2:EndIf
        
        If FileSize(File$) < 0      
        If CreateFile(1,File$)
          do=#True
        EndIf
        Else
          MessageRequester("Error","File already exists!")   
        EndIf
      EndIf    
      
    EndIf   
    
    If ev = #PB_Event_CloseWindow
      End
    EndIf   
        
    Until do
  EndIf

*buffer=AllocateMemory($FFFFF+1024)

For i=0 To index-1
If ReadFile(2,file(i))=0
MessageRequester("Error", "Cannot open file "+file(i))
End
EndIf


ges.q = Lof(2)
Repeat

If ges => $FFFF
  ReadData(2,*buffer,$FFFF) 
  WriteData(1,*buffer,$FFFF)
  ges - $FFFF
Else

  ReadData(2,*buffer,ges)
  WriteData(1,*buffer,ges)
  ges=0
EndIf

Repeat
ev = WindowEvent()
If ev=#PB_Event_CloseWindow
End
EndIf
Until ev=0
counter + 1
If counter > 20
counter = 0
counter2 + 1
counter2 % 4
SetWindowTitle(0, "Please wait" + LSet("",counter2,"."))
EndIf

Until ges = 0

CloseFile(2)
Next

CloseFile(1)

; IDE Options = PureBasic 4.60 Beta 2 (Windows - x86)
; CursorPosition = 92
; FirstLine = 68
; EnableXP
; Executable = Media-Combiner.exe