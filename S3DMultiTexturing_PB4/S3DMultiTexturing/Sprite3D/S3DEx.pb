#D3DRENDERSTATE_CULLMODE=22  
#D3DRENDERSTATE_DITHERENABLE=26
#D3DRENDERSTATE_COLORKEYENABLE=41
#D3DRENDERSTATE_FILLMODE=8  
#D3DCLEAR_TARGET=1

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

Structure D3DVIEWPORT7
dwX.l
dwY.l
dwWidth.l
dwHeight.l
dvMinZ.f
dvMaxZ.f
EndStructure

Structure PB_Sprite3D
Texture.IDirectDrawSurface7 ; DirectDrawSurface7
Vertice.D3DTLVERTEX[4]      ; The 4 vertices for the rectangle sprite
Width.w			   ; width set with ZoomSprite3D()
Height.w			 ; height set with ZoomSprite3D()
unknown.l
EndStructure

Procedure S3D_GetD3DDevice()
!extrn _PB_Direct3D_Device
!MOV EAX,[_PB_Direct3D_Device]
ProcedureReturn
EndProcedure

Procedure S3D_GetSprite3DQuality()
!extrn _PB_Sprite3D_Quality
!MOV EAX,[_PB_Sprite3D_Quality]
ProcedureReturn
EndProcedure

Procedure S3D_UseDither(UseDither)
*Dev.IDirect3DDevice7=S3D_GetD3DDevice()
ProcedureReturn *Dev\SetRenderState(#D3DRENDERSTATE_DITHERENABLE,UseDither)
EndProcedure

Procedure S3D_UseTransparency(UseTransparency)
*Dev.IDirect3DDevice7=S3D_GetD3DDevice()
ProcedureReturn *Dev\SetRenderState(#D3DRENDERSTATE_COLORKEYENABLE,UseTransparency)
EndProcedure

;-Flags für S3D_SetCullmode()
#D3DCULL_NONE=1 
#D3DCULL_CW=2
#D3DCULL_CCW=3 

Procedure S3D_SetCullmode(mode)
*Dev.IDirect3DDevice7=S3D_GetD3DDevice()
ProcedureReturn *Dev\SetRenderState(#D3DRENDERSTATE_CULLMODE,mode)
EndProcedure

;-Flags für S3D_SetFillMode()
#D3DFILL_POINT=1 
#D3DFILL_WIREFRAME=2
#D3DFILL_SOLID=3
 
Procedure S3D_SetFillMode(FillMode)
*Dev.IDirect3DDevice7=S3D_GetD3DDevice()
ProcedureReturn *Dev\SetRenderState(#D3DRENDERSTATE_FILLMODE,FillMode)
EndProcedure

Procedure S3D_Clear(Color)
*Dev.IDirect3DDevice7=S3D_GetD3DDevice()
BGR=Color>>16+(Color&$FF00)+(Color&$FF)<<16  ; RGB->BGR
ProcedureReturn *Dev\Clear(0,0,#D3DCLEAR_TARGET,BGR,0,0) 
EndProcedure

Procedure S3D_SetSprite3DDiffuse(Sprite3D,Color1,Color2,Color3,Color4)
*ptr.PB_Sprite3D=IsSprite3D(Sprite3D)
If *ptr=0:ProcedureReturn 0:EndIf

*ptr\Vertice[0]\Color=Color1>>16+(Color1&$FF00)+(Color1&$FF)<<16
*ptr\Vertice[1]\Color=Color2>>16+(Color2&$FF00)+(Color2&$FF)<<16
*ptr\Vertice[2]\Color=Color3>>16+(Color3&$FF00)+(Color3&$FF)<<16
*ptr\Vertice[3]\Color=Color4>>16+(Color4&$FF00)+(Color4&$FF)<<16
EndProcedure

Procedure S3D_SetSprite3DSpecular(Sprite3D,Color1,Color2,Color3,Color4)
*ptr.PB_Sprite3D=IsSprite3D(Sprite3D)
If *ptr=0:ProcedureReturn 0:EndIf

*ptr\Vertice[0]\specular=Color1>>16+(Color1&$FF00)+(Color1&$FF)<<16
*ptr\Vertice[1]\specular=Color2>>16+(Color2&$FF00)+(Color2&$FF)<<16
*ptr\Vertice[2]\specular=Color3>>16+(Color3&$FF00)+(Color3&$FF)<<16
*ptr\Vertice[3]\specular=Color4>>16+(Color4&$FF00)+(Color4&$FF)<<16
EndProcedure

Procedure S3D_SetSprite3DTexCoords(Sprite3D,tu1.f,tv1.f,tu2.f,tv2.f,tu3.f,tv3.f,tu4.f,tv4.f)
*ptr.PB_Sprite3D=IsSprite3D(Sprite3D)
If *ptr=0:ProcedureReturn 0:EndIf

*ptr\Vertice[0]\tu=tu1
*ptr\Vertice[0]\tv=tv1
*ptr\Vertice[1]\tu=tu2
*ptr\Vertice[1]\tv=tv2
*ptr\Vertice[2]\tu=tu3
*ptr\Vertice[2]\tv=tv3
*ptr\Vertice[3]\tu=tu4
*ptr\Vertice[3]\tv=tv4
EndProcedure

Procedure S3D_SetViewPort(x,y,width,height)
*Dev.IDirect3DDevice7=S3D_GetD3DDevice()
view.D3DVIEWPORT7
view\dwX=x
view\dwY=y
view\dwWidth=width
view\dwHeight=height
view\dvMinZ=0.0
view\dvMaxZ=1.0
ProcedureReturn *Dev\SetViewPort(view)
EndProcedure
; IDE Options = PureBasic v3.94 (Windows - x86)
; CursorPosition = 90
; FirstLine = 111
; Folding = --