
IncludeFile "DX9S_ObjectManager.pbi"
IncludeFile "DX9S_TextureManager.pbi"
IncludeFile "DX9S_DIK8.pbi"
IncludeFile "DX9S_DIM8.pbi"
IncludeFile "DX9S_DIJ8.pbi"
;IncludeFile "DX9S_ULH.pbi"
IncludeFile "DX9S_DS8.pbi"
IncludeFile "DX9S_Dummys.pbi"
;IncludeFile "DX9S_ImageLoader.pbi"

Structure MyTexCoord
  tu.f
  tv.f
EndStructure

Structure MySpriteVertex
  x.f
  y.f
  z.f
  rhw.f
  tu.f
  tv.f
EndStructure 

Structure MyColoredSpriteVertex
  x.f
  y.f
  z.f
  rhw.f
  Color.l
  tu.f
  tv.f
EndStructure 

Structure MyRGBVertex
  x.f
  y.f
  z.f
  rhw.f
  Color.l
EndStructure

Structure DisplaySprite
  v.MySpriteVertex[4]
EndStructure

Structure DisplaySpriteColor
  v.MyColoredSpriteVertex[4]
EndStructure

Structure RGBFilter
  v.MyRGBVertex[4]
EndStructure

Structure PB_DX9Sprite
  TexRes.l       ; TexRes
  Width.l        ; Current width of the sprite (could change if ClipSprite() is used)
  Height.l       ; Current height of the sprite (could change if ClipSprite() is used)
  Depth.l        ; depth of shade of the file. (in bits)  
  Mode.l         ; Sprite mode, as described in LoadSprite()
  FileName.l     ; Pointer on the filename, if any
  RealWidth.l    ; Original width of the sprite when it was loaded
  RealHeight.l   ; Original height of the sprite when it was loaded   
  ClipX.l        ; X offset if ClipSprite()
  ClipY.l        ; Y offset if ClipSprite()
  t.MyTexCoord[4]
  TexRes2.l
  fU.f
  fV.f
  FastCollisionMap.l
  InvalidCollisionMap.l
  CollisionMapCreationCount.l
EndStructure

Structure PB_ScreenMode
  ScreenModeWidth.w	       ; Width of the Screen (in pixel)
  ScreenModeHeight.w	     ; Height of the Screen (in pixel)
  ScreenModeDepth.w	       ; Depth of the Screen (in bits per pixel)
  ScreenModeRefreshRate.w  ; Refresh rate of the Screen (in Hz)
EndStructure
  
Structure DrawingInfoStruct
  Type.l
  Window.l
  DC.l
  ReleaseProcedure.l
  PixelBuffer.l
  Pitch.l
  Width.l
  Height.l
  Depth.l
  PixelFormat.l
  StopDirectAccess.l
  StartDirectAccess.l
EndStructure

Structure MyD3DTLVERTEX
  x.f
  y.f
  z.f
  rhw.f
  Color.l
  tu.f
  tv.f
EndStructure

Structure RECTF
  left.f
  top.f
  right.f
  bottom.f
EndStructure


Structure PB_DX9Sprite3D
  TexRes.l                 ; TexRes
  Vertice.MyD3DTLVERTEX[4] ; The 4 vertices for the rectangle sprite
  Width.l			             ; width set with ZoomSprite3D()
  Height.l			           ; height set with ZoomSprite3D()
  RealWidth.l
  RealHeight.l
  Angle.f
  Transformed.l
  BoundingBox.RECTF
EndStructure

Structure GAMMARAMP
  Red.w[256]
  Green.w[256]
  Blue.w[256]
EndStructure

Structure PB_DX8Sound
  DSB.l
EndStructure

Global _PB_Screen_Width
Global _PB_Screen_Height
Global _PB_Screen_Depth
Global _PB_Screen_RealWidth
Global _PB_Screen_RealHeight
Global _PB_Screen_WindowedXOffset
Global _PB_Screen_WindowedYOffset
Global _PB_Screen_AutoStretch
Global _PB_Screen_WindowedRightBorder
Global _PB_Screen_WindowedBottomBorder
Global _PB_Screen_Windowed
Global _PB_Direct3D_Device
Global _PB_D3DBase
;PublicVar(_PB_DirectX_BackBuffer)

Global SecureMode=1    ; <---------------

Global D3D9Inst
Global *D3D.IDirect3D9
Global *D3DDevice9.IDirect3DDevice9
Global *BackBuffer.IDirect3DSurface9
Global BackBufferSysCopyBitmap.l
;Global BackBufferPitch.l
Global SpriteList
Global SpriteList3D


Global d3dpp.D3DPRESENT_PARAMETERS
Global d3dcaps.D3DCAPS9


Global Screen_RefreshRate ; Refresh rate of the monitor
Global Screen_FrameRate ; Frame rate set with SetFrameRate()
Global Screen_Format

;Global _PB_Screen_Width ; Width of BackBuffer
;Global _PB_Screen_Height ; Height of BackBuffer
;Global _PB_Screen_RealWidth ; Width of BackBuffer
;Global _PB_Screen_RealHeight ; Height of BackBuffer
Global Screen_Target
Global IsScreenActive ; can we render on the screen ? (Flag set by FlipBuffers())

;Global _PB_Screen_AutoStretch
;Global _PB_Screen_WindowedXOffset
;Global _PB_Screen_WindowedYOffset
;Global _PB_Screen_WindowedRightBorder
;Global _PB_Screen_WindowedBottomBorder


Global ScreenOutput.DrawingInfoStruct
Global SpriteOutput.DrawingInfoStruct
Global *SpriteOutputID.PB_DX9Sprite

Global *ScreenModes.PB_ScreenMode
Global NumScreenModes
Global ScreenModeIndex
Global ScreenModeWidth
Global ScreenModeHeight
Global ScreenModeRefreshRate
Global ScreenModeDepth

Global AlphaIntensity


Global Screen_InitKeyboard
Global Screen_InitMouse
Global Screen_InitSound
Global Screen_InitJoystick
Global SoundList

;D3DDevice9 States
Global AlphaBlendState,SrcBlendMode,DestBlendMode
Global CurrentFVF


Global S3DSrcBlendMode,S3DDestBlendMode
Global S3DQuality

Global Screen_OldWndCB
Global DefaultTransColor
Global *PSColorKey.IDirect3DPixelShader9
Global UsePixelShader14
Global PS14Active
Global PS14CurrentTransColor

Global BeginScene

Global DeviceFlags

Global *Sprite3DIndexBuffer.l,*Sprite3DVertexBuffer.l
Global Sprite3D_CanRender.l
Global Sprite3D_QuadCount.l,Sprite3D_LastTex1.l,Sprite3D_SetTex1.l
Global Sprite3D_Clipping.l


Structure RGBA
  r.f
  g.f
  b.f
  a.f
EndStructure

Macro EnablePixelShader14(TransColor)
If UsePixelShader14
  
  If PS20Active=0
    *D3DDevice9\SetPixelShader(*PSColorKey)
    PS14Active=1
  EndIf
  
  If TransColor<>PS14CurrentTransColor
    PS14CurrentTransColor=TransColor
    ;R=>>3:G=>>3:B=>>3
    ;R<<3:G<<3:B<<3
    ;((( --> so wahrscheinlich nicht richtig da >>3  ... <<3  + siehe PointFast()  )))
    
    ;Color=(TransColor>>16)>>3+(((TransColor&$FF00)>>8)>>3)<<5+((TransColor&$FF)>>3)<<10
    R=TransColor&$FF
    G=(TransColor>>8)&$FF
    B=(TransColor>>16)&$FF
    
    nR=R>>3
    nR<<3
    nR+R>>5
    
    nG=G>>2
    nG<<2
    nG+G>>5
    
    nB=B>>3
    nB<<3
    nB+B>>5
    
    c.RGBA\r=nR/255:c\g=nG/255:c\b=nB/255
    *D3DDevice9\SetPixelShaderConstantF(0,c,1)
  EndIf
  
  
EndIf
EndMacro

Macro DisablePixelShader14()
If UsePixelShader14
  If PS14Active
    *D3DDevice9\SetPixelShader(0)
    PS14Active=0
  EndIf
EndIf
EndMacro





Macro SetBlendMode(AlphaBlend,SrcBlend,DestBlend,FVF)
If AlphaBlendState<>AlphaBlend
  AlphaBlendState=~AlphaBlendState
  *D3DDevice9\SetRenderState(#D3DRS_ALPHABLENDENABLE,AlphaBlend)
EndIf 
If SrcBlendMode<>SrcBlend
  SrcBlendMode=SrcBlend
  *D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,SrcBlend)
EndIf 
If DestBlendMode<>DestBlend
  DestBlendMode=DestBlend
  *D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,DestBlend)
EndIf
If CurrentFVF<>FVF
  CurrentFVF=FVF
  *D3DDevice9\SetFVF(FVF)
EndIf
EndMacro


Macro BeginD3D9Scene()
If IsScreenActive=0:ProcedureReturn #False:EndIf
If BeginScene=#False
  If *D3DDevice9\BeginScene():ProcedureReturn #False:EndIf
  BeginScene=#True
EndIf
EndMacro

Declare FreeSprite(Sprite)
Declare CloseScreen()
Declare IsSprite(Sprite)
Declare FlipBuffers2(Mode)

Procedure ___WndCB(hWnd,Msg,wParam,lParam)
  If Msg=#WM_ERASEBKGND Or Msg=#WM_PAINT
    FlipBuffers2(0)
  EndIf
  If Screen_OldWndCB
    ProcedureReturn CallWindowProc_(Screen_OldWndCB,hWnd,Msg,wParam,lParam)
  EndIf
  ProcedureReturn DefWindowProc_(hWnd,Msg,wParam,lParam)
EndProcedure

Procedure ___FreeSpriteCB(List,*ptr.PB_DX9Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\TexRes:TexRes_Free(*ptr\TexRes):EndIf
  If *ptr\TexRes2:TexRes_Free(*ptr\TexRes2):EndIf
  O_FreeObject(SpriteList,*ptr)
EndProcedure

Procedure ___CreateSprite(Sprite.l,Width.l,Height.l,Mode.l)  
  Type=#TEXRES_STATIC_A1R5G5B5
  If Mode&#PB_Sprite_Memory:Type=#TEXRES_DYNAMIC_A1R5G5B5:EndIf
  If Mode&#PB_Sprite_AlphaBlending
    
    ;--> needed(next line), but why ? (without it crashes)
    If Mode&#PB_Sprite_Texture=0:ProcedureReturn 0:EndIf
    
    Type=#TEXRES_STATIC_A8R8G8B8
  EndIf
  
  If Mode&#PB_Sprite_Texture
    RealTexture=1
  EndIf
  
  If UsePixelShader14 And Type=#TEXRES_DYNAMIC_A1R5G5B5
    *TexRes=TexRes_CreateTexture(*D3DDevice9,Width,Height,#TEXRES_DYNAMIC_A1R5G5B5_PS14,RealTexture)
  EndIf
  
  If *TexRes=0
    *TexRes=TexRes_CreateTexture(*D3DDevice9,Width,Height,Type,RealTexture)
  EndIf
  
  If *TexRes=0 And Type=#TEXRES_DYNAMIC_A1R5G5B5 ; try #TEXRES_STATIC_A1R5G5B5 if TexRes_CreateTexture() is failed(Dynamic textures are not supported everywhere)
    *TexRes=TexRes_CreateTexture(*D3DDevice9,Width,Height,#TEXRES_STATIC_A1R5G5B5,RealTexture)
  EndIf
  
  If *TexRes=0:ProcedureReturn 0:EndIf
  
  If O_IsObject(SpriteList,Sprite)
    FreeSprite(Sprite)
  EndIf
  *ptr.PB_DX9Sprite=O_GetOrAllocateID(SpriteList,Sprite)
  If *ptr=0:TexRes_Free(*TexRes):ProcedureReturn 0:EndIf
  
  *ptr\TexRes=*TexRes
  *ptr\Width=Width
  *ptr\Height=Height
  *ptr\Mode=Mode
  *ptr\Depth=16 ; always 16-Bit(X1R5G5B5) for normal sprites
  If Type=#TEXRES_STATIC_A8R8G8B8:*ptr\Depth=32:EndIf
  *ptr\FileName=0
  *ptr\RealWidth=Width
  *ptr\RealHeight=Height
  *ptr\ClipX=0
  *ptr\ClipY=0
  ; texture coords used for clipping
  *ptr\t[0]\tu=0.0
  *ptr\t[0]\tv=0.0
  *ptr\t[1]\tu=1.0
  *ptr\t[1]\tv=0.0
  *ptr\t[2]\tu=0.0
  *ptr\t[2]\tv=1.0
  *ptr\t[3]\tu=1.0
  *ptr\t[3]\tv=1.0
  
  
  ;-> always Real Texture
  
  ;If RealTexture
  *ptr\fU=1
  *ptr\fV=1
  ;Else
  ;*ptr\fU=*ptr\RealWidth/ToPow2(*ptr\RealWidth)
  ;*ptr\fV=*ptr\RealHeight/ToPow2(*ptr\RealHeight)
  ;EndIf
  
  *ptr\InvalidCollisionMap=#True
  
  TexRes_SetTransColor(*TexRes,DefaultTransColor)
  ProcedureReturn *ptr
EndProcedure

Procedure ___ClearSprite(Sprite,x,y,Width,Height,Color)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  DC=TexRes_GetDC(*ptr\TexRes)
  If DC=0:ProcedureReturn 0:EndIf
  
  result=SelectObject_(DC,GetStockObject_(#NULL_PEN))
  If result=0:TexRes_ReleaseDC(*ptr\TexRes,1):ProcedureReturn 0:EndIf
  hBrush=CreateSolidBrush_(Color)
  If hBrush=0:TexRes_ReleaseDC(*ptr\TexRes,1):ProcedureReturn 0:EndIf
  hOldBrush=SelectObject_(DC,hBrush)
  If hOldBrush=0:DeleteObject_(hBrush):TexRes_ReleaseDC(*ptr\TexRes,1):ProcedureReturn 0:EndIf
  result=Rectangle_(DC,x,y,x+Width,y+Height)
  If result=0:DeleteObject_(hBrush):TexRes_ReleaseDC(*ptr\TexRes,1):ProcedureReturn 0:EndIf
  SelectObject_(DC,hOldBrush)
  DeleteObject_(hBrush)
  
  ProcedureReturn TexRes_ReleaseDC(*ptr\TexRes,0)
EndProcedure

Procedure ___ReleaseScreenOutput()
  ;If ScreenOutput\DC And ScreenOutput\PixelBuffer ; is the fast method (hopefully) Release the DC should be enought 
  ;  *BackBuffer\ReleaseDC(ScreenOutput\DC)
  ;  ScreenOutput\DC=0
  ;  ScreenOutput\PixelBuffer=0
  ;EndIf  
  
  If ScreenOutput\DC
    *BackBuffer\ReleaseDC(ScreenOutput\DC)
    ScreenOutput\DC=0
  EndIf
  
  If ScreenOutput\PixelBuffer
    *BackBuffer\UnLockRect()
    ScreenOutput\PixelBuffer=0
  EndIf
  
EndProcedure


;+
Procedure ___ReleaseSpriteOutput()
  ; If SpriteOutput\DC And SpriteOutput\PixelBuffer
  ;   If *SpriteOutputID
  ;    TexRes_ReleaseDC(*SpriteOutputID\TexRes,0)
  ;     *SpriteOutputID=0
  ;     SpriteOutput\DC=0
  ;     SpriteOutput\PixelBuffer=0
  ;   EndIf
  ; EndIf
  
  If SpriteOutput\DC
    If *SpriteOutputID
      TexRes_ReleaseDC(*SpriteOutputID\TexRes,0)
      SpriteOutput\DC=0
      SpriteOutput\PixelBuffer=0
      
      ;-Correct?
      
      
      ;-WARNIG REMOVED !!!!
     ; TexRes_GetUpdatedTexture(*SpriteOutputID\TexRes)
      
      result=TexRes_Optimize(*SpriteOutputID\TexRes,UsePixelShader14) ; try to optimize the Texture
      If result:*SpriteOutputID\TexRes=result:EndIf
      
      
      *SpriteOutputID=0
    EndIf
  EndIf
  
  If SpriteOutput\PixelBuffer
    If *SpriteOutputID
      TexRes_UnLock(*SpriteOutputID\TexRes,0)
      SpriteOutput\PixelBuffer=0
      SpriteOutput\DC=0
      
      ;-Correct?
      
      
      ;-WARNIG REMOVED !!!!
      ;TexRes_GetUpdatedTexture(*SpriteOutputID\TexRes)
      
      result=TexRes_Optimize(*SpriteOutputID\TexRes,UsePixelShader14) ; try to optimize the Texture
      If result:*SpriteOutputID\TexRes=result:EndIf
      
      *SpriteOutputID=0
    EndIf
  EndIf
  
  
  
  
EndProcedure


Procedure ___ScreenStopDirectAccess()
  If ScreenOutput\PixelBuffer
    *BackBuffer\UnLockRect()
    ScreenOutput\PixelBuffer=0
  EndIf
  *BackBuffer\GetDC(@ScreenOutput\DC)
  ProcedureReturn ScreenOutput\DC
EndProcedure


Procedure ___ScreenStartDirectAccess(*pitch.long)
  If ScreenOutput\DC
    ;GetPixel_(ScreenOutput\DC,0,0) ; isn't needed here
    *BackBuffer\ReleaseDC(ScreenOutput\DC)
    ScreenOutput\DC=0
  EndIf
  *BackBuffer\LockRect(lr.D3DLOCKED_RECT,0,0)
  ScreenOutput\PixelBuffer=lr\pBits
  ScreenOutput\Pitch=lr\Pitch
  *pitch\l=lr\Pitch
  ProcedureReturn ScreenOutput\PixelBuffer
EndProcedure


Procedure ___SpriteStopDirectAccess()
  If SpriteOutput\PixelBuffer
    TexRes_UnLock(*SpriteOutputID\TexRes,0)
    SpriteOutput\PixelBuffer=0
  EndIf
  SpriteOutput\DC=TexRes_GetDC(*SpriteOutputID\TexRes)
  ProcedureReturn SpriteOutput\DC
EndProcedure

Procedure ___SpriteStartDirectAccess(*pitch.long)
  If SpriteOutput\DC
    ;GetPixel_(SpriteOutput\DC,0,0) ; isn't needed here
    TexRes_ReleaseDC(*SpriteOutputID\TexRes,0)
    SpriteOutput\DC=0
  EndIf
  TexRes_Lock(*SpriteOutputID\TexRes,0,@SpriteOutput\PixelBuffer,@SpriteOutput\Pitch)
  *pitch\l=SpriteOutput\Pitch
  ProcedureReturn SpriteOutput\PixelBuffer
EndProcedure


Procedure ___FreeDefaultPoolRes(List,*ptr.PB_DX9Sprite)
  If *ptr
    TexRes_OnLost(*ptr\TexRes)
  EndIf
EndProcedure

Procedure ___RestoreDefaultPoolRes(List,*ptr.PB_DX9Sprite)
  If *ptr
    TexRes_Restore(*ptr\TexRes)
  EndIf
EndProcedure



Procedure ___CreatePixelShader()
  
  ;- PIXELSHADER DISABLED !
  ;ProcedureReturn 0
  
  If *D3DDevice9=0:ProcedureReturn 0:EndIf
  
  If (d3dcaps\PixelShaderVersion)&$FFFF>=260  ; at least PS 1.4
    *D3DDevice9\CreatePixelShader(?PS14_ColorKey,@*PSColorKey)
  EndIf
  
  ProcedureReturn *PSColorKey
EndProcedure


Procedure ___PrepareD3D9Device()
  If *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_TEXTURE):ProcedureReturn #False:EndIf
  If *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG2,#D3DTA_DIFFUSE):ProcedureReturn #False:EndIf
  If *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG1,#D3DTA_TEXTURE):ProcedureReturn #False:EndIf
  If *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG2,#D3DTA_DIFFUSE):ProcedureReturn #False:EndIf
  If *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1):ProcedureReturn #False:EndIf
  If *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1):ProcedureReturn #False:EndIf
  ProcedureReturn #True
EndProcedure


Procedure ___CreateSpriteCollisionMap(*s1ptr.PB_DX9Sprite)
  
  If *s1ptr=0:ProcedureReturn #False:EndIf
  
  If *s1ptr\InvalidCollisionMap And *s1ptr\FastCollisionMap
    GlobalFree_(*s1ptr\FastCollisionMap)
    *s1ptr\FastCollisionMap=0
  EndIf
  
  If *s1ptr\FastCollisionMap=0 And *s1ptr\CollisionMapCreationCount<5
    
    *s1ptr\FastCollisionMap=GlobalAlloc_(#GMEM_ZEROINIT|#GMEM_FIXED,*s1ptr\RealWidth * *s1ptr\RealHeight )
    *s1ptr\InvalidCollisionMap=0
    *s1ptr\CollisionMapCreationCount+1
    
    If *s1ptr\FastCollisionMap
      *ptr.BYTE=*s1ptr\FastCollisionMap
      
      result=TexRes_Lock(*s1ptr\TexRes,1,@s1buffer,@s1bufferpitch)
      If result=0:GlobalFree_(*s1ptr\FastCollisionMap):*s1ptr\FastCollisionMap=0:ProcedureReturn #False:EndIf
      
      TransparentColor=TexRes_GetTransColor(*s1ptr\TexRes) 
      s1buffertrans.w=(TransparentColor>>16)>>3+(((TransparentColor&$FF00)>>8)>>2)<<5+((TransparentColor&$FF)>>3)<<11
      
      For y=0 To *s1ptr\RealHeight-1
        *s1bufferptr.WORD=s1buffer+(y)*s1bufferpitch+(0)*2
        For x=0 To *s1ptr\RealWidth-1
          If (*s1bufferptr\w)<>s1buffertrans
            *ptr\b=255
          Else
            *ptr\b=0
          EndIf 
          *s1bufferptr+2
          *ptr+1
        Next
      Next
      
      TexRes_UnLock(*s1ptr\TexRes,1)
      
    EndIf
    
  EndIf
  
  If *s1ptr\FastCollisionMap
    ProcedureReturn #True
  EndIf
EndProcedure


Procedure ___SpriteCollisionMapPixelCollision(*s1ptr.PB_DX9Sprite,x1,y1,*s2ptr.PB_DX9Sprite,x2,y2)
  
  SetRect_(re1.rect,x1,y1,x1+*s1ptr\Width,y1+*s1ptr\Height)
  SetRect_(re2.rect,x2,y2,x2+*s2ptr\Width,y2+*s2ptr\Height)
  x1-*s1ptr\ClipX
  x2-*s2ptr\ClipX
  y1-*s1ptr\ClipY
  y2-*s2ptr\ClipY
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
  For y=ire\Top To ire\bottom-1
    x=ire\left
  length.l=(ire\right-1) - x  +1  ;=(ire\right-1) 
    
    If H_CompareBytes(*s1ptr\FastCollisionMap+(y-y1)* *s1ptr\RealWidth+(x-x1),*s2ptr\FastCollisionMap+(y-y2)* *s2ptr\RealWidth+(x-x2),length)
      ProcedureReturn #True
    EndIf
  Next
  
EndProcedure



;->====================================================================
;->                           JOYSTICK COMMANDS        
;->====================================================================

ProcedureDLL InitJoystick()
  If DIJ8_InitJoystick()=0:ProcedureReturn 0:EndIf
  Screen_InitJoystick=1
  ProcedureReturn 1
EndProcedure

ProcedureDLL ExamineJoystick()
  ProcedureReturn DIJ8_ExamineJoystick() 
EndProcedure

ProcedureDLL JoystickButton(Button)
  ProcedureReturn DIJ8_Button(Button)
EndProcedure

ProcedureDLL JoystickAxisX() 
  Axis=(DIJ8_AxisX()-$7FFF)
  If Axis>$3FFF:ProcedureReturn 1:EndIf
  If Axis<-$3FFF:ProcedureReturn -1:EndIf
  ProcedureReturn 0
EndProcedure

ProcedureDLL JoystickAxisY() 
  Axis=(DIJ8_AxisY()-$7FFF)
  If Axis>$3FFF:ProcedureReturn 1:EndIf
  If Axis<-$3FFF:ProcedureReturn -1:EndIf
  ProcedureReturn 0
EndProcedure


;->====================================================================
;->                           SOUND COMMANDS        
;->====================================================================



ProcedureDLL InitSound()
  SoundList=O_Init(SizeOf(PB_DX9Sprite),128,0)
  If SoundList=0:ProcedureReturn 0:EndIf
  result=DS8_InitSound()
  If result
    Screen_InitSound=1
  EndIf
  ProcedureReturn result
EndProcedure

ProcedureDLL CatchSound2(Sound,Addr,Size)
  *DSB.IDirectSoundBuffer8=DS8_LoadSoundBufferFromMem(Addr,Size)
  If *DSB=0:ProcedureReturn 0:EndIf
  *ptr.PB_DX8Sound=O_GetOrAllocateID(SoundList,Sound)
  If *ptr=0
    *DSB\Release()
    ProcedureReturn 0
  EndIf
  *ptr\DSB=*DSB
  
  If Sound=#PB_Any
    ProcedureReturn *ptr
  EndIf
  
  ProcedureReturn *DSB
EndProcedure

ProcedureDLL CatchSound(Sound,Addr)
  ProcedureReturn CatchSound2(Sound,Addr,0)
EndProcedure

ProcedureDLL FreeSound(Sound)
  *ptr.PB_DX8Sound=O_IsObject(SoundList,Sound)
  If *ptr=0:ProcedureReturn 0:EndIf
  DS8_FreeSoundBuffer(*ptr\DSB)
  O_FreeObject(SoundList,Sound)  
EndProcedure

ProcedureDLL IsSound(Sound)
  ProcedureReturn O_IsObject(SoundList,Sound)
EndProcedure

ProcedureDLL LoadSound(Sound,File$)
  If *DS8_PDSB=0:ProcedureReturn 0:EndIf
  *DSB.IDirectSoundBuffer8=DS8_LoadSoundBufferFromFile(File$)
  If *DSB=0:ProcedureReturn 0:EndIf
  *ptr.PB_DX8Sound=O_GetOrAllocateID(SoundList,Sound)
  If *ptr=0
    *DSB\Release()
    ProcedureReturn 0
  EndIf
  *ptr\DSB=*DSB
  
  If Sound=#PB_Any
    ProcedureReturn *ptr
  EndIf
  
  ProcedureReturn *DSB
EndProcedure

ProcedureDLL PlaySound2(Sound,Looping)
  *ptr.PB_DX8Sound=O_IsObject(SoundList,Sound)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn DS8_PlaySoundBuffer(*ptr\DSB,Looping)
EndProcedure

ProcedureDLL PlaySound(Sound)
  ProcedureReturn PlaySound2(Sound,0)
EndProcedure


ProcedureDLL SoundFrequency(Sound,Freq)
  *ptr.PB_DX8Sound=O_IsObject(SoundList,Sound)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn DS8_SetSoundBufferFrequency(*ptr\DSB,Freq)
EndProcedure


ProcedureDLL SoundPan(Sound,Balance)
  *ptr.PB_DX8Sound=O_IsObject(SoundList,Sound)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn DS8_SetSoundBufferPan(*ptr\DSB,Pan)
EndProcedure

;-> Channel not supported
ProcedureDLL SoundVolume2(Sound,Volume,Channel)
  *ptr.PB_DX8Sound=O_IsObject(SoundList,Sound)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn DS8_SetSoundBufferVolume(*ptr\DSB,Volume)
EndProcedure

ProcedureDLL SoundVolume(Sound,Volume)
  ProcedureReturn SoundVolume2(Sound,Volume,0)
EndProcedure

ProcedureDLL StopSound(Sound)
  If Sound=-1
    ProcedureReturn DS8_StopSound(0)
  EndIf
  
  *ptr.PB_DX8Sound=O_IsObject(SoundList,Sound)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn DS8_StopSound(*ptr\DSB)
EndProcedure


;->====================================================================
;->                           MOUSE COMMANDS        
;->====================================================================



ProcedureDLL InitMouse()
  If DIM8_InitMouse()=0:ProcedureReturn 0:EndIf
  Screen_InitMouse=1
  ProcedureReturn 1
EndProcedure

ProcedureDLL ExamineMouse()
  ProcedureReturn DIM8_ExamineMouse(_PB_Screen_RealWidth,_PB_Screen_RealHeight) 
EndProcedure

ProcedureDLL MouseButton(Button)
  ProcedureReturn DIM8_MouseButton(Button)
EndProcedure

ProcedureDLL MouseLocate(x,y)
  ProcedureReturn DIM8_MouseLocate(x,y,_PB_Screen_RealWidth,_PB_Screen_RealHeight)
EndProcedure


;- STRANGE MouseX()/ MouseY() BUG !!!!

ProcedureDLL MouseX()
  ProcedureReturn DIM8_MouseX()
EndProcedure

ProcedureDLL MouseY()
  ProcedureReturn DIM8_MouseY()
EndProcedure

ProcedureDLL MouseDeltaX()
  ProcedureReturn DIM8_MouseDeltaX()
EndProcedure

ProcedureDLL MouseDeltaY()
  ProcedureReturn DIM8_MouseDeltaY()
EndProcedure

ProcedureDLL MouseWheel()
  ProcedureReturn DIM8_MouseWheel()
EndProcedure

ProcedureDLL ReleaseMouse(State)
  ;- ONLY WINDOWED ????!?!??!?!??????????
  ; If _PB_Screen_Windowed
  ;   ProcedureReturn DIM8_ReleaseMouse(State,0)
  ; Else
  ;   ProcedureReturn DIM8_ReleaseMouse(State,1)
  ; EndIf
  ProcedureReturn DIM8_ReleaseMouse(State)
EndProcedure


;->====================================================================
;->                           KEYBOARD COMMANDS        
;->====================================================================



ProcedureDLL InitKeyboard()
  If DIK8_InitKeyboard()=0:ProcedureReturn 0:EndIf
  Screen_InitKeyboard=1
  ProcedureReturn 1
EndProcedure

ProcedureDLL ExamineKeyboard()
  ProcedureReturn DIK8_ExamineKeyboard() 
EndProcedure


ProcedureDLL KeyboardPushed(Key)
  ProcedureReturn DIK8_KeyPushed(Key)
EndProcedure


ProcedureDLL KeyboardReleased(Key)
  ProcedureReturn DIK8_KeyUp(Key)
EndProcedure


ProcedureDLL KeyboardMode(Mode)
  ProcedureReturn DIK8_SetKeyboardMode(Mode)
EndProcedure


ProcedureDLL.s KeyboardInkey()
  ProcedureReturn DIK8_Inkey()
EndProcedure

;->====================================================================
;->                           SPRITE COMMANDS        
;->====================================================================

ProcedureDLL InitSprite()
  AlphaIntensity=$FFFFFF
  
  If D3D9Inst=0
    D3D9Inst=LoadLibrary_("d3d9.dll")
  EndIf
  If D3D9Inst=0:ProcedureReturn 0:EndIf
  
  Direct3DCreate9=GetProcAddress_(D3D9Inst,"Direct3DCreate9")
  If Direct3DCreate9=0:FreeLibrary_(D3D9Inst):D3D9Inst=0:ProcedureReturn 0:EndIf ; --> Free D3D9Inst ?
  
  *D3D.IDirect3D9=CallFunctionFast(Direct3DCreate9,#D3D_SDK_VERSION)
  If *D3D=0:FreeLibrary_(D3D9Inst):D3D9Inst=0:ProcedureReturn 0:EndIf
  
  If TexRes_Init()=0:*D3D\Release():FreeLibrary_(D3D9Inst):D3D9Inst=0:ProcedureReturn 0:EndIf
  
  SpriteList=O_Init(SizeOf(PB_DX9Sprite),128,0)
  If SpriteList=0:*D3D\Release():FreeLibrary_(D3D9Inst):D3D9Inst=0:ProcedureReturn 0:EndIf
  
  ;Examine screen modes
  Num15BitModes=*D3D\GetAdapterModeCount(#D3DADAPTER_DEFAULT,#D3DFMT_X1R5G5B5)
  Num16BitModes=*D3D\GetAdapterModeCount(#D3DADAPTER_DEFAULT,#D3DFMT_R5G6B5)
  Num32BitModes=*D3D\GetAdapterModeCount(#D3DADAPTER_DEFAULT,#D3DFMT_X8R8G8B8)
  
  NumScreenModes=Num32BitModes
  If Num15BitModes>0
    NumScreenModes+Num15BitModes
  Else
    NumScreenModes+Num16BitModes
  EndIf
  
  If NumScreenModes=0:*D3D\Release():O_Free(SpriteList):FreeLibrary_(D3D9Inst):D3D9Inst=0:ProcedureReturn 0:EndIf
  *ScreenModes=AllocateMemory(NumScreenModes*SizeOf(PB_ScreenMode))
  If *ScreenModes=0:*D3D\Release():O_Free(SpriteList):FreeLibrary_(D3D9Inst):D3D9Inst=0:ProcedureReturn 0:EndIf
  
  *ScreenModesPtr.PB_ScreenMode=*ScreenModes
  
  If Num15BitModes>0
    For Mode=0 To Num15BitModes-1
      *D3D\EnumAdapterModes(#D3DADAPTER_DEFAULT,#D3DFMT_X1R5G5B5,Mode,d3ddm.D3DDISPLAYMODE)
      *ScreenModesPtr\ScreenModeWidth=d3ddm\Width
      *ScreenModesPtr\ScreenModeHeight=d3ddm\Height
      *ScreenModesPtr\ScreenModeRefreshRate=d3ddm\RefreshRate
      *ScreenModesPtr\ScreenModeDepth=H_D3DFormatToBPP(d3ddm\Format)
      *ScreenModesPtr+SizeOf(PB_ScreenMode)
    Next
    
  Else
    *ScreenModesPtr.PB_ScreenMode=*ScreenModes
    For Mode=0 To Num16BitModes-1
      *D3D\EnumAdapterModes(#D3DADAPTER_DEFAULT,#D3DFMT_R5G6B5,Mode,d3ddm.D3DDISPLAYMODE)
      *ScreenModesPtr\ScreenModeWidth=d3ddm\Width
      *ScreenModesPtr\ScreenModeHeight=d3ddm\Height
      *ScreenModesPtr\ScreenModeRefreshRate=d3ddm\RefreshRate
      *ScreenModesPtr\ScreenModeDepth=H_D3DFormatToBPP(d3ddm\Format)
      *ScreenModesPtr+SizeOf(PB_ScreenMode)
    Next
    
  EndIf
  
  For Mode=0 To Num32BitModes-1
    *D3D\EnumAdapterModes(#D3DADAPTER_DEFAULT,#D3DFMT_X8R8G8B8,Mode,d3ddm.D3DDISPLAYMODE)
    *ScreenModesPtr\ScreenModeWidth=d3ddm\Width
    *ScreenModesPtr\ScreenModeHeight=d3ddm\Height
    *ScreenModesPtr\ScreenModeRefreshRate=d3ddm\RefreshRate
    *ScreenModesPtr\ScreenModeDepth=H_D3DFormatToBPP(d3ddm\Format)
    *ScreenModesPtr+SizeOf(PB_ScreenMode)
  Next
  ScreenModeIndex=0
  Screen_FrameRate=60
  
  
  ; HERE HERE COMMENT IN ?
  _PB_D3DBase=*D3D
  
  ProcedureReturn *D3D
EndProcedure



ProcedureDLL AvailableScreenMemory()
  If *D3DDevice9=0:ProcedureReturn 0:EndIf
  ProcedureReturn *D3DDevice9\GetAvailableTextureMem()
EndProcedure



ProcedureDLL ExamineScreenModes()
  ScreenModeIndex=0
  ProcedureReturn NumScreenModes
EndProcedure



ProcedureDLL NextScreenMode()
  If ScreenModeIndex>=NumScreenModes
    ScreenModeWidth=0
    ScreenModeHeight=0
    ScreenModeRefreshRate=0
    ScreenModeDepth=0
    ProcedureReturn 0
  EndIf
  
  *ScreenModesPtr.PB_ScreenMode=*ScreenModes+SizeOf(PB_ScreenMode)*ScreenModeIndex
  
  ScreenModeWidth=*ScreenModesPtr\ScreenModeWidth
  ScreenModeHeight=*ScreenModesPtr\ScreenModeHeight
  ScreenModeRefreshRate=*ScreenModesPtr\ScreenModeRefreshRate
  ScreenModeDepth=*ScreenModesPtr\ScreenModeDepth
  ScreenModeIndex+1
  ProcedureReturn 1
EndProcedure

ProcedureDLL ScreenModeWidth()
  ProcedureReturn ScreenModeWidth
EndProcedure

ProcedureDLL ScreenModeHeight()
  ProcedureReturn ScreenModeHeight
EndProcedure

ProcedureDLL ScreenModeRefreshRate()
  ProcedureReturn ScreenModeRefreshRate
EndProcedure

ProcedureDLL ScreenModeDepth()
  ProcedureReturn ScreenModeDepth
EndProcedure



ProcedureDLL OpenWindowedScreen(WindowID,x,y,Width,Height,AutoStretch,RightOffset,BottomOffset)
  CloseScreen() ; make sure that only one screen is open at one time
  
  If IsWindow_(WindowID)=0:ProcedureReturn 0:EndIf
  Screen_OldWndCB=SetWindowLong_(WindowID,#GWL_WNDPROC,@___WndCB())
  
  ;Init Keyboard:
  
  If Screen_InitKeyboard
    DIK8_CreateDevice(WindowID)
    ;If DIK8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If Screen_InitMouse
    DIM8_CreateDevice(WindowID)
    ;If DIM8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If Screen_InitJoystick
    DIJ8_CreateDevice(WindowID)
    ;If DIJ8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If Screen_InitSound
    DS8_CreateDevice(WindowID)
    ;If DS8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  Flags=#H_DEVICE_LOCKABLE|#H_DEVICE_DISABLEVSYNC
  If DeviceFlags<>0:Flags=DeviceFlags:EndIf
  result=H_Fill_D3DPRESENT_PARAMETERS(d3dpp,*D3D,WindowID,Width,Height,1,0,Flags)
  If result:DIK8_FreeDevice():ProcedureReturn 0:EndIf
  
  result=*D3D\GetDeviceCaps(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,d3dcaps)
  If result:ProcedureReturn 0:EndIf
  
  ;BehaviorFlags=#D3DCREATE_HARDWARE_VERTEXPROCESSING
  ;--
  
  ;BehaviorFlags=#D3DCREATE_SOFTWARE_VERTEXPROCESSING
  ;If d3dcaps\DevCaps&#D3DDEVCAPS_HWTRANSFORMANDLIGHT
  ;  BehaviorFlags=#D3DCREATE_HARDWARE_VERTEXPROCESSING
  ;  If d3dcaps\DevCaps&#D3DDEVCAPS_PUREDEVICE
  ;    BehaviorFlags=#D3DCREATE_HARDWARE_VERTEXPROCESSING|#D3DCREATE_PUREDEVICE
  ;  EndIf
  ;EndIf
  
  
  ;REMOVE THIS:
  
  BehaviorFlags=#D3DCREATE_SOFTWARE_VERTEXPROCESSING
  
  If d3dcaps\DevCaps&#D3DDEVCAPS_HWTRANSFORMANDLIGHT
    BehaviorFlags=#D3DCREATE_MIXED_VERTEXPROCESSING
  EndIf
  
  result=*D3D\CreateDevice(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,WindowID,BehaviorFlags,d3dpp,@*D3DDevice9)
  If result:ProcedureReturn 0:EndIf
  
  *D3D\GetAdapterDisplayMode(#D3DADAPTER_DEFAULT,ScreenInfo.D3DDISPLAYMODE)
  
  Screen_RefreshRate=ScreenInfo\RefreshRate
  If Screen_RefreshRate=0:Screen_RefreshRate=60:EndIf
  
  _PB_Screen_Width=Width
  _PB_Screen_Height=Height
  _PB_Screen_RealWidth=Width
  _PB_Screen_RealHeight=Height
  Screen_Target=-1
  
  _PB_Screen_WindowedXOffset=x
  _PB_Screen_WindowedYOffset=y
  _PB_Screen_AutoStretch=AutoStretch
  _PB_Screen_WindowedRightBorder=RightOffset
  _PB_Screen_WindowedBottomBorder=BottomOffset
  IsScreenActive=1
  
  If ___CreatePixelShader()
    UsePixelShader14=1
  EndIf
  
  *D3DDevice9\GetBackBuffer(0,0,#D3DBACKBUFFER_TYPE_MONO,@*BackBuffer)
  
  *D3DDevice9\Clear(0,0,#D3DCLEAR_TARGET,0,0,0)
  
  ;*D3DDevice9\SetRenderState(#D3DRS_CULLMODE,#D3DCULL_NONE)
  ;*D3DDevice9\SetRenderState(#D3DRS_CLIPPING,0)
  ;*D3DDevice9\SetRenderState(#D3DRS_SHADEMODE,#D3DSHADE_FLAT)
  
  _PB_Screen_Windowed=1
  _PB_Direct3D_Device=*D3DDevice9
  
  ___PrepareD3D9Device()
  
  ProcedureReturn *D3DDevice9
EndProcedure



ProcedureDLL OpenScreen(Width,Height,Depth,Title$)
  CloseScreen() ; make sure that only one screen is open at one time
  
  WindowID=H_CreateScreenWindow(Width,Height,1,Title$)
  
  If Screen_InitKeyboard
    DIK8_CreateDevice(WindowID)
    ;If DIK8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If Screen_InitMouse
    DIM8_CreateDevice(WindowID)
    ;If DIM8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If Screen_InitJoystick
    DIJ8_CreateDevice(WindowID)
    ;If DIJ8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If Screen_InitSound
    DS8_CreateDevice(WindowID)
    ;If DS8_CreateDevice(WindowID)=0:ProcedureReturn 0:EndIf
  EndIf
  
  Flags=#H_DEVICE_LOCKABLE|#H_DEVICE_DISABLEVSYNC
  If DeviceFlags<>0:Flags=DeviceFlags:EndIf
  result=H_Fill_D3DPRESENT_PARAMETERS(d3dpp,*D3D,WindowID,Width,Height,0,Depth,Flags); |#H_DEVICE_QUADRUPLEBUFFERING
  If result:ProcedureReturn 0:EndIf
  
  result=*D3D\GetDeviceCaps(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,d3dcaps)
  If result:ProcedureReturn 0:EndIf
  
  ;BehaviorFlags=#D3DCREATE_SOFTWARE_VERTEXPROCESSING
  
  ;  BehaviorFlags=#D3DCREATE_SOFTWARE_VERTEXPROCESSING
  ;If d3dcaps\DevCaps&#D3DDEVCAPS_HWTRANSFORMANDLIGHT
  ;  BehaviorFlags=#D3DCREATE_HARDWARE_VERTEXPROCESSING
  ;  If d3dcaps\DevCaps&#D3DDEVCAPS_PUREDEVICE
  ;    BehaviorFlags=#D3DCREATE_HARDWARE_VERTEXPROCESSING|#D3DCREATE_PUREDEVICE
  ;  EndIf
  ;EndIf
  
  
  BehaviorFlags=#D3DCREATE_SOFTWARE_VERTEXPROCESSING
  
  If d3dcaps\DevCaps&#D3DDEVCAPS_HWTRANSFORMANDLIGHT
    BehaviorFlags=#D3DCREATE_MIXED_VERTEXPROCESSING
  EndIf
  
  result=*D3D\CreateDevice(#D3DADAPTER_DEFAULT,#D3DDEVTYPE_HAL,WindowID,BehaviorFlags,d3dpp,@*D3DDevice9)
  If result:ProcedureReturn 0:EndIf
  
  *D3D\GetAdapterDisplayMode(#D3DADAPTER_DEFAULT,ScreenInfo.D3DDISPLAYMODE)
  
  Screen_RefreshRate=ScreenInfo\RefreshRate
  If Screen_RefreshRate=0:Screen_RefreshRate=60:EndIf
  
  _PB_Screen_Width=Width
  _PB_Screen_Height=Height
  _PB_Screen_RealWidth=Width
  _PB_Screen_RealHeight=Height
  _PB_Screen_Windowed=0
  _PB_Direct3D_Device=*D3DDevice9
  Screen_Target=-1
  IsScreenActive=1
  
  If ___CreatePixelShader()
    UsePixelShader14=1
  EndIf
  
  *D3DDevice9\GetBackBuffer(0,0,#D3DBACKBUFFER_TYPE_MONO,@*BackBuffer)
  *D3DDevice9\Clear(0,0,#D3DCLEAR_TARGET,0,0,0)
  
  SetCursor_(0) ; hide cursor
  
  ___PrepareD3D9Device()
  
  ProcedureReturn *D3DDevice9
EndProcedure



ProcedureDLL ClearScreen(Color)
  ;-> test if can be called between BeginScene()...EndScene()
  If *D3DDevice9=0 Or IsScreenActive=0:ProcedureReturn 0:EndIf
  If BeginScene
    BeginScene=#False
    *D3DDevice9\EndScene()
  EndIf
  
  If *D3DDevice9\Clear(0,0,#D3DCLEAR_TARGET,Color>>16+(Color&$FF00)+(Color&$FF)<<16,0,0)=#D3D_OK
    ProcedureReturn #True
  EndIf
EndProcedure



ProcedureDLL ScreenID()
  ProcedureReturn d3dpp\hDeviceWindow
EndProcedure



ProcedureDLL IsScreenActive()
  If *D3DDevice9=0 Or IsScreenActive=0:ProcedureReturn #False:EndIf
  If IsWindow_(d3dpp\hDeviceWindow)=0:ProcedureReturn #False:EndIf
  If IsIconic_(d3dpp\hDeviceWindow):ProcedureReturn #False:EndIf
  
  ;If d3dpp\Windowed=0
  If GetForegroundWindow_()<>d3dpp\hDeviceWindow:ProcedureReturn #False:EndIf
  ;Else
  ;  DC=GetWindowDC_(d3dpp\hDeviceWindow)
  ;  If DC=0:ProcedureReturn 0:EndIf
  ;  GetWindowRect_(d3dpp\hDeviceWindow,re.rect)
  ;  re\right=re\right-re\left
  ;  re\left=0
  ;  re\bottom=re\bottom-re\Top
  ;  re\Top=0
  ;  Visible=RectVisible_(DC,re)
  ;  ReleaseDC_(d3dpp\hDeviceWindow,DC)
  ;  If Visible=0:ProcedureReturn 0:EndIf
  ;EndIf
  
  If *D3DDevice9\TestCooperativeLevel():ProcedureReturn #False:EndIf
  
  ProcedureReturn #True
EndProcedure



ProcedureDLL FlipBuffers2(Mode)
  If *D3DDevice9=0:IsScreenActive=0:ProcedureReturn 0:EndIf
  
  If IsWindow_(d3dpp\hDeviceWindow)=0:IsScreenActive=0:ProcedureReturn 0:EndIf
  
  If d3dpp\Windowed=0 ; Process events... only for fullscreen mode (in windowed mode WindowEvent() must be used)
    PeekMessage_(msg.MSG,hWnd,0,0,#PM_REMOVE) 
    TranslateMessage_(msg) 
    DispatchMessage_(msg)
  EndIf
  
  result=*D3DDevice9\TestCooperativeLevel()
  If result=#D3DERR_DRIVERINTERNALERROR:IsScreenActive=0:ProcedureReturn 0:EndIf
  
  If result=#D3DERR_DEVICELOST
    TimeOut=GetTickCount_()
    Repeat
      Sleep_(1)
      result=*D3DDevice9\TestCooperativeLevel()
      If result=#D3DERR_DRIVERINTERNALERROR:IsScreenActive=0:ProcedureReturn 0:EndIf
    Until result=#D3DERR_DEVICENOTRESET Or result=#D3D_OK Or GetTickCount_()-TimeOut>32
    If result=#D3DERR_DEVICELOST:IsScreenActive=0:ProcedureReturn 0:EndIf
  EndIf
  
  If result=#D3DERR_DEVICENOTRESET ;Restore Device
    ;----> Free all Default Pool ressources <----
    O_EnumAllEntries(SpriteList,@___FreeDefaultPoolRes())
    *BackBuffer\Release() ; don't forget to free the backbuffer, or we can't reset the device
    If *D3DDevice9\Reset(d3dpp):IsScreenActive=0:ProcedureReturn 0:EndIf
    ;----> Recreate Default Pool ressources <----
    O_EnumAllEntries(SpriteList,@___RestoreDefaultPoolRes())
    *D3DDevice9\GetBackBuffer(0,0,#D3DBACKBUFFER_TYPE_MONO,@*BackBuffer)
    
    ___PrepareD3D9Device()
    AlphaBlendState=1:*D3DDevice9\SetRenderState(#D3DRS_ALPHABLENDENABLE,1)
    SrcBlendMode=#D3DBLEND_SRCALPHA:*D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,#D3DBLEND_SRCALPHA)
    DestBlendMode=#D3DBLEND_INVSRCALPHA:*D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,#D3DBLEND_INVSRCALPHA)
    CurrentFVF=#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW:*D3DDevice9\SetFVF(#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
    ;BackBufferPitch=0
    BeginScene=0 ;?
    
  EndIf
  
  If BeginScene
    BeginScene=#False
    *D3DDevice9\EndScene()
  EndIf
  
  Select Mode
    Case 0
      H_Wait(*D3DDevice9,0,Screen_FrameRate,0) ; Speed optimized / Wait for Framerate
    Case 2
      H_Wait(*D3DDevice9,Screen_RefreshRate,Screen_FrameRate,1) ; CPU usage Optimized / Wait for VBlank / Wait for FrameRate
    Default
      H_Wait(*D3DDevice9,Screen_RefreshRate,Screen_FrameRate,0) ; Speed optimized / Wait for VBlank / Wait for FrameRate
  EndSelect
  
  If d3dpp\Windowed=0
    result=*D3DDevice9\Present(0,0,0,0)
  Else
    re.rect\left=_PB_Screen_WindowedXOffset
    re\Top=_PB_Screen_WindowedYOffset
    
    GetClientRect_(d3dpp\hDeviceWindow,cre.rect)
    
    re\right=cre\right-_PB_Screen_WindowedRightBorder
    re\bottom=cre\bottom-_PB_Screen_WindowedBottomBorder
    
    If _PB_Screen_AutoStretch=0
      sre.rect\left=0
      sre\Top=0
      sre\right=re\right-re\left  
      sre\bottom=re\bottom-re\Top 
    Else
      sre\left=0
      sre\Top=0
      sre\right=_PB_Screen_Width
      sre\bottom=_PB_Screen_Height
    EndIf  
    
    result=*D3DDevice9\Present(sre,re,0,0)
  EndIf
  
  If result=#D3D_OK
    IsScreenActive=1
    ProcedureReturn 1
  EndIf
  
  IsScreenActive=0
EndProcedure

ProcedureDLL FlipBuffers()
  ProcedureReturn FlipBuffers2(1)
EndProcedure



ProcedureDLL SetFrameRate(FrameRate)
  Screen_FrameRate=FrameRate
  ProcedureReturn 1
EndProcedure



ProcedureDLL SetRefreshRate(RefreshRate)
  If *D3DDevice9=0
    Screen_RefreshRate=RefreshRate
    ProcedureReturn 1
  EndIf
  ProcedureReturn 0
EndProcedure



;+
ProcedureDLL ScreenOutput()
  If IsScreenActive=0:ProcedureReturn 0:EndIf
  
  ;we can't get the DC of the Surface while it's locked (other like in DirectX7 :( )
  ;ScreenOutput\Type=2
  
  If BeginScene
    BeginScene=#False
    *D3DDevice9\EndScene() ; needed
  EndIf
  
  ScreenOutput\Type=7 ; outputformat with direct memory access 
  
  ScreenOutput\Width=_PB_Screen_RealWidth
  ScreenOutput\Height=_PB_Screen_RealHeight
  ScreenOutput\Depth=H_D3DFormatToBPP(d3dpp\BackBufferFormat) ; bpp of BackBuffer
  Select d3dpp\BackBufferFormat
    Case #D3DFMT_X8R8G8B8
      ScreenOutput\PixelFormat=#PB_PixelFormat_32Bits_BGR
    Case #D3DFMT_X1R5G5B5
      ScreenOutput\PixelFormat=#PB_PixelFormat_15Bits
    Case #D3DFMT_R5G6B5
      ScreenOutput\PixelFormat=#PB_PixelFormat_16Bits
  EndSelect
  
  ScreenOutput\PixelBuffer=0
  ScreenOutput\Pitch=0
  
  ; If BackBufferPitch=0
  ;    *BackBuffer\LockRect(lr.D3DLOCKED_RECT,0,0)
  ;    BackBufferPitch=lr\Pitch
  ;    *BackBuffer\UnLockRect()
  ;  EndIf
  
  ;  ScreenOutput\Pitch=BackBufferPitch
  ;  If ScreenOutput\Pitch=0
  ;    ProcedureReturn 0
  ;  EndIf
  
  result=*BackBuffer\GetDC(@ScreenOutput\DC)
  If result<>#D3D_OK:ProcedureReturn 0:EndIf
  
  ScreenOutput\StopDirectAccess=@___ScreenStopDirectAccess()
  ScreenOutput\StartDirectAccess=@___ScreenStartDirectAccess()
  
  ScreenOutput\ReleaseProcedure=@___ReleaseScreenOutput()
  ProcedureReturn ScreenOutput
EndProcedure



;+
ProcedureDLL SpriteOutput(Sprite)
  If IsScreenActive=0:ProcedureReturn 0:EndIf
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  *ptr\InvalidCollisionMap=#True
  
  ;-> HERE?
  ;TexRes_GetAndUpdateTexture(*ptr\TexRes)
  
  *SpriteOutputID=*ptr 
  
  SpriteOutput\DC=TexRes_GetDC(*ptr\TexRes)
  If SpriteOutput\DC=0:ProcedureReturn 0:EndIf
  
  SpriteOutput\Type=7
  SpriteOutput\Width=TexRes_Width(*ptr\TexRes)
  SpriteOutput\Height=TexRes_Height(*ptr\TexRes)
  SpriteOutput\Depth=TexRes_Depth(*ptr\TexRes)
  
  ;-Pitch
  ;SpriteOutput\Pitch=TexRes_GetPitch(*ptr\TexRes)
  ;If SpriteOutput\Pitch=0
  ;ProcedureReturn 0
  ;EndIf
  SpriteOutput\Pitch=0
  SpriteOutput\PixelBuffer=0
  
  Select TexRes_Type(*ptr\TexRes)
    Case #TEXRES_STATIC_A8R8G8B8
      SpriteOutput\PixelFormat=#PB_PixelFormat_32Bits_BGR
    Case #TEXRES_DYNAMIC_A1R5G5B5
      SpriteOutput\PixelFormat=#PB_PixelFormat_16Bits
    Case #TEXRES_STATIC_A1R5G5B5
      SpriteOutput\PixelFormat=#PB_PixelFormat_16Bits
  EndSelect
  
  SpriteOutput\StopDirectAccess=@___SpriteStopDirectAccess()
  SpriteOutput\StartDirectAccess=@___SpriteStartDirectAccess()
  SpriteOutput\ReleaseProcedure=@___ReleaseSpriteOutput()
  ProcedureReturn SpriteOutput
EndProcedure



;+
ProcedureDLL DisplayTransparentSprite(Sprite,x,y)
  
  
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  SetRect_(re1.rect,x,y,x+*ptr\Width,y+*ptr\Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
  BeginD3D9Scene()
  If TexRes_NeedPS14(*ptr\TexRes)
    CTrans=TexRes_GetTransColor(*ptr\TexRes)
    EnablePixelShader14(CTrans)
  Else
    DisablePixelShader14()
  EndIf
  
  SetBlendMode(1,#D3DBLEND_SRCALPHA,#D3DBLEND_INVSRCALPHA,#D3DFVF_TEX1|#D3DFVF_XYZRHW)
  
  v.DisplaySprite
  
  v\v[0]\tu=(*ptr\t[0]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[0]\tv=(*ptr\t[0]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  
  v\v[1]\tu=(*ptr\t[1]\tu+(ire\right-re1\right)/*ptr\RealWidth)* *ptr\fU
  v\v[1]\tv=(*ptr\t[1]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  
  v\v[2]\tu=(*ptr\t[2]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[2]\tv=(*ptr\t[2]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight)* *ptr\fV
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  
  v\v[3]\tu=(*ptr\t[3]\tu+(ire\right-re1\right)/*ptr\RealWidth) * *ptr\fU
  v\v[3]\tv=(*ptr\t[3]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight) * *ptr\fV
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  
  *D3DDevice9\SetTexture(0,TexRes_GetUpdatedTexture(*ptr\TexRes))
  ProcedureReturn *D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(DisplaySprite)/4)
EndProcedure


;+
ProcedureDLL DisplayTranslucentSprite(Sprite,x,y,Alpha)
  
  
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  If Alpha=0:ProcedureReturn 0:EndIf 
  
  SetRect_(re1.rect,x,y,x+*ptr\Width,y+*ptr\Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
  BeginD3D9Scene()
  If TexRes_NeedPS14(*ptr\TexRes)
    CTrans=TexRes_GetTransColor(*ptr\TexRes)
    EnablePixelShader14(CTrans)
  Else
    DisablePixelShader14()
  EndIf 
  
  SetBlendMode(1,#D3DBLEND_SRCALPHA,#D3DBLEND_INVSRCALPHA,#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
  
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_TEXTURE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG2,#D3DTA_DIFFUSE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_MODULATE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_MODULATE)
  
  v.DisplaySpriteColor
  
  v\v[0]\Color=$FFFFFF+Alpha<<24
  v\v[1]\Color=$FFFFFF+Alpha<<24
  v\v[2]\Color=$FFFFFF+Alpha<<24
  v\v[3]\Color=$FFFFFF+Alpha<<24
  
  
  v\v[0]\tu=(*ptr\t[0]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[0]\tv=(*ptr\t[0]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  
  v\v[1]\tu=(*ptr\t[1]\tu+(ire\right-re1\right)/*ptr\RealWidth)* *ptr\fU
  v\v[1]\tv=(*ptr\t[1]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  
  v\v[2]\tu=(*ptr\t[2]\tu+(ire\left-re1\left)/*ptr\RealWidth) * *ptr\fU
  v\v[2]\tv=(*ptr\t[2]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight)* *ptr\fV
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  
  v\v[3]\tu=(*ptr\t[3]\tu+(ire\right-re1\right)/*ptr\RealWidth) * *ptr\fU
  v\v[3]\tv=(*ptr\t[3]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight) * *ptr\fV
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  
  
  *D3DDevice9\SetTexture(0,TexRes_GetUpdatedTexture(*ptr\TexRes))
  Result=*D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(DisplaySpriteColor)/4)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1)
  ProcedureReturn Result
EndProcedure


;+
ProcedureDLL DisplaySprite(Sprite,x,y)
  
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  SetRect_(re1.rect,x,y,x+*ptr\Width,y+*ptr\Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
  BeginD3D9Scene()
  
  DisablePixelShader14() 
  
  ;--> disable alphablend better solution ???
  SetBlendMode(1,#D3DBLEND_ONE,#D3DBLEND_ZERO,#D3DFVF_TEX1|#D3DFVF_XYZRHW)
  
  v.DisplaySprite
  
  v\v[0]\tu=(*ptr\t[0]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[0]\tv=(*ptr\t[0]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  
  v\v[1]\tu=(*ptr\t[1]\tu+(ire\right-re1\right)/*ptr\RealWidth)* *ptr\fU
  v\v[1]\tv=(*ptr\t[1]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  
  v\v[2]\tu=(*ptr\t[2]\tu+(ire\left-re1\left)/*ptr\RealWidth) * *ptr\fU
  v\v[2]\tv=(*ptr\t[2]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight)* *ptr\fV
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  
  v\v[3]\tu=(*ptr\t[3]\tu+(ire\right-re1\right)/*ptr\RealWidth) * *ptr\fU
  v\v[3]\tv=(*ptr\t[3]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight) * *ptr\fV
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  
  *D3DDevice9\SetTexture(0,TexRes_GetUpdatedTexture(*ptr\TexRes))
  ProcedureReturn *D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(DisplaySprite)/4)
EndProcedure


;+
ProcedureDLL DisplayRGBFilter(x,y,Width,Height,R,G,B)
  ;--> No checks for speed reason ?
  
  SetRect_(re1.rect,x,y,x+Width,y+Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
  BeginD3D9Scene()
  DisablePixelShader14()
  
  SetBlendMode(1,#D3DBLEND_ONE,#D3DBLEND_ONE,#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG2) ;- needed??
  
  v.RGBFilter
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  v\v[0]\Color=B+G<<8+R<<16 
  
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  v\v[1]\Color=B+G<<8+R<<16 
  
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  v\v[2]\Color=B+G<<8+R<<16 
  
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  v\v[3]\Color=B+G<<8+R<<16
  
  *D3DDevice9\SetTexture(0,0)
  Result=*D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(RGBFilter)/4)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  ProcedureReturn Result
EndProcedure



ProcedureDLL FreeSprite(Sprite)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf 
  If *ptr\FastCollisionMap
    GlobalFree_(*ptr\FastCollisionMap)
    *ptr\FastCollisionMap=0
  EndIf
  *ptr\CollisionMapCreationCount=0
  *ptr\InvalidCollisionMap=#True
  If *ptr\TexRes:TexRes_Free(*ptr\TexRes):EndIf
  If *ptr\TexRes2:TexRes_Free(*ptr\TexRes2):EndIf
  ProcedureReturn O_FreeObject(SpriteList,Sprite)
EndProcedure



ProcedureDLL IsSprite(Sprite)
  ProcedureReturn O_IsObject(SpriteList,Sprite)
EndProcedure



ProcedureDLL SpriteWidth(Sprite)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\Width  ; (RealWidth better ?)
EndProcedure



ProcedureDLL SpriteHeight(Sprite)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\Height  ; (RealHeight better ?)
EndProcedure



ProcedureDLL SpriteDepth(Sprite)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\Mode=#PB_Sprite_Alpha
    ProcedureReturn 8
  EndIf  
  ProcedureReturn *ptr\Depth
EndProcedure



ProcedureDLL CloseScreen()
  
  If *Sprite3DVertexBuffer
    GlobalFree_(*Sprite3DVertexBuffer)
    *Sprite3DVertexBuffer=0
  EndIf
  
  If *Sprite3DIndexBuffer
    GlobalFree_(*Sprite3DIndexBuffer)
    *Sprite3DIndexBuffer=0
  EndIf
  
  If BackBufferSysCopyBitmap
    DeleteObject_(BackBufferSysCopyBitmap)
    BackBufferSysCopyBitmap=0
  EndIf
  
  If SpriteList
    O_EnumAllEntries(SpriteList,@___FreeSpriteCB())   ; Free Sprites
  EndIf
  
  If *BackBuffer:*BackBuffer\Release():*BackBuffer=0:EndIf
  If *D3DDevice9:*D3DDevice9\EndScene():*D3DDevice9\Release():*D3DDevice9=0:EndIf
  DIK8_FreeDevice()
  DIM8_FreeDevice()
  DIJ8_FreeDevice()
  DS8_FreeDevice()
  If _PB_Screen_Windowed=0
    H_FreeScreenWindow(d3dpp\hDeviceWindow)
  EndIf
EndProcedure


ProcedureDLL Sprite_End()
  CloseScreen()
  If *ScreenModes:FreeMemory(*ScreenModes):*ScreenModes=0:EndIf
  If SoundList:O_Free(SoundList):SoundList=0:EndIf
  If SpriteList:O_Free(SpriteList):SpriteList=0:EndIf
  If SpriteList3D:O_Free(SpriteList3D):SpriteList3D=0:EndIf
  ;H_FreeD3DXDLL()
  If *D3D:*D3D\Release():*D3D=0:EndIf
  DIK8_FreeKeyboard()
  DIM8_FreeMouse()
  DIJ8_FreeJoystick()
  DS8_FreeSound()
  TexRes_End()
EndProcedure
  


ProcedureDLL CreateSprite2(Sprite,Width,Height,Mode)
  If Width<=0 Or Height<=0:ProcedureReturn 0:EndIf
  If Mode=#PB_Sprite_Alpha:ProcedureReturn 0:EndIf
  *ptr.PB_DX9Sprite=___CreateSprite(Sprite,Width,Height,Mode)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  If Sprite=#PB_Any
    If ___ClearSprite(*ptr,0,0,Width+1,Height+1,#Black) ; why the hell +1
      ProcedureReturn *ptr
    Else
      FreeSprite(*ptr)
      ProcedureReturn 0
    EndIf
  Else
    If ___ClearSprite(Sprite,0,0,Width+1,Height+1,#Black) ; why the hell +1
      ProcedureReturn *ptr\TexRes
    Else
      FreeSprite(Sprite)
      ProcedureReturn 0
    EndIf
  EndIf
  
EndProcedure


ProcedureDLL CreateSprite(Sprite,Width,Height)
  ProcedureReturn CreateSprite2(Sprite,Width,Height,0)
EndProcedure

ProcedureDLL LoadSprite2(Sprite,File.s,Mode.l)
  bpp=16
  If Mode&#PB_Sprite_Alpha:bpp=8:EndIf
  If Mode&#PB_Sprite_AlphaBlending:bpp=32:EndIf
  
  hBmp=_PB_LoadImage(0,File.s,bpp,ds.DIBSECTION)
  
  iW=ds\dsBm\bmWidth
  iH=ds\dsBm\bmHeight
  
  If hBmp=0:ProcedureReturn 0:EndIf
  
  If Mode=#PB_Sprite_Alpha
    *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,#PB_Sprite_AlphaBlending|#PB_Sprite_Texture)
    If *ptr  
      *ptr\TexRes2=TexRes_CreateTexture(*D3DDevice9,iW,iH,#TEXRES_STATIC_A8R8G8B8,0); ?   
      *ptr\Mode=#PB_Sprite_Alpha
    EndIf
  Else
    
    If Mode=0
      
      TexRes_DisableTransparentColorUpdate(#True) 
      *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,Mode)
      TexRes_DisableTransparentColorUpdate(#False)
      
      
      If TexRes_Type(*ptr\TexRes)<>#TEXRES_STATIC_A1R5G5B5 ; If it's not a static sprite we must free it and create new one
        If Sprite=#PB_Any:FreeSprite(*ptr):Else:FreeSprite(Sprite):EndIf
        *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,Mode)
      EndIf
      
    Else
      *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,Mode)
    EndIf
    
  EndIf
  
  If *ptr=0
    DeleteObject_(hBmp)
    ProcedureReturn 0
  EndIf
  
  If TexRes_Type(*ptr\TexRes)=#TEXRES_STATIC_A1R5G5B5
    lockOk=TexRes_StaticInitLock(*ptr\TexRes,@*destptr.l,@destpitch.l)
  Else
    lockOk=TexRes_Lock(*ptr\TexRes,0,@*destptr.l,@destpitch.l)
    
  EndIf
  
  
  If Mode&#PB_Sprite_Alpha And lockOk
    
    lockOk=TexRes_Lock(*ptr\TexRes2,0,@*destptr2.l,@destpitch2.l)
  EndIf
  
  If lockOk=#False
    
    If Sprite=#PB_Any
      FreeSprite(*ptr)
    Else
      FreeSprite(Sprite)
    EndIf
    DeleteObject_(hBmp)
    ProcedureReturn 0
  EndIf
  
  For y=0 To iH-1
    
    Select bpp
      Case 8
        For x=0 To iW-1
          *sptrb.BYTE=ds\dsBm\bmBits+((iH-1)*ds\dsBm\bmWidthBytes)+y*-ds\dsBm\bmWidthBytes+x
          *dptrl.LONG=*destptr+y*destpitch+x<<2  
          *dptrl2.LONG=*destptr2+y*destpitch2+x<<2       
          val=(*sptrb\b&$FF)
          valalpha=Abs(val-128)
          
          *dptrl\l=valalpha<<24+val<<16+val<<8+val
          If val=0
            *dptrl2\l=0
          Else
            *dptrl2\l=255<<24
          EndIf
        Next
        
      Case 16
        
        ;-> API BUG? (WIN 2000)
        ; If width is odd here, the sprite is displayed wrong!!!
        ; win api bug, because pitch seems to be wrong ?!?!
        ;Correct the pitch, because it must dividable through 4...
        If ds\dsBm\bmWidthBytes%4
          ds\dsBm\bmWidthBytes=ds\dsBm\bmWidthBytes+4-(ds\dsBm\bmWidthBytes+4)%4
        EndIf
        
        
        CopyMemory(ds\dsBm\bmBits+ds\dsBm\bmWidthBytes*(iH-y-1),*destptr+y*destpitch,iW*2)
        ;*sptrw.WORD=ds\dsBm\bmBits+((iH-1)*ds\dsBm\bmWidthBytes)+y*-ds\dsBm\bmWidthBytes+x<<1
        ;*dptrw.WORD=*destptr+y*destpitch+x<<1    
        ;*dptrw\w=*sptrw\w
      Case 32
        CopyMemory(ds\dsBm\bmBits+ds\dsBm\bmWidthBytes*(iH-y-1),*destptr+y*destpitch,iW*4)  
        ;*sptrl.LONG=ds\dsBm\bmBits+((iH-1)*ds\dsBm\bmWidthBytes)+y*-ds\dsBm\bmWidthBytes+x<<2
        ;*dptrl.LONG=*destptr+y*destpitch+x<<2  
        ;*dptrl\l=*sptrl\l
    EndSelect      
    
  Next
  
  
  If TexRes_Type(*ptr\TexRes)=#TEXRES_STATIC_A1R5G5B5
    TexRes_StaticInitUnLock(*ptr\TexRes,*destptr.l,destpitch.l)
  Else
    TexRes_UnLock(*ptr\TexRes,0)
  EndIf  
  
  If Mode&#PB_Sprite_Alpha
    TexRes_UnLock(*ptr\TexRes2,0)
  EndIf
  DeleteObject_(hBmp)   
  
  If Sprite=#PB_Any
    ProcedureReturn *ptr
  EndIf
  ProcedureReturn *ptr\TexRes
EndProcedure

ProcedureDLL LoadSprite(Sprite,File$)
  ProcedureReturn LoadSprite2(Sprite,File$,0)
EndProcedure

ProcedureDLL CatchSprite2(Sprite,Addr,Mode)
  bpp=16
  If Mode&#PB_Sprite_Alpha:bpp=8:EndIf
  If Mode&#PB_Sprite_AlphaBlending:bpp=32:EndIf
  
  hBmp=_PB_LoadImage(Addr,"",bpp,ds.DIBSECTION) ; this is the only line we must change for catchsprite
  
  iW=ds\dsBm\bmWidth
  iH=ds\dsBm\bmHeight
  
  If hBmp=0:ProcedureReturn 0:EndIf
  
  If Mode=#PB_Sprite_Alpha
    *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,#PB_Sprite_AlphaBlending|#PB_Sprite_Texture)
    If *ptr  
      *ptr\TexRes2=TexRes_CreateTexture(*D3DDevice9,iW,iH,#TEXRES_STATIC_A8R8G8B8,0); ?   
      *ptr\Mode=#PB_Sprite_Alpha
    EndIf
  Else
    
    If Mode=0
      
      TexRes_DisableTransparentColorUpdate(#True) 
      *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,Mode)
      TexRes_DisableTransparentColorUpdate(#False)
      
      
      If TexRes_Type(*ptr\TexRes)<>#TEXRES_STATIC_A1R5G5B5 ; If it's not a static sprite we must free it and create new one
        If Sprite=#PB_Any:FreeSprite(*ptr):Else:FreeSprite(Sprite):EndIf
        *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,Mode)
      EndIf
      
    Else
      *ptr.PB_DX9Sprite=___CreateSprite(Sprite,iW,iH,Mode)
    EndIf
    
  EndIf
  
  If *ptr=0
    DeleteObject_(hBmp)
    ProcedureReturn 0
  EndIf
  
  If TexRes_Type(*ptr\TexRes)=#TEXRES_STATIC_A1R5G5B5
    lockOk=TexRes_StaticInitLock(*ptr\TexRes,@*destptr.l,@destpitch.l)
  Else
    lockOk=TexRes_Lock(*ptr\TexRes,0,@*destptr.l,@destpitch.l)
    
  EndIf
  
  
  If Mode&#PB_Sprite_Alpha And lockOk
    
    lockOk=TexRes_Lock(*ptr\TexRes2,0,@*destptr2.l,@destpitch2.l)
  EndIf
  
  If lockOk=#False
    
    If Sprite=#PB_Any
      FreeSprite(*ptr)
    Else
      FreeSprite(Sprite)
    EndIf
    DeleteObject_(hBmp)
    ProcedureReturn 0
  EndIf
  
  For y=0 To iH-1
    
    Select bpp
      Case 8
        For x=0 To iW-1
          *sptrb.BYTE=ds\dsBm\bmBits+((iH-1)*ds\dsBm\bmWidthBytes)+y*-ds\dsBm\bmWidthBytes+x
          *dptrl.LONG=*destptr+y*destpitch+x<<2  
          *dptrl2.LONG=*destptr2+y*destpitch2+x<<2       
          val=(*sptrb\b&$FF)
          valalpha=Abs(val-128)
          
          *dptrl\l=valalpha<<24+val<<16+val<<8+val
          If val=0
            *dptrl2\l=0
          Else
            *dptrl2\l=255<<24
          EndIf
        Next
        
      Case 16
        
        ;-> API BUG? (WIN 2000)
        ; If width is odd here, the sprite is displayed wrong!!!
        ; win api bug, because pitch seems to be wrong ?!?!
        ;Correct the pitch, because it must dividable through 4...
        If ds\dsBm\bmWidthBytes%4
          ds\dsBm\bmWidthBytes=ds\dsBm\bmWidthBytes+4-(ds\dsBm\bmWidthBytes+4)%4
        EndIf
        
        CopyMemory(ds\dsBm\bmBits+ds\dsBm\bmWidthBytes*(iH-y-1),*destptr+y*destpitch,iW*2)
        ;*sptrw.WORD=ds\dsBm\bmBits+((iH-1)*ds\dsBm\bmWidthBytes)+y*-ds\dsBm\bmWidthBytes+x<<1
        ;*dptrw.WORD=*destptr+y*destpitch+x<<1    
        ;*dptrw\w=*sptrw\w
      Case 32
        CopyMemory(ds\dsBm\bmBits+ds\dsBm\bmWidthBytes*(iH-y-1),*destptr+y*destpitch,iW*4)  
        ;*sptrl.LONG=ds\dsBm\bmBits+((iH-1)*ds\dsBm\bmWidthBytes)+y*-ds\dsBm\bmWidthBytes+x<<2
        ;*dptrl.LONG=*destptr+y*destpitch+x<<2  
        ;*dptrl\l=*sptrl\l
    EndSelect      
    
  Next
  
  
  If TexRes_Type(*ptr\TexRes)=#TEXRES_STATIC_A1R5G5B5
    TexRes_StaticInitUnLock(*ptr\TexRes,*destptr.l,destpitch.l)
  Else
    TexRes_UnLock(*ptr\TexRes,0)
  EndIf  
  
  If Mode&#PB_Sprite_Alpha
    TexRes_UnLock(*ptr\TexRes2,0)
  EndIf
  DeleteObject_(hBmp)   
  
  If Sprite=#PB_Any
    ProcedureReturn *ptr
  EndIf
  ProcedureReturn *ptr\TexRes
EndProcedure


ProcedureDLL CatchSprite(Sprite,Addr)
  ProcedureReturn CatchSprite2(Sprite,Addr,0)
EndProcedure





ProcedureDLL TransparentSpriteColor(Sprite,Color)
  
  If Sprite=-1
    DefaultTransColor=Color&$FFFFFF
    ProcedureReturn 1
  EndIf
  
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  ;--> if SpriteTarget=Sprite ???
  ;*D3DDevice9\EndScene()
  ProcedureReturn TexRes_SetTransColor(*ptr\TexRes,Color&$FFFFFF)
  ;*D3DDevice9\BeginScene()
EndProcedure



ProcedureDLL ClipSprite(Sprite,x,y,Width,Height)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  If Width=-1:Width=*ptr\RealWidth:EndIf
  If Height=-1:Height=*ptr\RealHeight:EndIf
  
  If x<0:x=0:EndIf
  If y<0:y=0:EndIf
  
  If Width<0:Width=0:EndIf
  If Height<0:Height=0:EndIf
  
  If x>*ptr\RealWidth:x=*ptr\RealWidth:EndIf
  If y>*ptr\RealHeight:y=*ptr\RealHeight:EndIf
  
  If x+Width>*ptr\RealWidth:Width=*ptr\RealWidth-x:EndIf
  If y+Height>*ptr\RealHeight:Height=*ptr\RealHeight-y:EndIf
  
  *ptr\t[0]\tu=x/*ptr\RealWidth
  *ptr\t[0]\tv=y/*ptr\RealHeight
  
  *ptr\t[1]\tu=(x+Width)/*ptr\RealWidth
  *ptr\t[1]\tv=y/*ptr\RealHeight
  
  *ptr\t[2]\tu=x/*ptr\RealWidth
  *ptr\t[2]\tv=(y+Height)/*ptr\RealHeight
  
  *ptr\t[3]\tu=(x+Width)/*ptr\RealWidth
  *ptr\t[3]\tv=(y+Height)/*ptr\RealHeight 
  
  *ptr\ClipX=x
  *ptr\ClipY=y
  *ptr\Width=Width
  *ptr\Height=Height
  ProcedureReturn #True
EndProcedure



ProcedureDLL SaveSprite3(Sprite,File$,Format,Flags)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  Image=CreateImage(#PB_Any,*ptr\Width,*ptr\Height,32)
  If Image=0:ProcedureReturn 0:EndIf
  
  DstDC=StartDrawing(ImageOutput(Image))
  If DstDC=0:FreeImage(Image):ProcedureReturn 0:EndIf
  SrcDC=TexRes_GetDC(*ptr\TexRes)
  If SrcDC=0:StopDrawing():FreeImage(Image):ProcedureReturn 0:EndIf
  result=BitBlt_(DstDC,0,0,*ptr\Width,*ptr\Height,SrcDC,0,0,#SRCCOPY)
  TexRes_ReleaseDC(*ptr\TexRes,1)
  StopDrawing()
  If result=0:FreeImage(Image):ProcedureReturn 0:EndIf
  result=SaveImage(Image,File$,Format,Flags)
  FreeImage(Image)
  ProcedureReturn result
EndProcedure

ProcedureDLL SaveSprite2(Sprite,File$,Format)
  ProcedureReturn SaveSprite3(Sprite,File$,Format,0)
EndProcedure

ProcedureDLL SaveSprite(Sprite,File$)
  ProcedureReturn SaveSprite3(Sprite,File$,#PB_ImagePlugin_BMP,0)
EndProcedure


ProcedureDLL StartSpecialFX()
  ProcedureReturn 1
EndProcedure



ProcedureDLL StopSpecialFX()
  ProcedureReturn 1
EndProcedure

ProcedureDLL ChangeGamma(R,G,B,Flags)
  If IsScreenActive=0:ProcedureReturn 0:EndIf
  
  If Flags=1 Or _PB_Screen_Windowed
    ProcedureReturn 0
  EndIf
  gamma.GAMMARAMP
  
  R<<8
  G<<8
  B<<8
  For c=0 To 255
    
    If GammaRed<R:GammaRed+256:EndIf
    If GammaGreen<G:GammaGreen+256:EndIf
    If GammaBlue<B:GammaBlue+256:EndIf
    
    gamma\Red[c]=GammaRed
    gamma\Green[c]=GammaGreen
    gamma\Blue[c]=GammaBlue
  Next
  *D3DDevice9\SetGammaRamp(0,1,gamma)
EndProcedure


ProcedureDLL SpriteCollision(Sprite1,x1,y1,Sprite2,x2,y2)
  *s1ptr.PB_DX9Sprite=IsSprite(Sprite1)
  If *s1ptr=0:ProcedureReturn 0:EndIf
  *s2ptr.PB_DX9Sprite=IsSprite(Sprite2)
  If *s2ptr=0:ProcedureReturn 0:EndIf
  SetRect_(re1.rect,x1,y1,x1+*s1ptr\Width,y1+*s1ptr\Height)
  SetRect_(re2.rect,x2,y2,x2+*s2ptr\Width,y2+*s2ptr\Height)
  ProcedureReturn IntersectRect_(ire.rect,re1,re2)
EndProcedure




ProcedureDLL SpritePixelCollision(Sprite1,x1,y1,Sprite2,x2,y2)
  
  *s1ptr.PB_DX9Sprite=IsSprite(Sprite1)
  *s2ptr.PB_DX9Sprite=IsSprite(Sprite2)
  If *s2ptr=0 Or *s1ptr=0:ProcedureReturn 0:EndIf
  If *s2ptr\Depth<>16 Or *s1ptr\Depth<>16:ProcedureReturn 0:EndIf    
  
  ; Check first if we can use the fast collision...
  If ___CreateSpriteCollisionMap(*s1ptr) And ___CreateSpriteCollisionMap(*s2ptr)
    ProcedureReturn ___SpriteCollisionMapPixelCollision(*s1ptr,x1,y1,*s2ptr,x2,y2)
  EndIf
  
  ; use the slow method...
  
  If Sprite1=Sprite2
    
    SetRect_(re1.rect,x1,y1,x1+*s1ptr\Width,y1+*s1ptr\Height)
    SetRect_(re2.rect,x2,y2,x2+*s1ptr\Width,y2+*s1ptr\Height)
    x1-*s1ptr\ClipX
    x2-*s1ptr\ClipX
    y1-*s1ptr\ClipY
    y2-*s1ptr\ClipY 
    If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
    result=TexRes_Lock(*s1ptr\TexRes,1,@s1buffer,@s1bufferpitch)
    If result=0:ProcedureReturn 0:EndIf
    
    TransparentColor=TexRes_GetTransColor(*s1ptr\TexRes) 
    s1buffertrans.w=(TransparentColor>>16)>>3+(((TransparentColor&$FF00)>>8)>>2)<<5+((TransparentColor&$FF)>>3)<<11
    
    ;--> not really good optimized
    For y=ire\Top To ire\bottom-1 
      x=ire\left
      length.l=(ire\right-1)-x
      *s1bufferptr.WORD=s1buffer+(y-y1)*s1bufferpitch+(x-x1)*2
      *s2bufferptr.WORD=s1buffer+(y-y2)*s1bufferpitch+(x-x2)*2
      For x= 0 To length
        ;WHY THE HELL IS &$7FFF NEDDED ???
        If (*s1bufferptr\w)<>s1buffertrans And (*s2bufferptr\w)<>s1buffertrans 
          TexRes_UnLock(*s1ptr\TexRes,1)
          ProcedureReturn #True
        EndIf 
        *s1bufferptr+2
        *s2bufferptr+2
      Next
    Next
    
    TexRes_UnLock(*s1ptr\TexRes,1)
    
    
  Else
    SetRect_(re1.rect,x1,y1,x1+*s1ptr\Width,y1+*s1ptr\Height)
    SetRect_(re2.rect,x2,y2,x2+*s2ptr\Width,y2+*s2ptr\Height)
    x1-*s1ptr\ClipX
    x2-*s2ptr\ClipX
    y1-*s1ptr\ClipY
    y2-*s2ptr\ClipY
    If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
    result=TexRes_Lock(*s1ptr\TexRes,1,@s1buffer,@s1bufferpitch)
    If result=0:ProcedureReturn 0:EndIf
    result=TexRes_Lock(*s2ptr\TexRes,1,@s2buffer,@s2bufferpitch)
    If result=0:TexRes_UnLock(*s1ptr\TexRes,1):ProcedureReturn 0:EndIf
    
    TransparentColor=TexRes_GetTransColor(*s1ptr\TexRes) 
    s1buffertrans.w=(TransparentColor>>16)>>3+(((TransparentColor&$FF00)>>8)>>2)<<5+((TransparentColor&$FF)>>3)<<11
    ;s1buffertrans.w=(TransparentColor&$FF)>>3+(((TransparentColor&$FF00)>>8)>>3)<<5+((TransparentColor>>16)>>3)<<10
    
    
    TransparentColor=TexRes_GetTransColor(*s2ptr\TexRes) 
    ;s2buffertrans.w=(TransparentColor&$FF)>>3+(((TransparentColor&$FF00)>>8)>>3)<<5+((TransparentColor>>16)>>3)<<10
    s2buffertrans.w=(TransparentColor>>16)>>3+(((TransparentColor&$FF00)>>8)>>2)<<5+((TransparentColor&$FF)>>3)<<11
    
    ;--> not really good optimized
    For y=ire\Top To ire\bottom-1
      x=ire\left
      length.l=(ire\right-1)-x
      *s1bufferptr.WORD=s1buffer+(y-y1)*s1bufferpitch+(x-x1)*2
      *s2bufferptr.WORD=s2buffer+(y-y2)*s2bufferpitch+(x-x2)*2
      For x= 0 To length
        
        If (*s1bufferptr\w)<>s1buffertrans And (*s2bufferptr\w)<>s2buffertrans 
          TexRes_UnLock(*s1ptr\TexRes,1)
          TexRes_UnLock(*s2ptr\TexRes,1)        
          ProcedureReturn 1
        EndIf 
        *s1bufferptr+2
        *s2bufferptr+2
      Next
    Next
    
    TexRes_UnLock(*s1ptr\TexRes,1)
    TexRes_UnLock(*s2ptr\TexRes,1)
  EndIf
  
EndProcedure




ProcedureDLL UseBuffer(Sprite)
  If Sprite=Screen_Target:ProcedureReturn 1:EndIf
  
  If Screen_Target<>-1
    *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Screen_Target)
    If *ptr=0:ProcedureReturn 0:EndIf
    *ptr\InvalidCollisionMap=#True
    TexRes_UpdateFromRT(*ptr\TexRes)
  EndIf
  
  If Sprite<>-1
    
    *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
    If *ptr=0:ProcedureReturn 0:EndIf
    
    result=TexRes_Optimize(*ptr\TexRes,UsePixelShader14) ; try to optimize the Texture
    If result:*ptr\TexRes=result:EndIf
    
    ;*D3DDevice9\EndScene() 
    ;-> HERE
    ;TexRes_GetAndUpdateTexture(*ptr\TexRes)
    
    result=*D3DDevice9\SetRenderTarget(0,TexRes_GetRTSurface(*ptr\TexRes))   
    ;*D3DDevice9\BeginScene()
    If result<>#D3D_OK:ProcedureReturn 0:EndIf
    
    Screen_Target=Sprite
    _PB_Screen_Width=*ptr\RealWidth
    _PB_Screen_Height=*ptr\RealHeight
    ProcedureReturn 1
  Else
    _PB_Screen_Width=_PB_Screen_RealWidth
    _PB_Screen_Height=_PB_Screen_RealHeight
    Screen_Target=-1
    result=*D3DDevice9\SetRenderTarget(0,*BackBuffer)
    If result=#D3D_OK:ProcedureReturn 1:EndIf
  EndIf
EndProcedure



ProcedureDLL CopySprite2(SrcSprite,DestSprite,Mode)
  *sptr.PB_DX9Sprite=IsSprite(SrcSprite)
  If *sptr=0:ProcedureReturn 0:EndIf
  *dptr.PB_DX9Sprite=IsSprite(DestSprite)
  
  If Mode=#PB_Sprite_Alpha And *sptr\Mode<>#PB_Sprite_Alpha:ProcedureReturn 0:EndIf
  
  If *dptr
    If *dptr\Mode<>Mode Or *dptr\RealWidth<>*sptr\RealWidth Or *dptr\RealHeight<>*sptr\RealWidth
      FreeSprite(DestSprite)
      *dptr=___CreateSprite(DestSprite,*sptr\RealWidth,*sptr\RealHeight,Mode)
      If Mode=#PB_Sprite_Alpha And *dptr<>0
        *dptr\TexRes2=TexRes_CreateTexture(*D3DDevice9,*sptr\RealWidth,*sptr\RealHeight,#TEXRES_STATIC_A8R8G8B8,0)
      EndIf
    EndIf
    
  Else
    *dptr=___CreateSprite(DestSprite,*sptr\RealWidth,*sptr\RealHeight,Mode)
    If Mode=#PB_Sprite_Alpha And *dptr<>0
      *dptr\TexRes2=TexRes_CreateTexture(*D3DDevice9,*sptr\RealWidth,*sptr\RealHeight,#TEXRES_STATIC_A8R8G8B8,0)
    EndIf
  EndIf
  
  If *dptr=0:ProcedureReturn 0:EndIf
  TexRes_SetTransColor(*dptr\TexRes,TexRes_GetTransColor(*sptr\TexRes))
  *dptr\InvalidCollisionMap=#True
  ;--> some checks missing
  
  ;TexRes_Lock(*sptr\TexRes,0,0,@*srcptr,@srcpitch)
  ;TexRes_Lock(*dptr\TexRes,0,0,@*dstptr,@dstpitch)
  ;For y=0 To *sptr\RealHeight-1
  ;RtlMoveMemory_(*dstptr+y*dstpitch,*srcptr+y*srcpitch,*sptr\RealWidth*2)  ; -> *2 nicht immer korrect
  ;Next
  ;TexRes_UnLock(*dptr\TexRes,0)
  ;TexRes_UnLock(*sptr\TexRes,0)
  
  SrcDC=TexRes_GetDC(*sptr\TexRes)
  DestDC=TexRes_GetDC(*dptr\TexRes)
  Result=BitBlt_(DestDC,0,0,*sptr\RealWidth,*sptr\RealHeight,SrcDC,0,0,#SRCCOPY)
  TexRes_ReleaseDC(*dptr\TexRes,0)
  TexRes_ReleaseDC(*sptr\TexRes,1)
  
  If *sptr\TexRes2 And *dptr\TexRes2 And Result
    SrcDC=TexRes_GetDC(*sptr\TexRes2)
    DestDC=TexRes_GetDC(*dptr\TexRes2)
    Result=BitBlt_(DestDC,0,0,*sptr\RealWidth,*sptr\RealHeight,SrcDC,0,0,#SRCCOPY)
    TexRes_ReleaseDC(*dptr\TexRes2,0)
    TexRes_ReleaseDC(*sptr\TexRes2,1)
  EndIf
  
  
  If Result=0
    
    If DestSprite=#PB_Any
      FreeSprite(*dptr)
    Else
      FreeSprite(DestSprite)
    EndIf
    ProcedureReturn #False
  EndIf
  
  If DestSprite=#PB_Any
    ProcedureReturn *dptr
  EndIf
  
  ProcedureReturn *dptr\TexRes
EndProcedure

ProcedureDLL CopySprite(DestSprite,SrcSprite)
  ProcedureReturn CopySprite2(DestSprite,SrcSprite,0)
EndProcedure


ProcedureDLL GrabSprite2(Sprite,x,y,Width,Height,Mode)
  If Mode=#PB_Sprite_Alpha:ProcedureReturn 0:EndIf
  If Width<=0 Or Height<=0:ProcedureReturn 0:EndIf
  If x<0 Or y<0:ProcedureReturn 0:EndIf
  If x+Width>_PB_Screen_Width Or y+Height>_PB_Screen_Height:ProcedureReturn 0:EndIf
  
  *dptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *dptr=0
    *dptr.PB_DX9Sprite=___CreateSprite(Sprite,Width,Height,Mode)
  EndIf
  If *dptr=0:ProcedureReturn 0:EndIf
  
  Depth=16
  If Mode&#PB_Sprite_AlphaBlending:Depth=32:EndIf
  
  If *dptr\Width<>Width Or *dptr\Height<>Height Or *dptr\Depth<>Depth
    FreeSprite(Sprite)
    *dptr.PB_DX9Sprite=___CreateSprite(Sprite,Width,Height,Mode)
  Else
    
    result=TexRes_Optimize(*dptr\TexRes,UsePixelShader14) ; try to optimize the Texture
    If result:*dptr\TexRes=result:EndIf
  EndIf
  
  If *dptr=0
    ProcedureReturn 0
  EndIf
  
  If Screen_Target<>-1
    *ptr.PB_DX9Sprite=IsSprite(Screen_Target)
    If *ptr=0:ProcedureReturn 0:EndIf
    
    
    If BeginScene
      BeginScene=0
      *D3DDevice9\EndScene()  ; needed, to update the surface
    EndIf
    
    ;--> some checks missing
    SrcDC=TexRes_GetDC(*ptr\TexRes)
    
    If SrcDC
      DstDC=TexRes_GetDC(*dptr\TexRes)
      If DstDC
        Result=BitBlt_(DstDC,0,0,Width,Height,SrcDC,x,y,#SRCCOPY)
        TexRes_ReleaseDC(*dptr\TexRes,0)
      EndIf
      TexRes_ReleaseDC(*ptr\TexRes,1)
    EndIf
    
    
  Else
    
    If BeginScene
      BeginScene=0
      *D3DDevice9\EndScene()  ; needed, to update the surface
    EndIf
    
    
    ;OLD 48 FPS
    
    ;--> some checks missing
    
    If BackBufferSysCopyBitmap=0
      DisplayDC=CreateDC_("display",0,0,0)
      BackBufferSysCopyBitmap=CreateCompatibleBitmap_(DisplayDC,d3dpp\BackBufferWidth,d3dpp\BackBufferHeight)
      DeleteDC_(DisplayDC)
    EndIf
    
    MemDC=CreateCompatibleDC_(0)
    
    If MemDC
      OldhBmp=SelectObject_(MemDC,BackBufferSysCopyBitmap)
      
      *BackBuffer\GetDC(@SrcDC)
      If SrcDC
        
        Result=BitBlt_(MemDC,0,0,Width,Height,SrcDC,x,y,#SRCCOPY)
        *BackBuffer\ReleaseDC(SrcDC)
      EndIf
      
      If Result
        DstDC=TexRes_GetDC(*dptr\TexRes)
        If DstDC
          Result=BitBlt_(DstDC,0,0,Width,Height,MemDC,0,0,#SRCCOPY)        
          TexRes_ReleaseDC(*dptr\TexRes,0)
        EndIf
      EndIf
      
      SelectObject_(MemDC,OldhBmp)
      DeleteDC_(MemDC)
    EndIf 
    
  EndIf
  
  ; Correct?
  If Result=0
    
    If Sprite=#PB_Any
      FreeSprite(*dptr)
    Else
      FreeSprite(Sprite)
    EndIf 
    ProcedureReturn 0
  EndIf
  
  *dptr\InvalidCollisionMap=#True
  
  If Sprite=#PB_Any
    ProcedureReturn *dptr
  EndIf
  ProcedureReturn *dptr\TexRes
EndProcedure

ProcedureDLL GrabSprite(Sprite,x,y,Width,Height)
  ProcedureReturn GrabSprite2(Sprite,x,y,Width,Height,0)
EndProcedure


ProcedureDLL SpriteID(Sprite)
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\TexRes
EndProcedure


;->====================================================================
;->                           SPRITE3D COMMANDS        
;->====================================================================

ProcedureDLL InitSprite3D()
  SpriteList3D=O_Init(SizeOf(PB_DX9Sprite3D),128,0)
  If SpriteList3D=0:ProcedureReturn 0:EndIf
  S3DSrcBlendMode=#D3DBLEND_SRCALPHA     
  S3DDestBlendMode=#D3DBLEND_INVSRCALPHA
  ProcedureReturn 1
EndProcedure

ProcedureDLL IsSprite3D(Sprite3D)
  ProcedureReturn O_IsObject(SpriteList3D,Sprite3D)
EndProcedure

ProcedureDLL CreateSprite3D(Sprite3D,Sprite)
  *spriteptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *spriteptr=0:ProcedureReturn 0:EndIf
  *ptr.PB_DX9Sprite3D=O_GetOrAllocateID(SpriteList3D,Sprite3D)
  If *ptr=0:ProcedureReturn 0:EndIf
  *ptr\TexRes=*spriteptr\TexRes
  
  Width=TexRes_Width(*ptr\TexRes)
  Height=TexRes_Height(*ptr\TexRes)
  *ptr\Width=Width
  *ptr\Height=Height
  *ptr\RealWidth=Width
  *ptr\RealHeight=Height
  
  *ptr\Vertice[0]\x=0.0
  *ptr\Vertice[1]\x=Width
  *ptr\Vertice[2]\x=0.0
  *ptr\Vertice[3]\x=Width
  
  *ptr\Vertice[0]\y=0.0
  *ptr\Vertice[1]\y=0.0
  *ptr\Vertice[2]\y=Height
  *ptr\Vertice[3]\y=Height
  
  *ptr\Vertice[0]\z=0.0
  *ptr\Vertice[1]\z=0.0
  *ptr\Vertice[2]\z=0.0
  *ptr\Vertice[3]\z=0.0
  
  *ptr\Vertice[0]\rhw=1.0
  *ptr\Vertice[1]\rhw=1.0
  *ptr\Vertice[2]\rhw=1.0
  *ptr\Vertice[3]\rhw=1.0
  
  *ptr\Vertice[0]\Color=$FFFFFF
  *ptr\Vertice[1]\Color=$FFFFFF
  *ptr\Vertice[2]\Color=$FFFFFF
  *ptr\Vertice[3]\Color=$FFFFFF
  
  *ptr\Vertice[0]\tu=0.0
  *ptr\Vertice[0]\tv=0.0
  *ptr\Vertice[1]\tu=1.0
  *ptr\Vertice[1]\tv=0.0
  *ptr\Vertice[2]\tu=0.0
  *ptr\Vertice[2]\tv=1.0
  *ptr\Vertice[3]\tu=1.0
  *ptr\Vertice[3]\tv=1.0
  
  *ptr\BoundingBox\left=0
  *ptr\BoundingBox\top=0
  *ptr\BoundingBox\right=Width
  *ptr\BoundingBox\bottom=Height
  
  If Sprite3D=#PB_Any
    ProcedureReturn *ptr 
  EndIf
  ProcedureReturn *spriteptr\TexRes
EndProcedure  


ProcedureDLL ZoomSprite3D(Sprite3D,Width.l,Height.l)
  *ptr.PB_DX9Sprite3D=IsSprite3D(Sprite3D)
  If *ptr=0:ProcedureReturn 0:EndIf
  ;*ptr\Transformed=0 
  *ptr\Width=Width
  *ptr\Height=Height
  
  *ptr\Vertice[0]\x=0.0
  *ptr\Vertice[1]\x=Width
  *ptr\Vertice[2]\x=0.0
  *ptr\Vertice[3]\x=Width
  
  *ptr\Vertice[0]\y=0.0
  *ptr\Vertice[1]\y=0.0
  *ptr\Vertice[2]\y=Height
  *ptr\Vertice[3]\y=Height
  
  *ptr\Vertice[0]\rhw=1.0
  *ptr\Vertice[1]\rhw=1.0
  *ptr\Vertice[2]\rhw=1.0
  *ptr\Vertice[3]\rhw=1.0
  
  *ptr\BoundingBox\left=0.0
  *ptr\BoundingBox\top=0.0
  *ptr\BoundingBox\right=Width
  *ptr\BoundingBox\bottom=Height
  ;*ptr\Transformed=0
  
  ProcedureReturn #True
EndProcedure
  
ProcedureDLL RotateSprite3D(Sprite3D,Angle.f,Mode)
  *ptr.PB_DX9Sprite3D=IsSprite3D(Sprite3D)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  ;*ptr\Transformed=0 
  If Mode=0
    *ptr\Angle=Angle*ACos(-1)*2/360
  Else
    *ptr\Angle+Angle*ACos(-1)*2/360
  EndIf
  
  *ptr\Vertice[0]\x=0.0
  *ptr\Vertice[1]\x=*ptr\Width
  *ptr\Vertice[2]\x=0.0
  *ptr\Vertice[3]\x=*ptr\Width
  
  *ptr\Vertice[0]\y=0.0
  *ptr\Vertice[1]\y=0.0
  *ptr\Vertice[2]\y=*ptr\Height
  *ptr\Vertice[3]\y=*ptr\Height
  
  *ptr\Vertice[0]\rhw=1.0
  *ptr\Vertice[1]\rhw=1.0
  *ptr\Vertice[2]\rhw=1.0
  *ptr\Vertice[3]\rhw=1.0
  
  pCos.f=Cos(*ptr\Angle)
  pSin.f=Sin(*ptr\Angle)
  nSin.f=-Sin(*ptr\Angle)
  
  mx.f=(*ptr\Vertice[0]\x+*ptr\Vertice[1]\x+*ptr\Vertice[2]\x+*ptr\Vertice[3]\x)/4
  my.f=(*ptr\Vertice[0]\y+*ptr\Vertice[1]\y+*ptr\Vertice[2]\y+*ptr\Vertice[3]\y)/4
  
  XTmp.f=*ptr\Vertice[0]\x
  YTmp.f=*ptr\Vertice[0]\y
  *ptr\Vertice[0]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[0]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  XTmp.f=*ptr\Vertice[1]\x
  YTmp.f=*ptr\Vertice[1]\y
  *ptr\Vertice[1]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[1]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  XTmp.f=*ptr\Vertice[2]\x
  YTmp.f=*ptr\Vertice[2]\y
  *ptr\Vertice[2]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[2]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  XTmp.f=*ptr\Vertice[3]\x
  YTmp.f=*ptr\Vertice[3]\y
  *ptr\Vertice[3]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[3]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  ;x-min
  xmin.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x<xmin:xmin=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x<xmin:xmin=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x<xmin:xmin=*ptr\Vertice[3]\x:EndIf
  
  ;x-max
  xmax.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x>xmax:xmax=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x>xmax:xmax=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x>xmax:xmax=*ptr\Vertice[3]\x:EndIf
  
  ;y-min
  ymin.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y<ymin:ymin=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y<ymin:ymin=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y<ymin:ymin=*ptr\Vertice[3]\y:EndIf
  
  ;y-max
  ymax.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y>ymax:ymax=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y>ymax:ymax=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y>ymax:ymax=*ptr\Vertice[3]\y:EndIf
  
  *ptr\BoundingBox\left=xmin
  *ptr\BoundingBox\top=ymin
  *ptr\BoundingBox\right=xmax
  *ptr\BoundingBox\bottom=ymax
  
  ProcedureReturn #True
EndProcedure


ProcedureDLL DisplaySprite3D2(Sprite3D.l,OffsetX.f,OffsetY.f,BlendAlpha.l)
  If Sprite3D_CanRender=0:ProcedureReturn 0:EndIf
  If BlendAlpha=0:ProcedureReturn #True:EndIf ; Don't draw anything if BlendAlpha is 0!
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite3D=IsSprite3D(Sprite3D)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  *Tex1.IDirect3DTexture9=TexRes_GetUpdatedTexture(*ptr\TexRes)
  
  Clipping=#True  
  ;Check if everthing of the 3dsprite is visible
  If *ptr\BoundingBox\left+OffsetX>=0 And *ptr\BoundingBox\top+OffsetY>=0
    If *ptr\BoundingBox\right+OffsetX<_PB_Screen_Width And *ptr\BoundingBox\bottom+OffsetY<_PB_Screen_Height
      Clipping=#False
    EndIf
  EndIf 
  
  If Clipping=#True ; if a part is not visible, test weather it's completely outside of the screen
    If *ptr\BoundingBox\left+OffsetX=>_PB_Screen_Width Or *ptr\BoundingBox\right+OffsetX<0 Or  *ptr\BoundingBox\top+OffsetY=>_PB_Screen_Height Or *ptr\BoundingBox\bottom+OffsetY<0
      ProcedureReturn #True ; 3dsprite is completely outside of the drawing area
    EndIf
  EndIf
  
  If Sprite3D_QuadCount>0
    If *Tex1<>Sprite3D_LastTex1 Or Sprite3D_QuadCount>5000 Or Sprite3D_Clipping<>Clipping
      If Sprite3D_SetTex1<>Sprite3D_LastTex1 
        *D3DDevice9\SetTexture(0,Sprite3D_LastTex1)
        Sprite3D_SetTex1=Sprite3D_LastTex1 
      EndIf
      If Sprite3D_QuadCount=1 ; Improve speed if it's only 1 quad (?)
        *D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,*Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
      Else
        *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,Sprite3D_QuadCount*6,Sprite3D_QuadCount*2,*Sprite3DIndexBuffer,#D3DFMT_INDEX16,*Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
      EndIf
      Sprite3D_QuadCount=0
    EndIf
  EndIf
  
  If Clipping<>Sprite3D_Clipping
    Sprite3D_Clipping=Clipping
    *D3DDevice9\SetRenderState(#D3DRS_CLIPPING,Clipping)
  EndIf
  
  If TexRes_NeedPS14(*ptr\TexRes)
    EnablePixelShader14(TexRes_GetTransColor(*ptr\TexRes))
  Else
    DisablePixelShader14()
  EndIf
  
  Sprite3D_LastTex1=*Tex1
  
  *Quad.DisplaySpriteColor=*Sprite3DVertexBuffer+Sprite3D_QuadCount*SizeOf(DisplaySpriteColor)
  
  *Quad\v[0]\x=*ptr\Vertice[0]\x+OffsetX
  *Quad\v[0]\y=*ptr\Vertice[0]\y+OffsetY
  *Quad\v[0]\color=*ptr\Vertice[0]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[0]\tu=*ptr\Vertice[0]\tu
  *Quad\v[0]\tv=*ptr\Vertice[0]\tv
  *Quad\v[0]\rhw=*ptr\Vertice[0]\rhw
  
  *Quad\v[1]\x=*ptr\Vertice[1]\x+OffsetX
  *Quad\v[1]\y=*ptr\Vertice[1]\y+OffsetY
  *Quad\v[1]\color=*ptr\Vertice[1]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[1]\tu=*ptr\Vertice[1]\tu
  *Quad\v[1]\tv=*ptr\Vertice[1]\tv
  *Quad\v[1]\rhw=*ptr\Vertice[1]\rhw
  
  *Quad\v[2]\x=*ptr\Vertice[2]\x+OffsetX
  *Quad\v[2]\y=*ptr\Vertice[2]\y+OffsetY
  *Quad\v[2]\color=*ptr\Vertice[2]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[2]\tu=*ptr\Vertice[2]\tu
  *Quad\v[2]\tv=*ptr\Vertice[2]\tv
  *Quad\v[2]\rhw=*ptr\Vertice[2]\rhw
  
  *Quad\v[3]\x=*ptr\Vertice[3]\x+OffsetX
  *Quad\v[3]\y=*ptr\Vertice[3]\y+OffsetY 
  *Quad\v[3]\color=*ptr\Vertice[3]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[3]\tu=*ptr\Vertice[3]\tu
  *Quad\v[3]\tv=*ptr\Vertice[3]\tv
  *Quad\v[3]\rhw=*ptr\Vertice[3]\rhw
  
  Sprite3D_QuadCount+1
  
  ProcedureReturn #True
EndProcedure

ProcedureDLL DisplaySprite3D(Sprite3D,x.f,y.f)
  ProcedureReturn DisplaySprite3D2(Sprite3D,x,y,255)
EndProcedure

;+
ProcedureDLL Start3D() 
 If *D3DDevice9=0:ProcedureReturn 0:EndIf
  BeginD3D9Scene()
  
  If *D3DDevice9\SetRenderState(#D3DRS_ALPHABLENDENABLE,1):ProcedureReturn 0:EndIf
  AlphaBlendState=1
  
  If *D3DDevice9\SetFVF(#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW):ProcedureReturn 0:EndIf
  CurrentFVF=#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW
  
  If *D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,S3DSrcBlendMode):ProcedureReturn 0:EndIf
  SrcBlendMode=S3DSrcBlendMode
  
  If *D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,S3DDestBlendMode):ProcedureReturn 0:EndIf          
  DestBlendMode=S3DDestBlendMode
  
  *D3DDevice9\SetSoftwareVertexProcessing(#True) ; Use software vertex processing, because we don't clip the vertices For 3DSprites
  
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_TEXTURE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG2,#D3DTA_DIFFUSE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG1,#D3DTA_TEXTURE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG2,#D3DTA_DIFFUSE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_MODULATE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_MODULATE)
  
  Select S3DQuality
    Case 0
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_POINT)
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_POINT)
    Default
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_LINEAR)
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_LINEAR)
  EndSelect
  
  *D3DDevice9\SetRenderState(#D3DRS_CLIPPING,#True)
  Sprite3D_Clipping=#True
  
  If *Sprite3DVertexBuffer=0
    *Sprite3DVertexBuffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,($FFFF*4/6)*SizeOf(MyColoredSpriteVertex))
    
    If *Sprite3DVertexBuffer
      *Quad.DisplaySpriteColor=*Sprite3DVertexBuffer
      For c=0 To ($FFFF*4/6)-1
        *Quad\v[0]\z=0.0
        *Quad\v[0]\rhw=1.0
        *Quad\v[1]\z=0.0
        *Quad\v[1]\rhw=1.0
        *Quad\v[2]\z=0.0
        *Quad\v[2]\rhw=1.0
        *Quad\v[3]\z=0.0
        *Quad\v[3]\rhw=1.0
        *Quad+SizeOf(MyD3DTLVERTEX)
      Next
    EndIf
  EndIf
  
  ; Create our index buffer for faster displaying  
  If *Sprite3DIndexBuffer=0
    *Sprite3DIndexBuffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,$FFFF*2)
    
    If *Sprite3DIndexBuffer
      *IndexBuffer.l=*Sprite3DIndexBuffer
      For c=0 To $FFFF-6 Step 6
        PokeW(*IndexBuffer+c*2,0+Count)
        PokeW(*IndexBuffer+c*2+2,1+Count)
        PokeW(*IndexBuffer+c*2+4,2+Count)
        PokeW(*IndexBuffer+c*2+6,1+Count)
        PokeW(*IndexBuffer+c*2+8,3+Count)
        PokeW(*IndexBuffer+c*2+10,2+Count)
        Count+4
      Next
    EndIf
  EndIf
  
  Sprite3D_CanRender=#False
  If *Sprite3DIndexBuffer And *Sprite3DVertexBuffer And *D3DDevice9 And IsScreenActive
    Sprite3D_CanRender=#True
  EndIf
  
  Sprite3D_SetTex1=0:Sprite3D_LastTex1=0
  Sprite3D_QuadCount=0
  
  ProcedureReturn Sprite3D_CanRender
EndProcedure

ProcedureDLL Stop3D()  
  If IsScreenActive=0:ProcedureReturn 0:EndIf
  If *D3DDevice9=0:ProcedureReturn 0:EndIf  
  
  ; Force the batch to be flushed  
  If Sprite3D_QuadCount>0
    *D3DDevice9\SetTexture(0,Sprite3D_LastTex1)
    *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,Sprite3D_QuadCount*6,Sprite3D_QuadCount*2,*Sprite3DIndexBuffer,#D3DFMT_INDEX16,*Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
    Sprite3D_QuadCount=0
  EndIf
  
  *D3DDevice9\SetRenderState(#D3DRS_CLIPPING,#True)
  Sprite3D_Clipping=#True
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1)
  
  *D3DDevice9\SetSoftwareVertexProcessing(#False)
  ProcedureReturn #True
EndProcedure

ProcedureDLL Sprite3DBlendingMode(SrcMode,DestMode)
  If *D3DDevice9=0:ProcedureReturn 0:EndIf
  
  ; Force the batch to be flushed
  If Sprite3D_QuadCount>0
    *D3DDevice9\SetTexture(0,Sprite3D_LastTex1)
    *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,Sprite3D_QuadCount*6,Sprite3D_QuadCount*2,*Sprite3DIndexBuffer,#D3DFMT_INDEX16,*Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
    Sprite3D_QuadCount=0
  EndIf
  
  S3DSrcBlendMode=SrcMode
  S3DDestBlendMode=DestMode
  SrcBlendMode=SrcMode
  DestBlendMode=DestMode
  If *D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,SrcMode):ProcedureReturn 0:EndIf
  If *D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,DestMode):ProcedureReturn 0:EndIf          
  ProcedureReturn 1
EndProcedure

ProcedureDLL Sprite3DQuality(Quality)
  If IsScreenActive=0:ProcedureReturn #False:EndIf
  If *D3DDevice9=0:ProcedureReturn #False:EndIf
  
  If S3DQuality<>Quality
    
    ; Force the batch to be flushed
    If Sprite3D_QuadCount>0
      *D3DDevice9\SetTexture(0,Sprite3D_LastTex1)
      *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,Sprite3D_QuadCount*6,Sprite3D_QuadCount*2,*Sprite3DIndexBuffer,#D3DFMT_INDEX16,*Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
      Sprite3D_QuadCount=0
    EndIf
    
    S3DQuality=Quality
    
    Select S3DQuality
      Case 0
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_POINT)
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_POINT)
      Default
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_LINEAR)
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_LINEAR)
    EndSelect
    
  EndIf
  
  ProcedureReturn #True
EndProcedure

ProcedureDLL TransformSprite3D2(Sprite3D,x1.f,y1.f,z1.f,x2.f,y2.f,z2.f,x3.f,y3.f,z3.f,x4.f,y4.f,z4.f)
  *ptr.PB_DX9Sprite3D=IsSprite3D(Sprite3D)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  ;*ptr\Transformed=1 
  
  *ptr\Vertice[0]\x=x1
  *ptr\Vertice[1]\x=x2
  *ptr\Vertice[2]\x=x3
  *ptr\Vertice[3]\x=x4
  
  *ptr\Vertice[0]\y=y1
  *ptr\Vertice[1]\y=y2
  *ptr\Vertice[2]\y=y3
  *ptr\Vertice[3]\y=y4
  
  *ptr\Vertice[0]\rhw=1/z1
  *ptr\Vertice[1]\rhw=1/z2
  *ptr\Vertice[2]\rhw=1/z3
  *ptr\Vertice[3]\rhw=1/4
  
  ;x-min
  xmin.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x<xmin:xmin=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x<xmin:xmin=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x<xmin:xmin=*ptr\Vertice[3]\x:EndIf
  
  ;x-max
  xmax.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x>xmax:xmax=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x>xmax:xmax=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x>xmax:xmax=*ptr\Vertice[3]\x:EndIf
  
  ;y-min
  ymin.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y<ymin:ymin=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y<ymin:ymin=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y<ymin:ymin=*ptr\Vertice[3]\y:EndIf
  
  ;y-max
  ymax.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y>ymax:ymax=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y>ymax:ymax=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y>ymax:ymax=*ptr\Vertice[3]\y:EndIf
  
  *ptr\BoundingBox\left=xmin
  *ptr\BoundingBox\top=ymin
  *ptr\BoundingBox\right=xmax
  *ptr\BoundingBox\bottom=ymax
  
  ProcedureReturn #True
EndProcedure

ProcedureDLL TransformSprite3D(Sprite3D,x1.f,y1.f,x2.f,y2.f,x3.f,y3.f,x4.f,y4.f)
  ProcedureReturn TransformSprite3D2(Sprite3D,x1.f,y1.f,1,x2.f,y2.f,1,x3.f,y3.f,1,x4.f,y4.f,1)
EndProcedure

ProcedureDLL FreeSprite3D(Sprite3D)
  *ptr.PB_DX9Sprite3D=IsSprite3D(Sprite3D)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn O_FreeObject(SpriteList3D,*ptr)
EndProcedure


;+
ProcedureDLL DisplayAlphaSprite(Sprite,x,y)
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  SetRect_(re1.rect,x,y,x+*ptr\Width,y+*ptr\Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
   BeginD3D9Scene()
  DisablePixelShader14() 
  SetBlendMode(1,#D3DBLEND_SRCALPHA,#D3DBLEND_INVSRCALPHA,#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_MODULATE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_MODULATE)
  
  v.DisplaySpriteColor
  
  v\v[0]\Color=AlphaIntensity+255<<24
  v\v[1]\Color=AlphaIntensity+255<<24
  v\v[2]\Color=AlphaIntensity+255<<24
  v\v[3]\Color=AlphaIntensity+255<<24
  
  
  v\v[0]\tu=(*ptr\t[0]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[0]\tv=(*ptr\t[0]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  
  v\v[1]\tu=(*ptr\t[1]\tu+(ire\right-re1\right)/*ptr\RealWidth)* *ptr\fU
  v\v[1]\tv=(*ptr\t[1]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  
  v\v[2]\tu=(*ptr\t[2]\tu+(ire\left-re1\left)/*ptr\RealWidth) * *ptr\fU
  v\v[2]\tv=(*ptr\t[2]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight)* *ptr\fV
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  
  v\v[3]\tu=(*ptr\t[3]\tu+(ire\right-re1\right)/*ptr\RealWidth) * *ptr\fU
  v\v[3]\tv=(*ptr\t[3]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight) * *ptr\fV
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  
  *D3DDevice9\SetTexture(0,TexRes_GetUpdatedTexture(*ptr\TexRes))
  Result=*D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(DisplaySpriteColor)/4)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1)
  ProcedureReturn Result
EndProcedure


ProcedureDLL ChangeAlphaIntensity(R,G,B)
  AlphaIntensity= (B)+(G)<<8+(R)<<16 
EndProcedure


;+
ProcedureDLL DisplaySolidSprite(Sprite,x,y,Color)

  
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  SetRect_(re1.rect,x,y,x+*ptr\Width,y+*ptr\Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
   BeginD3D9Scene()
  DisablePixelShader14() 
  SetBlendMode(1,#D3DBLEND_SRCALPHA,#D3DBLEND_INVSRCALPHA,#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
  
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_DIFFUSE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG1,#D3DTA_TEXTURE)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG2) 
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1)
  
  ;Not all hardware supports all alpha-testing features. You can check the device capabilities
  ;*D3DDevice9\SetRenderState(#D3DRS_ALPHAREF,254)
  ;*D3DDevice9\SetRenderState(#D3DRS_ALPHATESTENABLE,#True)
  ;*D3DDevice9\SetRenderState(#D3DRS_ALPHAFUNC,#D3DCMP_GREATER)
  
  v.DisplaySpriteColor
  
  BGRColor=(Color&$FF)<<16+(Color&$FF00)+(Color>>16)&$FF
  
  v\v[0]\Color=BGRColor+255<<24
  v\v[1]\Color=BGRColor+255<<24
  v\v[2]\Color=BGRColor+255<<24
  v\v[3]\Color=BGRColor+255<<24
  
  v\v[0]\tu=(*ptr\t[0]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[0]\tv=(*ptr\t[0]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  
  v\v[1]\tu=(*ptr\t[1]\tu+(ire\right-re1\right)/*ptr\RealWidth)* *ptr\fU
  v\v[1]\tv=(*ptr\t[1]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  
  v\v[2]\tu=(*ptr\t[2]\tu+(ire\left-re1\left)/*ptr\RealWidth) * *ptr\fU
  v\v[2]\tv=(*ptr\t[2]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight)* *ptr\fV
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  
  v\v[3]\tu=(*ptr\t[3]\tu+(ire\right-re1\right)/*ptr\RealWidth) * *ptr\fU
  v\v[3]\tv=(*ptr\t[3]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight) * *ptr\fV
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  
  *D3DDevice9\SetTexture(0,TexRes_GetUpdatedTexture(*ptr\TexRes2))
  Result=*D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(DisplaySpriteColor)/4)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1) 
  ProcedureReturn Result
EndProcedure

;+
ProcedureDLL DisplayShadowSprite(Sprite,x,y)

  
  ;--> No checks for speed reason ?
  *ptr.PB_DX9Sprite=O_IsObject(SpriteList,Sprite)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  SetRect_(re1.rect,x,y,x+*ptr\Width,y+*ptr\Height)
  SetRect_(re2.rect,0,0,_PB_Screen_Width,_PB_Screen_Height)
  
  If IntersectRect_(ire.rect,re1,re2)=0:ProcedureReturn 0:EndIf
  
  BeginD3D9Scene()
  DisablePixelShader14()
  SetBlendMode(1,#D3DBLEND_SRCALPHA,#D3DBLEND_INVSRCALPHA,#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
  
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_DIFFUSE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG1,#D3DTA_TEXTURE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG2,#D3DTA_DIFFUSE)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG2)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_MODULATE)
  
  
  v.DisplaySpriteColor
  
  v\v[0]\Color=0+128<<24
  v\v[1]\Color=0+128<<24
  v\v[2]\Color=0+128<<24
  v\v[3]\Color=0+128<<24
  
  
  v\v[0]\tu=(*ptr\t[0]\tu+(ire\left-re1\left)/*ptr\RealWidth)* *ptr\fU
  v\v[0]\tv=(*ptr\t[0]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  
  v\v[0]\x=ire\left
  v\v[0]\y=ire\Top
  v\v[0]\rhw=1.0
  
  v\v[1]\tu=(*ptr\t[1]\tu+(ire\right-re1\right)/*ptr\RealWidth)* *ptr\fU
  v\v[1]\tv=(*ptr\t[1]\tv+(ire\Top-re1\Top)/*ptr\RealHeight)* *ptr\fV
  v\v[1]\x=ire\right
  v\v[1]\y=ire\Top
  v\v[1]\rhw=1.0
  
  v\v[2]\tu=(*ptr\t[2]\tu+(ire\left-re1\left)/*ptr\RealWidth) * *ptr\fU
  v\v[2]\tv=(*ptr\t[2]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight)* *ptr\fV
  v\v[2]\x=ire\left
  v\v[2]\y=ire\bottom
  v\v[2]\rhw=1.0
  
  v\v[3]\tu=(*ptr\t[3]\tu+(ire\right-re1\right)/*ptr\RealWidth) * *ptr\fU
  v\v[3]\tv=(*ptr\t[3]\tv+(ire\bottom-re1\bottom)/*ptr\RealHeight) * *ptr\fV
  v\v[3]\x=ire\right
  v\v[3]\y=ire\bottom
  v\v[3]\rhw=1.0
  
  *D3DDevice9\SetTexture(0,TexRes_GetUpdatedTexture(*ptr\TexRes2))
  Result=*D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,v,SizeOf(DisplaySpriteColor)/4)
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1)
  ProcedureReturn Result
EndProcedure

;Procedure ERR()
;  text$="Module: "+GetErrorModuleName()+Chr(13)
;  text$+"Description:"+GetErrorDescription()+Chr(13)
;  text$+"Quit ?"
;  If MessageRequester("ERROR in Line:"+Str(GetErrorLineNR()),text$,#MB_YESNO)=#IDYES:ExitProcess_(0):EndIf
;EndProcedure


;OnErrorGosub(@ERR())

;UseJPEGImageDecoder()
;UsePNGImageDecoder()
;UseTGAImageDecoder()
;UseTIFFImageDecoder()

DataSection
PS14_ColorKey:
IncludeBinary "ColorKey.cps"
EndDataSection


; IDE Options = PureBasic 5.00 Beta 3 (Windows - x86)
; CursorPosition = 9
; FirstLine = 7
; Folding = ---------------------
; Executable = TEST_FOR_LAPP.exe
; VersionField0 = 0,3,0,0
; VersionField1 = 0,3,0,0
; VersionField2 = Stefan Moebius
; VersionField3 = DX9 subsystem
; VersionField4 = 0.3
; VersionField5 = 0.3
; VersionField6 = DX9 subsystem for PureBasic
; VersionField7 = DX9 subsystem
; VersionField8 = DX9SubsystemDLL.dll
; VersionField9 = © 2006 Stefan Moebius