InitSprite()
InitKeyboard()
InitMouse()
InitSound()

OpenWindow(1,0,0,640,480,1,"GAME")
OpenWindowedScreen(WindowID(),0,0,640,480,0,0,0)

LoadSound(1,"daten\1.wav") 

LoadSprite(0,"daten\1.bmp")
LoadSprite(1,"daten\2.bmp")
LoadSprite(2,"daten\3.bmp")
LoadSprite(100,"daten\4.bmp")
LoadSprite(101,"daten\5.bmp")
LoadSprite(102,"daten\6.bmp")
LoadSprite(103,"daten\7.bmp")
LoadSprite(104,"daten\8.bmp")
LoadSprite(105,"daten\9.bmp")
LoadSprite(106,"daten\10.bmp")
LoadSprite(107,"daten\11.bmp")
LoadSprite(108,"daten\12.bmp")

LoadSprite(3,"daten\13.bmp")
LoadSprite(4,"daten\14.bmp")

LoadSprite(5,"daten\15.bmp")
LoadSprite(6,"daten\16.bmp")

LoadSprite(7,"daten\17.bmp")
LoadSprite(8,"daten\18.bmp")
TransparentSpriteColor(0,255,0,255)
TransparentSpriteColor(2,255,0,255)
TransparentSpriteColor(100,255,0,255)
TransparentSpriteColor(101,255,0,255)
TransparentSpriteColor(102,255,0,255)

TransparentSpriteColor(104,0,255,0)
TransparentSpriteColor(105,0,255,0)
TransparentSpriteColor(106,0,255,0)
TransparentSpriteColor(107,0,255,0)
TransparentSpriteColor(108,0,255,0)


TransparentSpriteColor(3,0,255,0)
TransparentSpriteColor(4,0,255,0)

TransparentSpriteColor(5,0,255,0)
TransparentSpriteColor(6,0,255,0)
TransparentSpriteColor(7,0,255,0)
TransparentSpriteColor(8,0,255,0)


LoadFont(1,"Arial",24)

Structure PIG
Use.l
X.l
Y.l
DirX.l
DirY.l
State.l
Typ.l
Z.l
EndStructure




Dim Pigs.PIG(1000)


For M=0 To 1000
Pigs(M)\Use=1

Pigs(M)\Typ=Random(5)+3

If Pigs(M)\Typ=3
Pigs(M)\Y=Random(1000)-Random(1000)
Pigs(M)\X=-Random(95000)
Pigs(M)\DirY=Random(1)-Random(1)
Pigs(M)\DirX=Random(1)+1
Pigs(M)\Z=1
EndIf

If Pigs(M)\Typ=4
Pigs(M)\Y=Random(1000)-Random(1000)
Pigs(M)\X=Random(95000)
Pigs(M)\DirY=Random(1)-Random(1)
Pigs(M)\DirX=-Random(1)-1
Pigs(M)\Z=1
EndIf

If Pigs(M)\Typ=5
Pigs(M)\Y=Random(1000)-Random(1000)
Pigs(M)\X=-Random(95000)
Pigs(M)\DirY=0
Pigs(M)\DirX=Random(1)+8
Pigs(M)\Z=1
EndIf

If Pigs(M)\Typ=6
Pigs(M)\Y=Random(1000)-Random(1000)
Pigs(M)\X=Random(95000)
Pigs(M)\DirY=0
Pigs(M)\DirX=-Random(1)-8
Pigs(M)\Z=1
EndIf

If Pigs(M)\Typ=7
Pigs(M)\Y=Random(1000)-Random(1000)
Pigs(M)\X=Random(95000)
Pigs(M)\DirY=0
Pigs(M)\DirX=1
Pigs(M)\Z=5
EndIf

If Pigs(M)\Typ=8
Pigs(M)\Y=Random(1000)-Random(1000)
Pigs(M)\X=Random(95000)
Pigs(M)\DirY=0
Pigs(M)\DirX=-1
Pigs(M)\Z=5
EndIf


Next


X=500
MouseLocate(320/1.5,240/1.5)
Gun=5
EGun=0
Start=GetTickCount_()

Repeat


ExamineMouse()
MouseX=MouseX()*1.5-16
MouseY=MouseY()*1.5-16

If MouseX>640:MouseLocate(640/1.5,MouseY()):MouseX=640:EndIf
If MouseY>480:MouseLocate(MouseX(),480/1.5):MouseY=480:EndIf

ExamineKeyboard()
Event=WindowEvent()

DisplaySprite(1,-X/8,0)
If smPigDead=0:DisplayTransparentSprite(108,(-X)/8+100,225):EndIf


For M=0 To 1000
If Pigs(M)\Use And Pigs(M)\Z=5
DisplayTransparentSprite(Pigs(M)\Typ,Pigs(M)\X-X,Pigs(M)\Y)
Pigs(M)\X+Pigs(M)\DirX
Pigs(M)\Y+Pigs(M)\DirY
EndIf

Next

For M=0 To 1000
If Pigs(M)\Use And Pigs(M)\Z=1
DisplayTransparentSprite(Pigs(M)\Typ,Pigs(M)\X-X,Pigs(M)\Y)
Pigs(M)\X+Pigs(M)\DirX
Pigs(M)\Y+Pigs(M)\DirY
EndIf
Next


DisplayTransparentSprite(2,-X,245)

DisplayTransparentSprite(102,-X+1700,200)
If BigPigDead=0
DisplayTransparentSprite(104,-X+1500,200)
Else
DisplayTransparentSprite(105,-X+1500,200)
EndIf
DisplayTransparentSprite(106,-X+300,300)
DisplayTransparentSprite(107,-X+1900,420)


StartDrawing(ScreenOutput())
DrawingMode(1)
DrawingFont(FontID())
Locate(0,0)
FrontColor(255,128,0)
If Points<0:Points=0:EndIf
DrawText("Punkte: "+Str(Points))
Locate(0,30)
FrontColor(0,0,128)
Min=(120000-(GetTickCount_()-Start))/60000
Sec=((120000-(GetTickCount_()-Start))-Min*60000)/1000
Min$=Str(Min)
Sec$=Str(Sec)
If Sec<10:Sec$="0"+Sec$:EndIf
DrawText("Zeit: "+Min$+":"+Sec$)

StopDrawing()


Pause+1
Bed=0
If EGun<>2
If MouseButton(1)=1 And OldMouseState=0 And Gun:Bed=1:EndIf
Else
If MouseButton(1)=1 And Pause>5 And Gun:Bed=1:Pause=0:EndIf
EndIf



If Bed
Gun-1:PlaySound(1)
Hit=0

If SpritePixelCollision(108,(-X)/8+100,225,103,MouseX+16,MouseY+16) And smPigDead=0
smPigDead=1
Points+100
Hit=1
EndIf


If SpritePixelCollision(104,-X+1500,200,103,MouseX+16,MouseY+16) And BigPigDead=0
BigPigDead=1
Points+85
Hit=1
EndIf

If SpritePixelCollision(106,-X+300,300,103,MouseX+16,MouseY+16)
EGun=1
Hit=1
If Gun>8:Gun=8:EndIf
EndIf


If SpritePixelCollision(107,-X+1900,420,103,MouseX+16,MouseY+16) And EGun=1
EGun=2
Hit=1
EndIf


If SpritePixelCollision(102,-X+1700,200,103,MouseX+16,MouseY+16)
Points-5
Hit=1
EndIf

If Hit=0
If SpritePixelCollision(2,-X,245,103,MouseX+16,MouseY+16)=0

For M=0 To 1000
If Pigs(M)\Z=5 And Hit=0
If SpritePixelCollision(Pigs(M)\Typ,Pigs(M)\X-X,Pigs(M)\Y,103,MouseX+16,MouseY+16)
A.f=Abs(Pigs(M)\DirX*Pigs(M)\Z)
Points+A
Pigs(M)\DirY+8
Pigs(M)\DirX=0
Hit=1
EndIf
EndIf

If Pigs(M)\Z=1 And Hit=0
If SpritePixelCollision(Pigs(M)\Typ,Pigs(M)\X-X,Pigs(M)\Y,103,MouseX+16,MouseY+16)
A.f=Abs(Pigs(M)\DirX*Pigs(M)\Z)
Points+A
Pigs(M)\DirY+8
Pigs(M)\DirX=0
Hit=1
EndIf
EndIf
Next


EndIf
EndIf




EndIf


OldMouseState=MouseButton(1)

If EGun=0
If MouseButton(2)=1 And OldMouseState=0 And Gun<5:Gun=5:Points-5:EndIf
OldMouseState2=MouseButton(2)
EndIf

If EGun=1
If MouseButton(2)=1 And OldMouseState=0 And Gun<8:Gun=8:Points-6:EndIf
OldMouseState2=MouseButton(2)
EndIf

If EGun=2
If MouseButton(2)=1 And OldMouseState=0 And Gun<32:Gun=32:Points-6:EndIf
OldMouseState2=MouseButton(2)
EndIf



If EGun=0
For M=0 To Gun
DisplayTransparentSprite(100,640-M*20,400)
Next
Else
For M=0 To Gun
DisplayTransparentSprite(101,640-M*20,400)
Next
EndIf


DisplayTransparentSprite(0,MouseX,MouseY)
FlipBuffers()

If KeyboardPushed(#PB_KEY_LEFT):X-5:EndIf
If KeyboardPushed(#PB_KEY_RIGHT):X+5:EndIf

If MouseX>608:X+5:EndIf
If MouseX<1:X-5:EndIf

If X<0:X=0:EndIf
If X>1920-640:X=1920-640:EndIf


Until KeyboardPushed(#PB_KEY_ESCAPE) Or GetTickCount_()-Start>120000

MessageRequester("Punkte:",Str(Points))

; ExecutableFormat=Windows
; UseIcon=C:\CDROM\2\1.ico
; Executable=C:\CDROM\2\GAME3.exe
; DisableDebugger
; EOF