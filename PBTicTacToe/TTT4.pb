Procedure Error()
MessageRequester("Fehler","")
End
EndProcedure


Text$="PB Tic Tac Toe"  +Chr(10)+Chr(13)
Text$+LSet("",12,Chr(175)) +Chr(10) +Chr(13)
Text$+"by"              +Chr(10) +Chr(13)
Text$+"Stefan Moebius" +Chr(10)+Chr(13)
Text$+""+Chr(10)+Chr(13)

Text$+"Kontakt:"+Chr(10)+Chr(13)
Text$+"Email: MoebiusStefan@AOL.COM"+Chr(10)+Chr(13)

Text$+""+Chr(10)+Chr(13)
Text$+"Dank an:"+Chr(10)+Chr(13)
Text$+"André Beer,Michael Moebius"+Chr(10)+Chr(13)
MessageRequester("Über",Text$,#MB_ICONINFORMATION)

Global Player
Global Win
Global CSet
Global O
Global X

Dim Feld(2,2)
Player=0
Win=0
CSet=0


Procedure Check4Winner()
Winner=0
;X
; X
;  X
If Feld(0,0)=Feld(1,1) And Feld(1,1)=Feld(2,2) And Feld(0,0)>0:Winner=Feld(0,0):EndIf
;If Feld(0,0)=1 And Feld(1,1)=1 And Feld(2,2)=1:Winner=1:EndIf
;If Feld(0,0)=2 And Feld(1,1)=2 And Feld(2,2)=2:Winner=2:EndIf

;XXX
;
;
If Feld(0,0)=Feld(1,0) And Feld(1,0)=Feld(2,0) And Feld(0,0)>0:Winner=Feld(0,0):EndIf
;If Feld(0,0)=1 And Feld(1,0)=1 And Feld(2,0)=1:Winner=1:EndIf
;If Feld(0,0)=2 And Feld(1,0)=2 And Feld(2,0)=2:Winner=2:EndIf

;
;XXX
;
If Feld(0,1)=Feld(1,1) And Feld(1,1)=Feld(2,1) And Feld(0,1)>0:Winner=Feld(0,1):EndIf
;If Feld(0,1)=1 And Feld(1,1)=1 And Feld(2,1)=1:Winner=1:EndIf
;If Feld(0,1)=2 And Feld(1,1)=2 And Feld(2,1)=2:Winner=2:EndIf

;
;
;XXX
If Feld(0,2)=Feld(1,2) And Feld(1,2)=Feld(2,2) And Feld(0,2)>0:Winner=Feld(0,2):EndIf
;If Feld(0,2)=1 And Feld(1,2)=1 And Feld(2,2)=1:Winner=1:EndIf
;If Feld(0,2)=2 And Feld(1,2)=2 And Feld(2,2)=2:Winner=2:EndIf

;  X
; X
;X
If Feld(2,0)=1 And Feld(1,1)=1 And Feld(0,2)=1:Winner=1:EndIf
If Feld(2,0)=2 And Feld(1,1)=2 And Feld(0,2)=2:Winner=2:EndIf

;X
;X
;X
If Feld(0,0)=1 And Feld(0,1)=1 And Feld(0,2)=1:Winner=1:EndIf
If Feld(0,0)=2 And Feld(0,1)=2 And Feld(0,2)=2:Winner=2:EndIf

; X
; X
; X
If Feld(1,0)=1 And Feld(1,1)=1 And Feld(1,2)=1:Winner=1:EndIf
If Feld(1,0)=2 And Feld(1,1)=2 And Feld(1,2)=2:Winner=2:EndIf

;  X
;  X
;  X
If Feld(2,0)=1 And Feld(2,1)=1 And Feld(2,2)=1:Winner=1:EndIf
If Feld(2,0)=2 And Feld(2,1)=2 And Feld(2,2)=2:Winner=2:EndIf
ProcedureReturn Winner
EndProcedure

Procedure Computer(X1,Y1,X2,Y2,SX,SY,Pl)
If Feld(X1,Y1)=Pl And Feld(X2,Y2)=Pl And Feld(SX,SY)=0 And CSet
CSet=0
Feld(SX,SY)=2
SetGadgetState(SX+SY*3,O)
EndIf
EndProcedure




hWnd=OpenWindow(1,0,0,155,75,#PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered,"PB Tic Tac Toe")
If hWnd=0:End:EndIf 



Icon.ICONINFO
Icon\fIcon=-1
Icon\xHotspot=0
Icon\yHotspot=0
Icon\hbmMask=CatchImage(0,?LogoMask)
Icon\hbmColor=CatchImage(1,?Logo)
Logo=CreateIconIndirect_(Icon)
If Logo=0:End:EndIf

Icon\hbmMask=CatchImage(2,?XMask)
Icon\hbmColor=CatchImage(3,?X)
X=CreateIconIndirect_(Icon)
If X=0:End:EndIf

Icon\hbmMask=CatchImage(4,?OMask)
Icon\hbmColor=CatchImage(5,?O)
O=CreateIconIndirect_(Icon)
If O=0:End:EndIf

CreateGadgetList(hWnd)
ButtonImageGadget(0, 0, 0,20,20,0)
ButtonImageGadget(1,20, 0,20,20,0)
ButtonImageGadget(2,40, 0,20,20,0)
ButtonImageGadget(3, 0,20,20,20,0)
ButtonImageGadget(4,20,20,20,20,0)
ButtonImageGadget(5,40,20,20,20,0)
ButtonImageGadget(6, 0,40,20,20,0)
ButtonImageGadget(7,20,40,20,20,0)
ButtonImageGadget(8,40,40,20,20,0)
ButtonGadget(9,90,55,65,18,"&Beenden")
ImageGadget(10,80, 0,75,45,Logo)

Quit=0
Repeat

Event=WindowEvent()

If Event=#PB_Event_Gadget
ID=EventGadgetID()
If ID>=0 And ID<=8 And Feld(ID%3,ID/3)=0 And Player=0 And Win=0
Player=~Player
Feld(ID%3,ID/3)=1
SetGadgetState(ID,X)
EndIf

If ID=9:Quit=1:EndIf
EndIf

Win=Check4Winner()

If Player<>0 And Win=0
CSet=1:Player=~Player


Computer(0,0,1,0,2,0,2);XXO
Computer(0,1,1,1,2,1,2);XXO
Computer(0,2,1,2,2,2,2);XXO

Computer(1,0,2,0,0,0,2);OXX
Computer(1,1,2,1,0,1,2);OXX
Computer(1,2,2,2,0,2,2);OXX

Computer(0,0,2,0,1,0,2);XOX
Computer(0,1,2,1,1,1,2);XOX
Computer(0,2,2,2,1,2,2);XOX

Computer(0,0,0,1,0,2,2)
Computer(1,0,1,1,1,2,2)
Computer(2,0,2,1,2,2,2)

Computer(0,0,0,2,0,1,2)
Computer(1,0,1,2,1,1,2)
Computer(2,0,2,2,2,1,2)

Computer(0,1,0,2,0,0,2)
Computer(1,1,1,2,1,0,2)
Computer(2,1,2,2,2,0,2)

Computer(0,0,1,1,2,2,2)
Computer(0,0,2,2,1,1,2)
Computer(1,1,2,2,0,0,2)

Computer(2,0,1,1,0,2,2)
Computer(0,2,1,1,2,0,2)
Computer(2,0,0,2,1,1,2)




Computer(0,0,1,0,2,0,1);XXO
Computer(0,1,1,1,2,1,1);XXO
Computer(0,2,1,2,2,2,1);XXO

Computer(1,0,2,0,0,0,1);OXX
Computer(1,1,2,1,0,1,1);OXX
Computer(1,2,2,2,0,2,1);OXX

Computer(0,0,2,0,1,0,1);XOX
Computer(0,1,2,1,1,1,1);XOX
Computer(0,2,2,2,1,2,1);XOX

Computer(0,0,0,1,0,2,1)
Computer(1,0,1,1,1,2,1)
Computer(2,0,2,1,2,2,1)

Computer(0,0,0,2,0,1,1)
Computer(1,0,1,2,1,1,1)
Computer(2,0,2,2,2,1,1)

Computer(0,1,0,2,0,0,1)
Computer(1,1,1,2,1,0,1)
Computer(2,1,2,2,2,0,1)

Computer(0,0,1,1,2,2,1)
Computer(0,0,2,2,1,1,1)
Computer(1,1,2,2,0,0,1)

Computer(2,0,1,1,0,2,1)
Computer(0,2,1,1,2,0,1)
Computer(2,0,0,2,1,1,1)


;Extra
Computer(0,1,2,0,0,0,1)
Computer(1,2,2,0,2,2,1)
Computer(0,0,1,2,0,2,1)
Computer(0,2,2,1,2,2,1)

Computer(1,1,2,2,0,2,1)

Computer(1,2,2,1,2,2,1)

;Computer(0,2,2,0,2,2,1)
;Computer()

If Feld(1,1)=0:Feld(1,1)=2:SetGadgetState(4,O):CSet=0:EndIf

For Nr=0 To 8
If CSet And Feld(Nr%3,Nr/3)=0:Feld(Nr%3,Nr/3)=2:SetGadgetState(Nr,O):CSet=0:EndIf
Next

EndIf

Win=Check4Winner()


Count=0
For Nr=0 To 8
If Feld(Nr%3,Nr/3)=0:Count+1:EndIf
Next
If Count=0:Quit=1:EndIf


Until Event=#PB_Event_CloseWindow Or Quit Or Win>0

Select Win
Case 1
MessageRequester("WOW","Du hast gewonnen !")
Case 2
MessageRequester("","Du hast verloren !")
EndSelect


DestroyIcon_(X)
DestroyIcon_(O)
DestroyIcon_(Logo)
FreeImage(0)
FreeImage(1)
FreeImage(2)
FreeImage(3)
FreeImage(4)
FreeImage(5)



End
DataSection
Logo:
IncludeBinary "Logo.bmp"
LogoMask:
IncludeBinary "LogoMask.bmp"
O:
IncludeBinary "O.bmp"
OMask:
IncludeBinary "OMask.bmp"
X:
IncludeBinary "X.bmp"
XMask:
IncludeBinary "XMask.bmp"
EndDataSection

; ExecutableFormat=Windows
; Executable=C:\CDROM\6\PBTicTacToe.exe
; DisableDebugger
; EOF