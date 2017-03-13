;Draw primitives with Direct3D7
;******************************

Structure MyVertices
  x1.f 
  y1.f 
  z1.f 
  rhw1.f
  diffuse1.l
  
  x2.f 
  y2.f 
  z2.f 
  rhw2.f
  diffuse2.l
  
  x3.f 
  y3.f 
  z3.f 
  rhw3.f
  diffuse3.l 
  
  x4.f 
  y4.f 
  z4.f 
  rhw4.f
  diffuse4.l     
EndStructure

#D3DCLEAR_TARGET=1

#D3DFVF_XYZRHW=4
#D3DFVF_DIFFUSE=64
#D3DFVF_SPECULAR=128

#D3DPT_POINTLIST=1
#D3DPT_LINELIST=2     
#D3DPT_TRIANGLELIST=4
#D3DPT_TRIANGLESTRIP=5

#D3DRENDERSTATE_CULLMODE=22
#D3DRENDERSTATE_DITHERENABLE=26
#D3DRENDERSTATE_SPECULARENABLE=29
#D3DRENDERSTATE_COLORKEYENABLE=41
#D3DRENDERSTATE_LIGHTING=137
#D3DCULL_NONE=1
#D3DCULL_CCW=3 
    
    
#D3DBLEND_ZERO=1
#D3DBLEND_ONE=2
    
#D3DBLEND_SRCCOLOR=3
#D3DBLEND_INVSRCCOLOR=4
  


Procedure Sprite3D_Start2DDrawing()
  Global Sprite3D_Points.MyVertices
  Global *D3DDevice.IDirect3DDevice7
  
  !extrn _PB_Direct3D_Device
  !MOV Eax,[_PB_Direct3D_Device]
  !MOV [p_D3DDevice],Eax
  
  Sprite3D_Points\rhw1=1.0
  Sprite3D_Points\rhw2=1.0
  Sprite3D_Points\rhw3=1.0
  Sprite3D_Points\rhw4=1.0
  
  *D3DDevice\SetRenderState(#D3DRENDERSTATE_COLORKEYENABLE,0) ; disable colorkey
  *D3DDevice\SetRenderState(#D3DRENDERSTATE_DITHERENABLE,1) ; enable dithering (improve the quality)
  *D3DDevice\SetRenderState(#D3DRENDERSTATE_CULLMODE,#D3DCULL_NONE); disable culling
  Sprite3DBlendingMode(#D3DBLEND_ONE,#D3DBLEND_ZERO)
EndProcedure



Procedure Sprite3D_Stop2DDrawing()
  *D3DDevice\SetRenderState(#D3DRENDERSTATE_COLORKEYENABLE,1);enable colorkey
  *D3DDevice\SetRenderState(#D3DRENDERSTATE_DITHERENABLE,0)
  *D3DDevice\SetRenderState(#D3DRENDERSTATE_CULLMODE,#D3DCULL_CCW)
  Sprite3DBlendingMode(#D3DBLEND_SRCCOLOR,#D3DBLEND_INVSRCCOLOR)
EndProcedure



Procedure Sprite3D_DrawLine2D(x1.f,y1.f,x2.f,y2.f,RGB1,RGB2)
  Sprite3D_Points\x1=x1
  Sprite3D_Points\y1=y1
  Sprite3D_Points\diffuse1=RGB1>>16+(RGB1&$FF00)+(RGB1&$FF)<<16 ;convert RGB to BGR
  Sprite3D_Points\x2=x2
  Sprite3D_Points\y2=y2
  Sprite3D_Points\diffuse2=RGB2>>16+(RGB2&$FF00)+(RGB2&$FF)<<16
  ProcedureReturn *D3DDevice\DrawPrimitive(#D3DPT_LINELIST,#D3DFVF_XYZRHW|#D3DFVF_DIFFUSE,@Sprite3D_Points,2,0)
EndProcedure



Procedure Sprite3D_ClearScreen(RGB)
  *D3DDevice\Clear(0,0,#D3DCLEAR_TARGET,RGB>>16+(RGB&$FF00)+(RGB&$FF)<<16,0,0)
EndProcedure



Procedure Sprite3D_DrawTriangle2D(x1.f,y1.f,x2.f,y2.f,x3.f,y3.f,RGB1,RGB2,RGB3)
  Sprite3D_Points\x1=x1
  Sprite3D_Points\y1=y1
  Sprite3D_Points\diffuse1=RGB1>>16+(RGB1&$FF00)+(RGB1&$FF)<<16
  Sprite3D_Points\x2=x2
  Sprite3D_Points\y2=y2
  Sprite3D_Points\diffuse2=RGB2>>16+(RGB2&$FF00)+(RGB2&$FF)<<16
  Sprite3D_Points\x3=x3
  Sprite3D_Points\y3=y3
  Sprite3D_Points\diffuse3=RGB3>>16+(RGB3&$FF00)+(RGB3&$FF)<<16 
  ProcedureReturn *D3DDevice\DrawPrimitive(#D3DPT_TRIANGLELIST,#D3DFVF_XYZRHW|#D3DFVF_DIFFUSE,@Sprite3D_Points,3,0)
EndProcedure



Procedure Sprite3D_DrawBox2D(X.f,Y.f,Width.f,Height.f,RGB1,RGB2,RGB3,RGB4)
  Sprite3D_Points\x1=X
  Sprite3D_Points\y1=Y
  Sprite3D_Points\diffuse1=RGB1>>16+(RGB1&$FF00)+(RGB1&$FF)<<16 
  Sprite3D_Points\x2=X+Width
  Sprite3D_Points\y2=Y
  Sprite3D_Points\diffuse2=RGB2>>16+(RGB2&$FF00)+(RGB2&$FF)<<16 
  Sprite3D_Points\x3=X
  Sprite3D_Points\y3=Y+Height
  Sprite3D_Points\diffuse3=RGB3>>16+(RGB3&$FF00)+(RGB3&$FF)<<16 
  Sprite3D_Points\x4=X+Width
  Sprite3D_Points\y4=Y+Height
  Sprite3D_Points\diffuse4=RGB4>>16+(RGB4&$FF00)+(RGB4&$FF)<<16 
  ProcedureReturn *D3DDevice\DrawPrimitive(#D3DPT_TRIANGLESTRIP,#D3DFVF_XYZRHW|#D3DFVF_DIFFUSE,@Sprite3D_Points,4,0)
EndProcedure



Procedure Sprite3D_DrawPixel2D(X.f,Y.f,RGB)
  Sprite3D_Points\x1=X
  Sprite3D_Points\y1=Y
  Sprite3D_Points\diffuse1=RGB>>16+(RGB&$FF00)+(RGB&$FF)<<16 
  ProcedureReturn *D3DDevice\DrawPrimitive(#D3DPT_POINTLIST,#D3DFVF_XYZRHW|#D3DFVF_DIFFUSE,@Sprite3D_Points,1,0)
EndProcedure





;example:

InitSprite()
InitSprite3D()

#flags=#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget

OpenWindow(1,0,0,400,300,"Direct3D 7 Primitives test",#flags)
OpenWindowedScreen(WindowID(1),0,0,400,300,1,0,0)

XPos=50:addX=1

Repeat
  
  
  Start3D()
  Sprite3D_Start2DDrawing()
  
  
  Sprite3D_ClearScreen(#Blue);clear the screen
  
  
  ;Draw a triangle
  Sprite3D_DrawTriangle2D(50,150,150,150,150,250,#Red,#Green,#Blue)
  
  
  ;Draw a few lines
  Sprite3D_DrawLine2D(200,200,300,300,#Black,#White)
  Sprite3D_DrawLine2D(300,300,400,200,#Black,#White)
  Sprite3D_DrawLine2D(400,200,300,100,#Black,#White)
  Sprite3D_DrawLine2D(300,100,200,200,#Black,#White)
  
  Sprite3D_DrawBox2D(100,25,250,50,#Magenta,#White,#Yellow,#Red)
  
  XPos+addX
  YPos+addY
  
  If XPos<=0:addX=1:EndIf
  If XPos>=300:addX=-1:EndIf
  
  If YPos<=0:addY=2:EndIf
  If YPos>=200:addY=-2:EndIf
  
  Sprite3D_DrawBox2D(XPos,YPos,100,100,#Black,#White,#Green,#Black)
  
  Sprite3D_Stop2DDrawing()
  Stop3D()
  
  Delay(16)
  FlipBuffers()
Until WindowEvent()=#PB_Event_CloseWindow








; IDE Options = PureBasic v4.02 (Windows - x86)
; CursorPosition = 198
; FirstLine = 180
; Folding = --
; DisableDebugger