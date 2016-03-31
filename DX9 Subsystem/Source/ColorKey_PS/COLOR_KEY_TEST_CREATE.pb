#D3D_SDK_VERSION=31 

#D3DADAPTER_DEFAULT=0 
#D3DDEVTYPE_HAL=1
#D3DSWAPEFFECT_DISCARD=1
#D3DFMT_UNKNOWN=0  
#D3DFMT_D16=80

#D3DCREATE_SOFTWARE_VERTEXPROCESSING=32 
#D3DCLEAR_TARGET=1 
#D3DCLEAR_ZBUFFER=2

#D3DTS_WORLD=256
#D3DTS_VIEW=2
#D3DTS_PROJECTION=3

Structure D3DPresent_Parameters 
  BackBufferWidth.l 
  BackBufferHeight.l 
  BackBufferFormat.l 
  BackBufferCount.l 
  MultiSampleType.l 
  MultiSampleQuality.l 
  SwapEffect.l 
  hDeviceWindow.l 
  Windowed.l 
  EnableAutoDepthStencil.l 
  AutoDepthStencilFormat.l 
  Flags.l 
  FullScreen_RefreshRateInHz.l 
  FullScreen_PresentationInterval.l 
EndStructure 

Structure D3DXMATRIX 
  _11.f 
  _12.f 
  _13.f 
  _14.f 
  _21.f 
  _22.f 
  _23.f 
  _24.f 
  _31.f 
  _32.f 
  _33.f 
  _34.f 
  _41.f 
  _42.f 
  _43.f 
  _44.f 
EndStructure

Structure D3DXPARAMETER_DESC
Name.l                       ; // Parameter name
Semantic.l                  ;  // Parameter semantic
Class.l         ; // Class
Type.l         ;   // Component type
Rows.l                      ;  // Number of rows
Columns.l                  ;     // Number of columns
Elements.l                      ;// Number of array elements
Annotations.l            ;;       // Number of annotations
StructMembers.l                 ;// Number of Structure member sub-parameters
Flags.l               ;;        // D3DX_PARAMETER_* flags
Bytes.l              ;;//           // Parameter size, in bytes
EndStructure


D3D9DLL=OpenLibrary(1,"d3d9.dll") 
D3DX9DLL=OpenLibrary(2,"d3dx9_30.dll")

If D3D9DLL=0 Or D3DX9DLL=0 
  MessageRequester("Error","Can't load needed dlls!")
  End 
EndIf 

OpenWindow(1,0,0,640,480,"Direct3D9 FX Test",#PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget) 

*D3D.IDirect3D9=CallFunction(1,"Direct3DCreate9",#D3D_SDK_VERSION) 

If *D3D=0 
  MessageRequester("Error","Can't init direct3d 9!") 
  End 
EndIf 

D3DWnd.D3DPresent_Parameters\Windowed=1
D3DWnd\SwapEffect=#D3DSWAPEFFECT_DISCARD
D3DWnd\BackBufferWidth=640 
D3DWnd\BackBufferHeight=480 
D3DWnd\EnableAutoDepthStencil=1 ; use a z-buffer, or it will look ugly
D3DWnd\AutoDepthStencilFormat=#D3DFMT_D16

  
*D3D\CreateDevice(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,WindowID(1),#D3DCREATE_SOFTWARE_VERTEXPROCESSING,D3DWnd,@*D3DDevice.IDirect3DDevice9) 

If *D3DDevice=0 
  *D3D\Release()
  MessageRequester("Error","Can't init direct3d 9!") 
  End 
EndIf 


CallFunction(2,"D3DXCreateTextureFromFileA",*D3DDevice,@"test.bmp",@*Tex) 

Debug "SET TEX"
Debug *D3DDevice\SetTexture(0,*Tex)


; load fx file and compile it

CallFunction(2,"D3DXCreateEffectCompilerFromFileA",@"ColorKey.fx",0,0,0,@*EffectCompiler.ID3DXEffectCompiler,0)

If *EffectCompiler=0
  *D3DDevice\Release()
  *D3D\Release()
  MessageRequester("Error","D3DXCreateEffectCompilerFromFileA failed!") 
  End
EndIf

*EffectCompiler\CompileEffect(0,@*EffectBuffer.ID3DXBUFFER,0)

CallFunction(2,"D3DXCreateEffect",*D3DDevice,*EffectBuffer\GetBufferPointer(),*EffectBuffer\GetBufferSize(),0,0,0,0,@*Effect.ID3DXEffect,0)


; create teapot mesh
CallFunction(2,"D3DXCreateTeapot",*D3DDevice,@*Mesh.ID3DXMesh,0)

If *Mesh=0
  *D3DDevice\Release()
  *D3D\Release()
  MessageRequester("Error","D3DXCreateTeapot failed!") 
  End
EndIf


CallFunction(2,"D3DXMatrixTranslation",Translate.D3DXMATRIX,0,0,5.0)

CallFunction(2,"D3DXMatrixPerspectiveFovRH",Proj.D3DXMATRIX,ACos(-1)/2,1.0,0.1,100)

CallFunction(2,"D3DXMatrixPerspectiveLH",Proj.D3DXMATRIX,0.1,0.1,0.1,100.0)


;Debug *Effect\FindNextValidTechnique(0,@Technique)
;Debug *Effect\SetTechnique(Technique)  
    
;Debug *Effect\FindNextValidTechnique(Technique,@Technique)
;Debug *Effect\SetTechnique(Technique)  









Repeat

hParam=*Effect\GetParameter(0,Param)
If hParam
*Effect\GetParameterDesc(hParam,@ParamDesc.D3DXPARAMETER_DESC)

If ParamDesc\Type=9
Texture=hParam
Debug "TEX"
EndIf


If ParamDesc\Semantic

String$=UCase(PeekS(ParamDesc\Semantic,-1,#PB_UTF8))
Debug String$

If String$="WORLD":hWorld=hParam:EndIf
If String$="WORLDVIEW":hWorldView=hParam:EndIf
If String$="WORLDVIEWPROJECTION":hWorldViewProj=hParam:EndIf
If String$="VIEWPROJECTION":hViewProj=hParam:EndIf
If String$="VIEW":hView=hParam:EndIf
If String$="VIEWINV":hViewInv=hParam:EndIf
If String$="PROJECTION":hProj=hParam:EndIf
If String$="CAMERAPOSITION":hCameraPos=hParam:EndIf

Else

Debug "ParamDesc\Semantic=0"
EndIf

Else
Debug "hParam=0"
EndIf

Param+1
Until Param>100




*D3DDevice\SetTextureStageState(0,11,$40000)
     *D3DDevice\SetRenderState(7,1)
  *D3DDevice\SetRenderState(14,1)
  *D3DDevice\SetRenderState(23,4)
  

; set projection matrix
*D3DDevice\SetTransform(#D3DTS_PROJECTION,Proj)


CallFunction(2,"D3DXMatrixIdentity",View.D3DXMATRIX)

*D3DDevice\SetRenderStaTE(137,0)


*Effect\GetPixelShader(*Effect\GetCurrentTechnique(),@*psh)
Debug *psh

Repeat 

  t.f+0.05

  CallFunction(2,"D3DXMatrixRotationX",RotX.D3DXMATRIX,t)
  CallFunction(2,"D3DXMatrixRotationY",RotY.D3DXMATRIX,t)
 
  CallFunction(2,"D3DXMatrixMultiply",World.D3DXMATRIX,RotX,RotY)
  CallFunction(2,"D3DXMatrixMultiply",World.D3DXMATRIX,World,Translate)
  
  *D3DDevice\SetTransform(#D3DTS_WORLD,World)

  *D3DDevice\Clear(0,0,#D3DCLEAR_TARGET|#D3DCLEAR_ZBUFFER,$555555,1.0,0) 
  *D3DDevice\BeginScene()

  *Effect\Begin(@NumPasses,0)
  For Pass=0 To NumPasses-1
    *Effect\BeginPass(Pass)
    *Mesh\DrawSubset(0)
    
    
    If WR=0
    WR=1
    *D3DDevice\GetPixelShader(@*ps.IDirect3DPixelShader9)
    *ps\GetFunction(0,@Size)
    Addr=AllocateMemory(Size)
    A=Size
    *ps\GetFunction(Addr,@A)
    
    CreateFile(1,"ColorKey.ps")
    WriteData(1,Addr,Size)
    CloseFile(1)
    EndIf
    
    
    
    *Effect\EndPass()
  Next

  *D3DDevice\EndScene()

  *D3DDevice\Present(0,0,0,0) 
Until WindowEvent()=#PB_Event_CloseWindow

*Effect\Release()
*EffectBuffer\Release()
*EffectCompiler\Release()
*D3DDevice\Release()
*D3D\Release()

; IDE Options = PureBasic 5.00 Beta 3 (Windows - x86)
; CursorPosition = 101
; FirstLine = 89