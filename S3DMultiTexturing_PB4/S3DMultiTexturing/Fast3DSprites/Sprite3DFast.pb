IncludeFile "Sprite3DFast_inc.pbi"


InitSprite()
InitSprite3D()


OpenWindow(1,0,0,640,480,"Fast 3D-Sprites",#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget|#PB_Window_SystemMenu)
OpenWindowedScreen(WindowID(1),0,0,640,480,0,0,0)

CreateSprite(1,16,16,#PB_Sprite_Texture)

StartDrawing(SpriteOutput(1))
Box(0,0,64,64,#Green)
StopDrawing()




Start3D()
result=S3D_InitS3DFast()
If result:Stop3D():CloseScreen():MessageRequester("ERROR","Can't render with current blending operations!"):End:EndIf
  
Stop3D()
CreateSprite3D(1,1)


Repeat
  
  ClearScreen(0)
  
  
  
  Start=GetTickCount_()
  Start3D()
  S3D_StartFast()
  For c=0 To 500000
    S3D_DisplaySprite3DFast(1,Random(640),Random(480),5)
  Next
  S3D_StopFast()
  Stop3D() ; Make sure, that everything has been rendered.
  NeededTime=GetTickCount_()-Start
  
  
  Start=GetTickCount_()
  Start3D()
  For c=0 To 500000
    DisplaySprite3D(1,Random(640),Random(480),5)
  Next
  Stop3D() ; Make sure, that everything has been rendered.
  NeededTime2=GetTickCount_()-Start
  
  
  StartDrawing(ScreenOutput())
  DrawingMode(1)

  DrawText(0,5,"S3D_DisplaySprite3DFast(): "+Str(NeededTime)+" ms")
  DrawText(0,20,"DisplaySprite3D(): "+Str(NeededTime2)+" ms")
  StopDrawing()
  
  FlipBuffers()
  
Until WindowEvent()=#PB_Event_CloseWindow

S3D_EndS3DFast()
; IDE Options = PureBasic v4.02 (Windows - x86)
; CursorPosition = 58
; FirstLine = 37
; Folding = -
; DisableDebugger