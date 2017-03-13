Structure DDPIXELFORMAT 
  dwSize.l 
  dwFlags.l 
  dwFourCC.l 
  dwRGBBitCount.l 
  dwRBitMask.l 
  dwGBitMask.l 
  dwBBitMask.l 
  dwRGBAlphaBitMask.l 
EndStructure 

Structure DDCOLORKEY 
  dwColorSpaceLowValue.l 
  dwColorSpaceHighValue.l 
EndStructure 

Structure DDSCAPS2 
  dwCaps.l 
  dwCaps2.l 
  dwCaps3.l 
  dwCaps4.l 
EndStructure 

Structure DDSURFACEDESC2 
  dwSize.l 
  dwFlags.l 
  dwHeight.l 
  dwWidth.l 
  lPitch.l 
  dwBackBufferCount.l 
  dwRefreshRate.l 
  dwAlphaBitDepth.l 
  dwReserved.l 
  lpSurface.l 
  ddckCKDestOverlay.DDCOLORKEY 
  ddckCKDestBlt.DDCOLORKEY 
  ddckCKSrcOverlay.DDCOLORKEY 
  ddckCKSrcBlt.DDCOLORKEY 
  ddpfPixelFormat.DDPIXELFORMAT 
  ddsCaps.DDSCAPS2 
  dwTextureStage.l 
EndStructure 

Structure D3DTLVERTEX 
  sx.f 
  sy.f 
  sz.f 
  rhw.f 
  color.l 
  specular.l 
  tu.f 
  tv.f 
EndStructure 

Structure PB_Sprite3D 
  Texture.IDirectDrawSurface7 ; DirectDrawSurface7 
  Vertice.D3DTLVERTEX[4]      ; The 4 vertices for the rectangle sprite 
  Width.w          ; width set with ZoomSprite3D() 
  Height.w       ; height set with ZoomSprite3D() 
  unknown.l 
EndStructure 




Procedure ClipSprite3D(Sprite3D,ClipX,ClipY,ClipWidth,ClipHeight) 
  *Sprite3D.PB_Sprite3D=IsSprite3D(Sprite3D) 
  
  If *Sprite3D=0:ProcedureReturn 0:EndIf 
  *DDS.IDirectDrawSurface7=*Sprite3D\Texture 
  
  DDSDESC.DDSURFACEDESC2 
  DDSDESC\dwSize=SizeOf(DDSURFACEDESC2) 
  Result=*DDS\GetSurfaceDesc(DDSDESC) 
  If Result:ProcedureReturn 0:EndIf 
  
  *Sprite3D\Vertice[0]\tu=ClipX/DDSDESC\dwWidth 
  *Sprite3D\Vertice[0]\tv=ClipY/DDSDESC\dwHeight 
  
  *Sprite3D\Vertice[1]\tu=(ClipX+ClipWidth)/DDSDESC\dwWidth 
  *Sprite3D\Vertice[1]\tv=ClipY/DDSDESC\dwHeight 
  
  *Sprite3D\Vertice[2]\tu=ClipX/DDSDESC\dwWidth 
  *Sprite3D\Vertice[2]\tv=(ClipY+ClipHeight)/DDSDESC\dwHeight 
  
  *Sprite3D\Vertice[3]\tu=(ClipX+ClipWidth)/DDSDESC\dwWidth 
  *Sprite3D\Vertice[3]\tv=(ClipY+ClipHeight)/DDSDESC\dwHeight 
  
  ProcedureReturn 1 ; return success 
EndProcedure 




;Example: 
InitSprite() 
InitSprite3D() 
InitKeyboard() 

SetRefreshRate(60)
OpenWindow(1,0,0,1024,768,"Clip sprite3D")
OpenWindowedScreen(WindowID(1),0,0,1024,768,0,0,0) 

LoadSprite(1,"tree.bmp",#PB_Sprite_Texture)

CreateSprite3D(1,1) 


ClipSprite3D(1,25,25,50,50) 
ZoomSprite3D(1,400,400)

Repeat 
  
  ClearScreen(0) 
  
  Start3D() 
  Sprite3DQuality(1)
  
  RotateSprite3D(1,1,1) 
  DisplaySprite3D(1,200,200) 
  Stop3D() 
  
  FlipBuffers() 
  
  ExamineKeyboard() 
  WindowEvent()
Until KeyboardPushed(#PB_Key_Escape) 

; IDE Options = PureBasic v4.02 (Windows - x86)
; CursorPosition = 125
; FirstLine = 100
; Folding = -