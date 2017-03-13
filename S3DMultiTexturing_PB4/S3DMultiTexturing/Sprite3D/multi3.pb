
Procedure S3D_GetD3DDevice()
!extrn _PB_Direct3D_Device
!MOV EAX,[_PB_Direct3D_Device]
ProcedureReturn
EndProcedure


Structure D3DTLVERTEX
  StructureUnion
    sx.f            ;X value of the vertex (in pixels)
    dvSX.f
  EndStructureUnion
  StructureUnion
    sy.f            ;Y value of the vertex (in pixels)
    dvSY.f
  EndStructureUnion
  StructureUnion
    sz.f
    dvSZ.f
  EndStructureUnion
  StructureUnion
    rhw.f
    dvRHW.f
  EndStructureUnion
  StructureUnion
    color.l
    dcColor.l
  EndStructureUnion
  StructureUnion
    specular.l
    dcSpecular.l
  EndStructureUnion
  StructureUnion
    tu.f            ;horizontal texture coordinate of the vertex 
    dvTU.f
  EndStructureUnion
  StructureUnion
    tv.f            ;vertical texture coordinate of the vertex 
    dvTV.f
  EndStructureUnion
EndStructure

Structure PB_Sprite3D
  Texture.IDirectDrawSurface7 ; DirectDrawSurface7
  Vertice.D3DTLVERTEX[4]       ; The 4 vertices for the rectangle sprite
  Width.w			 ; width set with ZoomSprite3D()
  Height.w			 ; height set with ZoomSprite3D()
  unknown.l
EndStructure


#D3DTOP_DISABLE=1
#D3DTOP_SELECTARG1=2
#D3DTOP_SELECTARG2=3
#D3DTOP_MODULATE=4
#D3DTOP_MODULATE2X=5
#D3DTOP_MODULATE4X=6
#D3DTOP_ADD=7
#D3DTOP_ADDSIGNED=8
#D3DTOP_ADDSIGNED2X=9
#D3DTOP_SUBTRACT=10
#D3DTOP_ADDSMOOTH=11
#D3DTOP_BLENDDIFFUSEALPHA=12
#D3DTOP_BLENDTEXTUREALPHA=13
#D3DTOP_BLENDFACTORALPHA=14
#D3DTOP_BLENDTEXTUREALPHAPM=15
#D3DTOP_BLENDCURRENTALPHA=16
#D3DTOP_PREMODULATE=17
#D3DTOP_MODULATEALPHA_ADDCOLOR=18
#D3DTOP_MODULATECOLOR_ADDALPHA=19
#D3DTOP_MODULATEINVALPHA_ADDCOLOR=20
#D3DTOP_MODULATEINVCOLOR_ADDALPHA=21
#D3DTOP_BUMPENVMAP=22
#D3DTOP_BUMPENVMAPLUMINANCE=23
#D3DTOP_DOTPRODUCT3=24

#D3DTSS_COLOROP=1
#D3DTSS_COLORARG1=2
#D3DTSS_COLORARG2=3
#D3DTSS_ALPHAOP=4
#D3DTSS_ALPHAARG1=5
#D3DTSS_ALPHAARG2=6
#D3DTSS_TEXCOORDINDEX=11
#D3DTSS_ADDRESS=12
#D3DTSS_ADDRESSU=13
#D3DTSS_ADDRESSV=14
#D3DTSS_BORDERCOLOR=15
#D3DTSS_MAGFILTER=16
#D3DTSS_MINFILTER=17
#D3DTSS_MIPFILTER=18
#D3DTSS_MAXMIPLEVEL=20
#D3DTSS_MAXANISOTROPY=21
#D3DTSS_TEXTURETRANSFORMFLAGS=24

#D3DTA_SELECTMASK=15
#D3DTA_DIFFUSE=0
#D3DTA_CURRENT=1
#D3DTA_TEXTURE=2
#D3DTA_TFACTOR=3
#D3DTA_COMPLEMENT=16
#D3DTA_ALPHAREPLICATE=32
#D3DTA_SPECULAR=4

#D3DFVF_XYZ=2
#D3DFVF_XYZRHW=4
#D3DFVF_XYZB1=6
#D3DFVF_XYZB2=8
#D3DFVF_XYZB3=10
#D3DFVF_XYZB4=12
#D3DFVF_XYZB5=14
#D3DFVF_NORMAL=16
#D3DFVF_DIFFUSE=64
#D3DFVF_SPECULAR=128
#D3DFVF_TEX0=0
#D3DFVF_TEX1=256
#D3DFVF_TEX2=512
#D3DFVF_TEX3=768
#D3DFVF_TEX4=1024
#D3DFVF_TEX5=1280
#D3DFVF_TEX6=1536
#D3DFVF_TEX7=1792
#D3DFVF_TEX8=2048
#D3DFVF_VERTEX=274
#D3DFVF_LVERTEX=482
#D3DFVF_TLVERTEX=452

#D3DSBT_ALL=1 
#D3DSBT_PIXELSTATE=2 
#D3DSBT_VERTEXSTATE=3

#D3DRENDERSTATE_TEXTUREFACTOR=60
#D3DPT_TRIANGLELIST=4

Global *IndexBuffer,StateBlock

Procedure Sprite3DInitMultitexturing()
  *Dev.IDirect3DDevice7=S3D_GetD3DDevice()
  *IndexBuffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,6*2)
  PokeW(*IndexBuffer,0)
  PokeW(*IndexBuffer+2,1)
  PokeW(*IndexBuffer+4,2)
  PokeW(*IndexBuffer+6,1)
  PokeW(*IndexBuffer+8,3)
  PokeW(*IndexBuffer+10,2)
  *Dev\CreateStateBlock(#D3DSBT_PIXELSTATE,@StateBlock)
EndProcedure

Procedure Sprite3DEndMultitexturing()
  *Dev.IDirect3DDevice7=S3D_GetD3DDevice()
  *Dev\DeleteStateBlock(StateBlock)
  GlobalFree_(*IndexBuffer)
EndProcedure

Procedure Sprite3DStartMultitexturing()
  *Dev.IDirect3DDevice7=S3D_GetD3DDevice()
  *Dev\CaptureStateBlock(StateBlock)
  
  *Dev\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_TEXTURE)
  *Dev\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  *Dev\SetTextureStageState(0,#D3DTSS_ALPHAARG1,#D3DTA_DIFFUSE)
  *Dev\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_BLENDDIFFUSEALPHA)
  
  *Dev\SetTextureStageState(1,#D3DTSS_COLORARG1,#D3DTA_TEXTURE)
  *Dev\SetTextureStageState(1,#D3DTSS_COLOROP,#D3DTOP_BLENDFACTORALPHA)
  *Dev\SetTextureStageState(1,#D3DTSS_ALPHAARG1,#D3DTA_DIFFUSE) 
  *Dev\SetTextureStageState(1,#D3DTSS_ALPHAOP,#D3DTOP_BLENDDIFFUSEALPHA)
  
  passes=2
  ProcedureReturn *Dev\ValidateDevice(@passes)  
EndProcedure

Procedure Sprite3DStopMultitexturing()
  *Dev.IDirect3DDevice7=S3D_GetD3DDevice()
  *Dev\ApplyStateBlock(StateBlock)
EndProcedure



Structure myFVF
  x1.f
  y1.f
  z1.f
  RHW1.f
  diffuse1.l
  Tu1.f
  Tv1.f
  Tu12.f
  Tv12.f
  
  x2.f
  y2.f
  z2.f
  RHW2.f
  diffuse2.l
  Tu2.f
  Tv2.f
  Tu22.f
  Tv22.f
  
  x3.f
  y3.f
  z3.f
  RHW3.f
  diffuse3.l
  Tu3.f
  Tv3.f
  Tu32.f
  Tv32.f
  
  x4.f
  y4.f
  z4.f
  RHW4.f
  diffuse4.l
  Tu4.f
  Tv4.f
  Tu42.f
  Tv42.f
EndStructure




Procedure DisplaySprite3DMultiTexture(Sprite3D,OffsetX,OffsetY,MultitextureSprite,BlendAlpha,Alpha)
  *Dev.IDirect3DDevice7=S3D_GetD3DDevice()
  *Sprite3D.PB_Sprite3D=IsSprite3D(Sprite3D)
  
  *Tex1.IDirectDrawSurface7=*Sprite3D\Texture
  *Tex2.IDirectDrawSurface7=PeekL(IsSprite(MultitextureSprite))
  
  Quad.myFVF
  Quad\x1=*Sprite3D\Vertice[0]\sx+OffsetX
  Quad\y1=*Sprite3D\Vertice[0]\sy+OffsetY
  Quad\z1=*Sprite3D\Vertice[0]\sz
  Quad\RHW1=*Sprite3D\Vertice[0]\rhw
  Quad\diffuse1=*Sprite3D\Vertice[0]\color&$FFFFFF+Alpha<<24
  Quad\Tv1=*Sprite3D\Vertice[0]\tu
  Quad\Tu1=*Sprite3D\Vertice[0]\tv
  Quad\Tv12=*Sprite3D\Vertice[0]\tu
  Quad\Tu12=*Sprite3D\Vertice[0]\tv
  
  Quad\x2=*Sprite3D\Vertice[1]\sx+OffsetX
  Quad\y2=*Sprite3D\Vertice[1]\sy+OffsetY
  Quad\z2=*Sprite3D\Vertice[1]\sz
  Quad\RHW2=*Sprite3D\Vertice[1]\rhw
  Quad\diffuse2=*Sprite3D\Vertice[1]\color&$FFFFFF+Alpha<<24
  Quad\Tv2=*Sprite3D\Vertice[2]\tu
  Quad\Tu2=*Sprite3D\Vertice[2]\tv
  Quad\Tv22=*Sprite3D\Vertice[2]\tu
  Quad\Tu22=*Sprite3D\Vertice[2]\tv
  
  Quad\x3=*Sprite3D\Vertice[2]\sx+OffsetX
  Quad\y3=*Sprite3D\Vertice[2]\sy+OffsetY
  Quad\z3=*Sprite3D\Vertice[2]\sz
  Quad\RHW3=*Sprite3D\Vertice[2]\rhw
  Quad\diffuse3=*Sprite3D\Vertice[2]\color&$FFFFFF+Alpha<<24
  Quad\Tv3=*Sprite3D\Vertice[1]\tu
  Quad\Tu3=*Sprite3D\Vertice[1]\tv
  Quad\Tv32=*Sprite3D\Vertice[1]\tu
  Quad\Tu32=*Sprite3D\Vertice[1]\tv
  
  Quad\x4=*Sprite3D\Vertice[3]\sx+OffsetX
  Quad\y4=*Sprite3D\Vertice[3]\sy+OffsetY
  Quad\z4=*Sprite3D\Vertice[3]\sz
  Quad\RHW4=*Sprite3D\Vertice[3]\rhw
  Quad\diffuse4=*Sprite3D\Vertice[3]\color&$FFFFFF+Alpha<<24
  Quad\Tv4=*Sprite3D\Vertice[3]\tu
  Quad\Tu4=*Sprite3D\Vertice[3]\tv
  Quad\Tv42=*Sprite3D\Vertice[3]\tu
  Quad\Tu42=*Sprite3D\Vertice[3]\tv
  
  *Dev\SetTexture(0,*Tex1)
  *Dev\SetTexture(1,*Tex2)
  *Dev\SetRenderState(#D3DRENDERSTATE_TEXTUREFACTOR,$FFFFFF+BlendAlpha<<24) 
  *Dev\DrawIndexedPrimitive(#D3DPT_TRIANGLELIST,#D3DFVF_XYZRHW|#D3DFVF_DIFFUSE|#D3DFVF_TEX2,Quad,4,*IndexBuffer,6,0) 
EndProcedure





InitSprite()
InitSprite3D()
InitKeyboard()


#flags=#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget

OpenWindow(1,0,0,1024,768,"DisplaySprite3DMultiTexture",#flags)
OpenWindowedScreen(WindowID(1),0,0,400,300,1,0,0)

SetFrameRate(60)

Start3D() ; D3DDevice wird erstellt
Sprite3DInitMultitexturing()
Stop3D()


LoadSprite(1,"1.bmp",#PB_Sprite_Texture)
LoadSprite(2,"2.bmp",#PB_Sprite_Texture)

CreateSprite3D(1,1)

Repeat
  
  ClearScreen(255)
  
  
  Start3D()
  
  result=Sprite3DStartMultitexturing() 
  If result:Stop3D():CloseScreen():MessageRequester("ERROR","Can't render with current blending operations!"):End:EndIf
  
  
  c+1
  Alpha=Abs(Sin(c/100))*255
  

  ZoomSprite3D(1,1024,768)
  DisplaySprite3DMultiTexture(1,0,0,2,Alpha,128)

  
  Sprite3DStopMultitexturing()
  
  ;DisplaySprite3D(1,100,100,Alpha) 
  Stop3D()
  
  
  FlipBuffers()
  
  
  ExamineKeyboard()
  WindowEvent()
Until KeyboardPushed(#PB_Key_Escape)

Sprite3DEndMultitexturing()

End
; IDE Options = PureBasic v4.02 (Windows - x86)
; CursorPosition = 333
; FirstLine = 311
; Folding = --