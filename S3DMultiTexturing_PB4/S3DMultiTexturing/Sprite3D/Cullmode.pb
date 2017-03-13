
#D3DRENDERSTATE_CULLMODE=22

#D3DCULL_NONE=1 
#D3DCULL_CW=2 
#D3DCULL_CCW=3 ; default
    

Procedure Sprite3DGetD3DDevice()
!extrn _PB_Direct3D_Device 
!MOV Eax,[_PB_Direct3D_Device] 
ProcedureReturn
EndProcedure

Procedure Sprite3DSetCullmode(mode)
*D3DDevice.IDirect3DDevice7=Sprite3DGetD3DDevice()
If *D3DDevice
ProcedureReturn *D3DDevice\SetRenderState(#D3DRENDERSTATE_CULLMODE,mode)
EndIf
ProcedureReturn -1
EndProcedure 


InitSprite()
InitSprite3D()
InitKeyboard()

#flags=#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget

OpenWindow(1,0,0,400,300,"Change cullmode",#flags)
OpenWindowedScreen(WindowID(1),0,0,400,300,1,0,0)

LoadSprite(1,"TEST.bmp",#PB_Sprite_Texture)
CreateSprite3D(1,1)

Repeat 

ClearScreen(0)

  Start3D()
  
  Select Cullmode
  Case 0
  Sprite3DSetCullmode(#D3DCULL_NONE) ; alles zeichnen
  Case 1
  Sprite3DSetCullmode(#D3DCULL_CCW) ; nur Vierecke zeichnen, deren Eckpunkte im Uhrzeigersinn angeordnet sind
  EndSelect
  
  TransformSprite3D(1,0,0,100,0,100,100,0,100)
  DisplaySprite3D(1,0,50)
  
  TransformSprite3D(1,0,100,100,100,100,0,0,0)
  DisplaySprite3D(1,200,50)
  
  Stop3D()
  
  StartDrawing(ScreenOutput())
  Select Cullmode
  Case 0
  DrawText(0,0,"Cullmode:None  (change with F1)")
  Case 1
  DrawText(0,0,"Cullmode:Counter clockwise  (change with F1)")
  EndSelect
  StopDrawing()
  
  Delay(16)
  FlipBuffers()
  
  ExamineKeyboard()
  
  If KeyboardReleased(#PB_Key_F1):Cullmode=(Cullmode+1)%2:EndIf
  
Until WindowEvent()=#PB_Event_CloseWindow








; IDE Options = PureBasic v4.02 (Windows - x86)
; CursorPosition = 61
; FirstLine = 53
; Folding = -
; DisableDebugger