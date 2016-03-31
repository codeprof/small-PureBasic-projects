;####################################################
;# DX9Subsystem TextureManager ©2006 Stefan Moebius #
;####################################################

IncludeFile "DX9S_D3D9HelperFunctions.pbi" 

Global TexRes_DisableTransparentColorUpdate.l

#TEXRES_DYNAMIC_A1R5G5B5=1
#TEXRES_STATIC_A1R5G5B5=2
#TEXRES_STATIC_A8R8G8B8=3
#TEXRES_DYNAMIC_A1R5G5B5_PS14=4

;#TEXRES_SILENTLOCK_TRYLOCK=1
;#TEXRES_SILENTLOCK_GETDCFAILED=2

#TEXRES_OPTIMIZE_PS14=1

Structure TexRes
  VTable.l
  Type.l ; #TEXRES_DYNAMIC_A1R5G5B5,#TEXRES_STATIC_A1R5G5B5 or #TEXRES_STATIC_A8R8G8B8
  Width.l
  Height.l
  IsDynamic.l
  CanMakeDynamic.l ; needed to optimize the TexRes
  RealTexture.l ; true if created with #PB_Sprite_Texture
  TransparentColor.l
  LockSinceGetRTSurface.l
  RTToSysMemCopyNeeded.l
  TextureUpdateNeeded.l
  DC.l
  QuickGetDCMethod.l
  Locked.l
  NumLocks.l ; needed to optimize the TexRes
  D3DDevice.l
  SysmemSurface.IDirect3DSurface9
  Texture.l
  TextureSurface.IDirect3DSurface9
  RTSurface.l
  RTCopy.l
  Pitch.l
EndStructure

Macro ToPow2(val)
Pow(2,Round(Log(val)/Log(2),1))
EndMacro

;--------------------------------------------------------------------------------------
; functions to handle with the internal surfaces and textures
;--------------------------------------------------------------------------------------

Procedure ___ReleaseSpriteRT(*ptr.TexRes) ; Release Rendertarget of the Sprite 
  Debug "ReleaseSpriteRT"
  
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\RTSurface=0:ProcedureReturn 0:EndIf
  If *ptr\IsDynamic:ProcedureReturn 0:EndIf
  
  *RT.IDirect3DSurface9=*ptr\RTSurface
  *RT\Release()
  *ptr\RTSurface=0
  ProcedureReturn #True
EndProcedure

Procedure ___MakeSureSpriteRTExists(*ptr.TexRes) ; make sure Rendertarget is existing
  Debug "MakeSureSpriteRTExists"
  
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\Texture=0:ProcedureReturn 0:EndIf
  
  If *ptr\RTSurface:ProcedureReturn 1:EndIf ; RTSurface exist (no need to create a new one)
  ;If *ptr\IsDynamic:ProcedureReturn 0:EndIf ; not needed, because we can't free the RT of a dynamic sprite 
  *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  If *D3DDevice=0:ProcedureReturn 0:EndIf
  ;The Rendertarget is needed if you want to display a sprite on the sprite (with UseBuffer(Sprite)) and for 2DDrawing (need to be lockable)
  *D3DDevice\CreateRenderTarget(*ptr\Width,*ptr\Height,#D3DFMT_R5G6B5,0,0,1,@*ptr\RTSurface,0)
  
  If *ptr\RTSurface=0:ProcedureReturn 0:EndIf
  
  ;*D3DDevice\EndScene()
  
  ;Copy RTCopy --> RTSurface
  *RTSurf.IDirect3DSurface9=*ptr\RTSurface
  If *RTSurf\LockRect(db.D3DLOCKED_RECT,0,0):ProcedureReturn 0:EndIf
  
  BytesPerLine=*ptr\Width*2
  For y=0 To *ptr\Height-1
    CopyMemory(*ptr\RTCopy+y*(BytesPerLine),db\pBits+y*db\Pitch,BytesPerLine)
  Next
  
  *RTSurf\UnLockRect()
  ;*D3DDevice\BeginScene()
  
  ProcedureReturn 1
EndProcedure


Procedure ___Static_CopyRTToManagedTexture(*ptr.TexRes)
  Debug "Static_CopyRTToManagedTexture"
  
  If *ptr=0:ProcedureReturn 0:EndIf
  If ___MakeSureSpriteRTExists(*ptr)=0:ProcedureReturn 0:EndIf ; make sure Rendertarget is existing
  If *ptr\Texture=0 Or *ptr\RTSurface=0:ProcedureReturn 0:EndIf
  
  ;*D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  ;If *D3DDevice=0:ProcedureReturn 0:EndIf  
  ;*D3DDevice\EndScene()  
  
  ;Copy RTSurface-->RTCopy
  BytesPerLine=*ptr\Width*2
  *RTSurf.IDirect3DSurface9=*ptr\RTSurface
  If *RTSurf\LockRect(sb.D3DLOCKED_RECT,0,#D3DLOCK_READONLY):ProcedureReturn 0:EndIf
  For y=0 To *ptr\Height-1
    CopyMemory(sb\pBits+y*sb\Pitch,*ptr\RTCopy+y*(BytesPerLine),BytesPerLine)
  Next
  *RTSurf\UnLockRect()
  
  ;Copy RTCopy--> Managed Texture
  *Texture.IDirect3DTexture9=*ptr\Texture
  If *Texture\LockRect(0,db.D3DLOCKED_RECT,0,0):ProcedureReturn 0:EndIf
  
  H_SetX1RGB15ToA1RGB15TransColor(*ptr\TransparentColor)
  For y=0 To *ptr\Height-1
    H_ConvertX1RGB15ToA1RGB15(*ptr\RTCopy+y*(BytesPerLine),db\pBits+y*db\Pitch,*ptr\Width)
  Next
  
  *Texture\UnLockRect(0)
  ;*D3DDevice\BeginScene()
  ProcedureReturn 1
EndProcedure

Procedure ___Dynamic_CopyRTSurfaceToSysmemSurface(*ptr.TexRes)
  Debug "Dynamic_CopyRTSurfaceToSysmemSurface"
  
  If *ptr=0:ProcedureReturn 0:EndIf
  ;Copy RTSurface->SysmemSurface
  *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  If *D3DDevice=0 Or *ptr\RTSurface=0 Or *ptr\SysmemSurface=0:ProcedureReturn 0:EndIf
  If *D3DDevice\GetRenderTargetData(*ptr\RTSurface,*ptr\SysmemSurface):ProcedureReturn 0:EndIf
  ProcedureReturn 1
EndProcedure


Procedure ___Dynamic_CopySysmemSurfaceToTexture(*ptr.TexRes)
  Debug "Dynamic_CopySysmemSurfaceToTexture"
  
  
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\TextureSurface=0 Or *ptr\SysMemSurface=0:ProcedureReturn 0:EndIf
  
  ;Copy SysmemSurface-->TextureSurface
  *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
  If *TexSurf\LockRect(db.D3DLOCKED_RECT,0,#D3DLOCK_DISCARD):ProcedureReturn 0:EndIf
  *SysmemSurf.IDirect3DSurface9=*ptr\SysMemSurface
  If *SysmemSurf\LockRect(sb.D3DLOCKED_RECT,0,#D3DLOCK_READONLY):*SysmemSurf\UnLockRect():ProcedureReturn 0:EndIf
  
  H_SetX1RGB15ToA1RGB15TransColor(*ptr\TransparentColor)
  For y=0 To *ptr\Height-1
    H_ConvertX1RGB15ToA1RGB15(sb\pBits+y*sb\Pitch,db\pBits+y*db\Pitch,*ptr\Width)
  Next
  
  *SysmemSurf\UnLockRect()
  *TexSurf\UnLockRect()
  ProcedureReturn 1
EndProcedure


Procedure ___Dynamic_CopySysmemSurfaceToRTSurface(*ptr.TexRes)
  Debug "Dynamic_CopySysmemSurfaceToRTSurface"
  
  If *ptr=0:ProcedureReturn 0:EndIf
  ;Copy SysmemSurface->Texture
  *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  If *D3DDevice=0 Or *ptr\SysmemSurface=0 Or *ptr\RTSurface=0:ProcedureReturn 0:EndIf
  If *D3DDevice\UpdateSurface(*ptr\SysmemSurface,0,*ptr\RTSurface,0):ProcedureReturn 0:EndIf
  ProcedureReturn 1
EndProcedure

Procedure ___Dynamic_PS14_CopySysmemSurfaceToTexture(*ptr.TexRes)
  Debug "Dynamic_PS14_CopySysmemSurfaceToTexture"  
  
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\TextureSurface=0 Or *ptr\SysMemSurface=0:ProcedureReturn 0:EndIf
  
  *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  If *D3DDevice=0:ProcedureReturn 0:EndIf
  
  ;don't copy pixel which can't be seen
  ;sre.rect
  ;sre\left=0
  ;sre\top=0
  ;sre\right=*ptr\Width
  ;sre\bottom=*ptr\Height
  
  ; Result=*D3DDevice\UpdateSurface(*ptr\SysMemSurface,sre,*ptr\TextureSurface,0) 
  
  Result=*D3DDevice\UpdateSurface(*ptr\SysMemSurface,0,*ptr\TextureSurface,0) 
  If Result:ProcedureReturn 0:EndIf
  
  ProcedureReturn 1
EndProcedure

Procedure ___Dynamic_PS14_CopyTextureToSysmemSurface(*ptr.TexRes)
  Debug "Dynamic_PS14_CopyTextureToSysmemSurface"
  
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\TextureSurface=0 Or *ptr\SysMemSurface=0:ProcedureReturn 0:EndIf
  
  *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  If *D3DDevice=0:ProcedureReturn 0:EndIf
  
  ; große von TextureSurface und SysMemSurface unterschiedlicht (ToPow2) !!!! -> ERROR ????
  
  Result=*D3DDevice\GetRenderTargetData(*ptr\TextureSurface,*ptr\SysMemSurface)
  If Result:ProcedureReturn 0:EndIf
  
  ProcedureReturn 1
EndProcedure

Procedure ___MakeSureA8R8G8B8SpriteHasSystemSurface(*ptr.TexRes)
  If *ptr=0:ProcedureReturn #False:EndIf
  *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
  
  If *ptr\SysMemSurface=0
    *Dev.IDirect3DDevice9=*ptr\D3DDevice
    *Dev\CreateOffscreenPlainSurface(*ptr\Width,*ptr\Height,#D3DFMT_X8R8G8B8,#D3DPOOL_SYSTEMMEM,@*TmpSurf.IDirect3DSurface9,0)
    
    If *TmpSurf=0:ProcedureReturn 0:EndIf
    
    If *TexSurf\LockRect(sb.D3DLOCKED_RECT,0,#D3DLOCK_READONLY):*TmpSurf\Release():ProcedureReturn 0:EndIf
    If *TmpSurf\LockRect(db.D3DLOCKED_RECT,0,0):*TexSurf\UnLockRect():*TmpSurf\Release():ProcedureReturn 0:EndIf
    
    BytesPerLine=*ptr\Width*4
    For y=0 To *ptr\Height-1
      CopyMemory(sb\pBits+y*sb\Pitch,db\pBits+y*sb\Pitch,BytesPerLine)
    Next
    
    *TmpSurf\UnLockRect()
    *TexSurf\UnLockRect()
    *ptr\SysMemSurface=*TmpSurf
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure ___Static_A8R8G8B8_CopySysmemSurfaceToTexture(*ptr.TexRes)
  If *ptr=0:ProcedureReturn #False:EndIf
  
  *TmpSurf.IDirect3DSurface9=*ptr\SysMemSurface
  *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
  If *TmpSurf=0 Or *TexSurf=0:ProcedureReturn #False:EndIf
  
  If *TmpSurf\LockRect(sb.D3DLOCKED_RECT,0,#D3DLOCK_READONLY):ProcedureReturn 0:EndIf
  If *TexSurf\LockRect(db.D3DLOCKED_RECT,0,0):*TmpSurf\UnLockRect():ProcedureReturn 0:EndIf
  
  BytesPerLine=*ptr\Width*4
  For y=0 To *ptr\Height-1
    CopyMemory(sb\pBits+y*sb\Pitch,db\pBits+y*db\Pitch,BytesPerLine)
  Next
  
  *TmpSurf\UnLockRect()
  *TexSurf\UnLockRect()
  ProcedureReturn #True
EndProcedure


;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------



Procedure TexRes_Init()
  ProcedureReturn H_Init();X1RGB15ToA1RGB15Buffer()
EndProcedure

Procedure TexRes_End()
  ProcedureReturn H_Free();X1RGB15ToA1RGB15Buffer()
EndProcedure

Procedure TexRes_Type(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\Type
EndProcedure

Procedure TexRes_Width(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\Width
EndProcedure

Procedure TexRes_Height(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\Height
EndProcedure

Procedure TexRes_Depth(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  Select *ptr\Type
    Case #TEXRES_DYNAMIC_A1R5G5B5
      ProcedureReturn 16
    Case #TEXRES_STATIC_A1R5G5B5
      ProcedureReturn 16
    Case #TEXRES_STATIC_A8R8G8B8
      ProcedureReturn 32
  EndSelect
EndProcedure


Procedure TexRes_CreateTexture(*D3DDevice.IDirect3DDevice9,Width,Height,Type,RealTexture)
  If Width<=0 And Height<=0 Or *D3DDevice=0:ProcedureReturn 0:EndIf
  
  
  ;-> No Pow2
  
  ;If RealTexture
  TexWidth=Width
  TexHeight=Height
  ;Else
  ;TexWidth=ToPow2(Width)
  ;TexHeight=ToPow2(Height)
  ;EndIf
  
  
  Select Type
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *D3DDevice\CreateTexture(TexWidth,TexHeight,1,#D3DUSAGE_RENDERTARGET,#D3DFMT_R5G6B5,#D3DPOOL_DEFAULT,@*Tex.IDirect3DTexture9,0)
      
      If *Tex=0:ProcedureReturn 0:EndIf
      ;The sysmem Surface is needed to restore the Sprite if the Device gets lost
      *D3DDevice\CreateOffscreenPlainSurface(Width,Height,#D3DFMT_R5G6B5,#D3DPOOL_SYSTEMMEM,@*SysmemSurface.IDirect3DSurface9,0)
      If *SysmemSurface=0
        *Tex\Release()
        ProcedureReturn 0
      EndIf
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *D3DDevice\CreateTexture(TexWidth,TexHeight,1,#D3DUSAGE_DYNAMIC,#D3DFMT_A1R5G5B5,#D3DPOOL_DEFAULT,@*Tex.IDirect3DTexture9,0)
      If *Tex=0:ProcedureReturn 0:EndIf
      
      
      ;The Rendertarget is needed if you want to display a sprite on the sprite (with UseBuffer(Sprite))
      *D3DDevice\CreateRenderTarget(Width,Height,#D3DFMT_R5G6B5,0,0,0,@*RTSurface.IDirect3DSurface9,0)
      
      If *RTSurface=0 ; we can't create the render target surface
        *Tex\Release() ; needed because the texture was sucessfully created 
        ProcedureReturn 0
      EndIf
      
      ;The sysmem Surface is needed to restore the Sprite if the Device gets lost
      *D3DDevice\CreateOffscreenPlainSurface(Width,Height,#D3DFMT_R5G6B5,#D3DPOOL_SYSTEMMEM,@*SysmemSurface.IDirect3DSurface9,0)
      
      If *SysmemSurface=0
        *RTSurface\Release()
        *Tex\Release()
        ProcedureReturn 0
      EndIf
      
    Case #TEXRES_STATIC_A1R5G5B5
      
      *D3DDevice\CreateTexture(TexWidth,TexHeight,1,0,#D3DFMT_A1R5G5B5,#D3DPOOL_MANAGED,@*Tex,0)
      If *Tex=0:ProcedureReturn 0:EndIf ; we can't create such a texture
      
      ;The Rendertarget is needed if you want to display a sprite on the sprite (with UseBuffer(Sprite)) and for 2DDrawing (need to be lockable)
      *D3DDevice\CreateRenderTarget(Width,Height,#D3DFMT_R5G6B5,0,0,1,@*RTSurface.IDirect3DSurface9,0)
      
      If *RTSurface=0 ; we can't create the render target surface
        *Tex\Release() ; needed because the texture was sucessfully created 
        ProcedureReturn 0
      EndIf     
      
      *RTCopy=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,Width*Height*2)
      
      If *RTCopy=0
        *RTSurface\Release()
        *Tex\Release()
        ProcedureReturn 0
      EndIf
      
      
    Case #TEXRES_STATIC_A8R8G8B8
      
      *D3DDevice\CreateTexture(TexWidth,TexHeight,1,0,#D3DFMT_A8R8G8B8,#D3DPOOL_MANAGED,@*Tex,0)
      If *Tex=0:ProcedureReturn 0:EndIf ; we can't create such a texture
      
    Default
      ProcedureReturn 0
  EndSelect
  
  *Tex\GetSurfaceLevel(0,@*TextureSurface.IDirect3DSurface9)
  
  If *TextureSurface=0
    If *SysmemSurface:*SysmemSurface\Release():EndIf
    If *RTSurface:*RTSurface\Release():EndIf
    *Tex\Release()
    ProcedureReturn 0
  EndIf
  
  *ptr.TexRes=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,SizeOf(TexRes))
  
  If *ptr=0
    *TextureSurface\Release()
    If *SysmemSurface:*SysmemSurface\Release():EndIf
    If *RTSurface:*RTSurface\Release():EndIf
    *Tex\Release()
    ProcedureReturn 0
  EndIf
  *ptr\VTable=?TexRes_VTable
  *ptr\Type=Type
  *ptr\Width=Width
  *ptr\Height=Height
  *ptr\RealTexture=RealTexture
  
  Select Type
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *ptr\IsDynamic=1
      *ptr\CanMakeDynamic=0
      *ptr\SysmemSurface=*SysmemSurface
      *ptr\TextureUpdateNeeded=1
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *ptr\IsDynamic=1
      *ptr\CanMakeDynamic=0
      *ptr\SysmemSurface=*SysmemSurface
      *ptr\RTSurface=*RTSurface
      *ptr\TextureUpdateNeeded=1
    Case #TEXRES_STATIC_A1R5G5B5
      *ptr\IsDynamic=0
      *ptr\CanMakeDynamic=1
      *ptr\RTSurface=*RTSurface
      *ptr\TextureUpdateNeeded=1
    Case #TEXRES_STATIC_A8R8G8B8
      *ptr\IsDynamic=0
      *ptr\CanMakeDynamic=0
      *ptr\TextureUpdateNeeded=0
  EndSelect
  
  *ptr\Texture=*Tex
  *ptr\TextureSurface=*TextureSurface
  *ptr\D3DDevice=*D3DDevice
  *ptr\Pitch=0
  *ptr\RTCopy=*RTCopy
  
  ProcedureReturn *ptr
EndProcedure

Procedure TexRes_GetUpdatedTexture(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\TextureUpdateNeeded=0
    ProcedureReturn *ptr\Texture
  EndIf
  
  If *ptr\Type=#TEXRES_STATIC_A8R8G8B8
    If ___Static_A8R8G8B8_CopySysmemSurfaceToTexture(*ptr)
    EndIf
    ProcedureReturn 0
  EndIf
  
  *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
  
  If *ptr\Type=#TEXRES_DYNAMIC_A1R5G5B5_PS14
    ;If ___Dynamic_PS14_CopyTextureToSysmemSurface(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
    
    ;correct?
    If ___Dynamic_PS14_CopySysmemSurfaceToTexture(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
    
    *ptr\TextureUpdateNeeded=0
    ProcedureReturn *ptr\Texture  
  EndIf
  
  
  If *ptr\IsDynamic=0
    If ___Static_CopyRTToManagedTexture(*ptr)=0:ProcedureReturn 0:EndIf
  Else
    ;If *ptr\RTToSysMemCopyNeeded
    ;  *ptr\RTToSysMemCopyNeeded=0
    ;  If ___Dynamic_CopyRTSurfaceToSysmemSurface(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
    ;EndIf
    If ___Dynamic_CopySysmemSurfaceToTexture(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
  EndIf
  *ptr\TextureUpdateNeeded=0
  ProcedureReturn *ptr\Texture
EndProcedure


Procedure TexRes_UpdateFromRT(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  
  If *ptr\Type=#TEXRES_STATIC_A1R5G5B5
    If ___Static_CopyRTToManagedTexture(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If *ptr\Type=#TEXRES_DYNAMIC_A1R5G5B5_PS14

    If ___Dynamic_PS14_CopyTextureToSysmemSurface(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
  EndIf
  
  If *ptr\Type=#TEXRES_DYNAMIC_A1R5G5B5
    If ___Dynamic_CopyRTSurfaceToSysmemSurface(*ptr.TexRes)=0:ProcedureReturn 0:EndIf
    *ptr\TextureUpdateNeeded=1
  EndIf
  ProcedureReturn 1
EndProcedure



Procedure TexRes_SetTransColor(*ptr.TexRes,TransColor)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\Type=#TEXRES_STATIC_A8R8G8B8:ProcedureReturn 0:EndIf
  If *ptr\TransparentColor=TransColor:ProcedureReturn 1:EndIf
  
  If *ptr\Type<>#TEXRES_DYNAMIC_A1R5G5B5_PS14
    *ptr\TextureUpdateNeeded=1
  EndIf
  
  *ptr\TransparentColor=TransColor
  
  
  If TexRes_DisableTransparentColorUpdate=0
    ProcedureReturn TexRes_GetUpdatedTexture(*ptr.TexRes)
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure TexRes_GetTransColor(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\Type=#TEXRES_STATIC_A8R8G8B8:ProcedureReturn 0:EndIf
  ProcedureReturn *ptr\TransparentColor
EndProcedure

Procedure TexRes_Lock(*ptr.TexRes,Readonly,*SurfacePtr.Long,*SurfacePitch.Long)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *SurfacePtr=0 Or *SurfacePitch=0:ProcedureReturn 0:EndIf
  
  Select *ptr\Type
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *Surf.IDirect3DSurface9=*ptr\SysmemSurface
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *Surf.IDirect3DSurface9=*ptr\SysmemSurface
    Case #TEXRES_STATIC_A1R5G5B5
      If ___MakeSureSpriteRTExists(*ptr)=0:ProcedureReturn 0:EndIf
      *Surf.IDirect3DSurface9=*ptr\RTSurface
    Case #TEXRES_STATIC_A8R8G8B8
      
      If ___MakeSureA8R8G8B8SpriteHasSystemSurface(*ptr)=0:ProcedureReturn 0:EndIf   
      *Surf.IDirect3DSurface9=*ptr\SysMemSurface
  EndSelect
  
  
  If *Surf=0:ProcedureReturn 0:EndIf
  
  If Readonly
    If *Surf\LockRect(lr.D3DLOCKED_RECT,0,#D3DLOCK_READONLY):ProcedureReturn 0:EndIf
  Else
    If *Surf\LockRect(lr.D3DLOCKED_RECT,0,0):ProcedureReturn 0:EndIf
    *ptr\NumLocks+1
  EndIf
  *ptr\Locked=1
  *SurfacePtr\l=lr\pBits
  *SurfacePitch\l=lr\Pitch
  ProcedureReturn 1
EndProcedure


Procedure TexRes_UnLock(*ptr.TexRes,WasReadonly)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\Locked=0:ProcedureReturn 0:EndIf
  ;If ___MakeSureSpriteRTExists(*ptr)=0:ProcedureReturn 0:EndIf ; the RT must exist because TexRes_Lock worked
  
  Select *ptr\Type
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *Surf.IDirect3DSurface9=*ptr\SysmemSurface
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *Surf.IDirect3DSurface9=*ptr\SysmemSurface
    Case #TEXRES_STATIC_A1R5G5B5
      *Surf.IDirect3DSurface9=*ptr\RTSurface
    Case #TEXRES_STATIC_A8R8G8B8
      *Surf.IDirect3DSurface9=*ptr\SysMemSurface    
  EndSelect
  
  
  If *Surf=0:ProcedureReturn 0:EndIf
  If *Surf\UnLockRect():ProcedureReturn 0:EndIf
  *ptr\Locked=0
  
  If WasReadonly=0
    *ptr\TextureUpdateNeeded=1
    *ptr\LockSinceGetRTSurface=1
  EndIf
  
  ;--- D A N G E R !!!!!
  ProcedureReturn #True;TexRes_GetUpdatedTexture(*ptr)  ;--> needed ????
EndProcedure


Procedure TexRes_GetDC(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\DC:ProcedureReturn 0:EndIf
  
  Select *ptr\Type
    
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *Surf.IDirect3DSurface9=*ptr\SysmemSurface
      If *Surf\GetDC(@*ptr\DC):ProcedureReturn 0:EndIf
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *Surf.IDirect3DSurface9=*ptr\SysmemSurface
      If *Surf\GetDC(@*ptr\DC):ProcedureReturn 0:EndIf
      
    Case #TEXRES_STATIC_A1R5G5B5
      If ___MakeSureSpriteRTExists(*ptr)=0:ProcedureReturn 0:EndIf
      *Surf.IDirect3DSurface9=*ptr\RTSurface
      If *Surf\GetDC(@*ptr\DC):ProcedureReturn 0:EndIf
      
    Case #TEXRES_STATIC_A8R8G8B8
      
      If ___MakeSureA8R8G8B8SpriteHasSystemSurface(*ptr)=0:ProcedureReturn 0:EndIf
      *Surf.IDirect3DSurface9=*ptr\SysMemSurface
      *ptr\SysMemSurface\GetDC(@*ptr\DC)
  EndSelect
  
  ProcedureReturn *ptr\DC
EndProcedure


Procedure TexRes_ReleaseDC(*ptr.TexRes,WasReadonly)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\DC=0:ProcedureReturn 0:EndIf
  ;If ___MakeSureSpriteRTExists(*ptr)=0:ProcedureReturn 0:EndIf ; the RT must exist because TexRes_Lock worked
  
  Select *ptr\Type
    
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *Surf.IDirect3DSurface9=*ptr\SysMemSurface
      If *Surf\ReleaseDC(*ptr\DC):ProcedureReturn 0:EndIf
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *Surf.IDirect3DSurface9=*ptr\SysMemSurface
      If *Surf\ReleaseDC(*ptr\DC):ProcedureReturn 0:EndIf
      
    Case #TEXRES_STATIC_A1R5G5B5
      *Surf.IDirect3DSurface9=*ptr\RTSurface
      If *Surf\ReleaseDC(*ptr\DC):ProcedureReturn 0:EndIf
      
    Case #TEXRES_STATIC_A8R8G8B8
      
      *Surf.IDirect3DSurface9=*ptr\SysMemSurface
      If *Surf\ReleaseDC(*ptr\DC):ProcedureReturn 0:EndIf
      
  EndSelect
  
  *ptr\DC=0
  If WasReadonly=0
    *ptr\TextureUpdateNeeded=1
    *ptr\LockSinceGetRTSurface=1
    *ptr\NumLocks+1
  EndIf
  
  ;--- D A N G E R !!!!
  ProcedureReturn #True;TexRes_GetUpdatedTexture(*ptr)
EndProcedure


Procedure TexRes_GetRTSurface(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  
  
  
  If *ptr\Type=#TEXRES_DYNAMIC_A1R5G5B5_PS14
   ;-- WARNING ADDED !!!!
    If ___Dynamic_PS14_CopySysmemSurfaceToTexture(*ptr)=0:ProcedureReturn 0:EndIf
    ProcedureReturn *ptr\TextureSurface
  EndIf
  
  
  If *ptr\IsDynamic=0
    If ___MakeSureSpriteRTExists(*ptr)=0:ProcedureReturn 0:EndIf
    
  Else
    
    If *ptr\LockSinceGetRTSurface
      *ptr\LockSinceGetRTSurface=0
      If ___Dynamic_CopySysmemSurfaceToRTSurface(*ptr)=0:ProcedureReturn 0:EndIf
    EndIf
    *ptr\RTToSysMemCopyNeeded=1
    
  EndIf
  
  ;-> here change
  *ptr\NumLocks+1 ; needed, that the TexRes can be optimized
  
  ;---- NOT FOR DNYMIC PS 1.4
  ;*ptr\TextureUpdateNeeded=1
  
  ProcedureReturn *ptr\RTSurface
EndProcedure


Procedure TexRes_OnLost(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  Select *ptr\Type
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      
      ; ___Dynamic_PS14_CopyTextureToSysmemSurface(*ptr) ;- why needed ?????
      *Surf.IDirect3DSurface9=*ptr\TextureSurface
      *Tex.IDirect3DTexture9=*ptr\Texture
      *ptr\TextureSurface=0
      *ptr\Texture=0
      *Surf\Release()
      *Tex\Release()
      ProcedureReturn 1
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *RT.IDirect3DSurface9=*ptr\RTSurface
      *Surf.IDirect3DSurface9=*ptr\TextureSurface
      *Tex.IDirect3DTexture9=*ptr\Texture
      *ptr\RTSurface=0
      *ptr\TextureSurface=0
      *ptr\Texture=0
      *RT\Release()
      *Surf\Release()
      *Tex\Release()
      ProcedureReturn 1
      
    Case #TEXRES_STATIC_A1R5G5B5
      ProcedureReturn ___ReleaseSpriteRT(*ptr)
      
    Case #TEXRES_STATIC_A8R8G8B8
      ProcedureReturn 1
  EndSelect
EndProcedure


Procedure TexRes_Restore(*ptr.TexRes)  
  
  ;, sET pITCH To 0!!!!
  
  If *ptr=0:ProcedureReturn 0:EndIf
  Select *ptr\Type
    
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
      Width=*ptr\Width
      Height=*ptr\Height
      ;If *ptr\RealTexture=0
      ;Width=ToPow2(Width)
      ;Height=ToPow2(Height)
      ;EndIf
      *D3DDevice\CreateTexture(Width,Height,1,#D3DUSAGE_RENDERTARGET,#D3DFMT_R5G6B5,#D3DPOOL_DEFAULT,@*Tex.IDirect3DTexture9,0)
      If *Tex=0:ProcedureReturn 0:EndIf
      
      *Tex\GetSurfaceLevel(0,@*TextureSurface.IDirect3DSurface9)
      If *TextureSurface=0
        *Tex\Release()
        ProcedureReturn 0 
      EndIf
      
      *ptr\Texture=*Tex
      *ptr\TextureSurface=*TextureSurface
      
      ProcedureReturn ___Dynamic_PS14_CopySysmemSurfaceToTexture(*ptr)
      
      
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      *D3DDevice.IDirect3DDevice9=*ptr\D3DDevice
      Width=*ptr\Width
      Height=*ptr\Height
      ;If *ptr\RealTexture=0
      ;Width=ToPow2(Width)
      ;Height=ToPow2(Height)
      ;EndIf
      
      *D3DDevice\CreateTexture(Width,Height,1,#D3DUSAGE_DYNAMIC,#D3DFMT_A1R5G5B5,#D3DPOOL_DEFAULT,@*Tex.IDirect3DTexture9,0)
      If *Tex=0:ProcedureReturn 0:EndIf
      ;The Rendertarget is needed if you want to display a sprite on the sprite (with UseBuffer(Sprite))
      *D3DDevice\CreateRenderTarget(*ptr\Width,*ptr\Height,#D3DFMT_R5G6B5,0,0,0,@*RTSurface.IDirect3DSurface9,0)
      
      If *RTSurface=0 ; we can't create the render target surface
        *Tex\Release() ; needed because the texture was sucessfully created 
        ProcedureReturn 0
      EndIf
      
      *Tex\GetSurfaceLevel(0,@*TextureSurface.IDirect3DSurface9)
      If *TextureSurface=0
        *RTSurface\Release()
        *Tex\Release()
        ProcedureReturn 0 
      EndIf
      
      *ptr\RTSurface=*RTSurface
      *ptr\Texture=*Tex
      *ptr\TextureSurface=*TextureSurface
      
      If ___Dynamic_CopySysmemSurfaceToTexture(*ptr)=0:ProcedureReturn 0:EndIf
      ProcedureReturn ___Dynamic_CopySysmemSurfaceToRTSurface(*ptr)
      
    Case #TEXRES_STATIC_A1R5G5B5
      ProcedureReturn ___MakeSureSpriteRTExists(*ptr)
    Case #TEXRES_STATIC_A8R8G8B8
      ProcedureReturn 1
  EndSelect
EndProcedure



Procedure TexRes_Free(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  
  Select *ptr\Type
    
    Case #TEXRES_DYNAMIC_A1R5G5B5_PS14
      
      *SysSurf.IDirect3DSurface9=*ptr\SysmemSurface
      *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
      *Tex.IDirect3DTexture9=*ptr\Texture
      If *SysSurf:*SysSurf\Release():EndIf
      If *TexSurf:*TexSurf\Release():EndIf
      If *Tex:*Tex\Release():EndIf
      GlobalFree_(*ptr)
      ProcedureReturn 1
      
    Case #TEXRES_DYNAMIC_A1R5G5B5
      
      *RT.IDirect3DSurface9=*ptr\RTSurface
      *SysSurf.IDirect3DSurface9=*ptr\SysmemSurface
      *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
      *Tex.IDirect3DTexture9=*ptr\Texture
      If *RT:*RT\Release():EndIf
      If *SysSurf:*SysSurf\Release():EndIf
      If *TexSurf:*TexSurf\Release():EndIf
      If *Tex:*Tex\Release():EndIf
      GlobalFree_(*ptr)
      ProcedureReturn 1
      
    Case #TEXRES_STATIC_A1R5G5B5
      *RT.IDirect3DSurface9=*ptr\RTSurface
      *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
      *Tex.IDirect3DTexture9=*ptr\Texture
      If *RT:*RT\Release():EndIf
      If *TexSurf:*TexSurf\Release():EndIf
      If *Tex:*Tex\Release():EndIf
      If *ptr\RTCopy:GlobalFree_(*ptr\RTCopy):*ptr\RTCopy=0:EndIf
      GlobalFree_(*ptr)
      ProcedureReturn 1
      
    Case #TEXRES_STATIC_A8R8G8B8
      *SysSurf.IDirect3DSurface9=*ptr\SysmemSurface
      *TexSurf.IDirect3DSurface9=*ptr\TextureSurface
      *Tex.IDirect3DTexture9=*ptr\Texture
      If *SysSurf:*SysSurf\Release():EndIf
      If *TexSurf:*TexSurf\Release():EndIf
      If *Tex:*Tex\Release():EndIf
      GlobalFree_(*ptr)
      ProcedureReturn 1
  EndSelect
EndProcedure



Procedure TexRes_Optimize(*ptr.TexRes,Flags)
  ;---TEST ONLY!!!
  ;ProcedureReturn 0
  
  If *ptr=0:ProcedureReturn 0:EndIf
  
  Select *ptr\Type
    
    Case #TEXRES_DYNAMIC_A1R5G5B5
      ; Noting to optimize here
      ProcedureReturn 0
      
    Case #TEXRES_STATIC_A1R5G5B5
      ;--> adjust values
      
      ;-> this is not really clever, because TexRes_Optimize() is called in SpriteOutput(), GrabSprite() where the RT is needed -> RT must be recreated 
      If *ptr\NumLocks<3:___ReleaseSpriteRT(*ptr):ProcedureReturn *ptr:EndIf ; release the rendertarget if it's not used frequently
      
      If *ptr\NumLocks>5 And *ptr\CanMakeDynamic ; try to convert the texture into a dynamic one (for faster UseBuffer(...)/SpriteOutput(...))
        
        If Flags=#TEXRES_OPTIMIZE_PS14
          *newptr.TexRes=TexRes_CreateTexture(*ptr\D3DDevice,*ptr\Width,*ptr\Height,#TEXRES_DYNAMIC_A1R5G5B5_PS14,*ptr\RealTexture)
          If *newptr=0
            *newptr.TexRes=TexRes_CreateTexture(*ptr\D3DDevice,*ptr\Width,*ptr\Height,#TEXRES_DYNAMIC_A1R5G5B5,*ptr\RealTexture)
          EndIf
          
        Else
          *newptr.TexRes=TexRes_CreateTexture(*ptr\D3DDevice,*ptr\Width,*ptr\Height,#TEXRES_DYNAMIC_A1R5G5B5,*ptr\RealTexture)
        EndIf
        
        
        If *newptr=0
          *ptr\CanMakeDynamic=0 ; prevent the program from trying it more than once (for speed reason)
          ProcedureReturn 0
        EndIf
        
        
        sDC=TexRes_GetDC(*ptr)
        If sDC=0:TexRes_Free(*newptr):*ptr\CanMakeDynamic=0:ProcedureReturn 0:EndIf
        dDC=TexRes_GetDC(*newptr)
        If dDC=0:TexRes_ReleaseDC(*ptr,1):TexRes_Free(*newptr):*ptr\CanMakeDynamic=0:ProcedureReturn 0:EndIf
        
        result=BitBlt_(dDC,0,0,*ptr\Width,*ptr\Height,sDC,0,0,#SRCCOPY)
        
        TexRes_ReleaseDC(*newptr,0)
        TexRes_ReleaseDC(*ptr,1)
        
        If TexRes_SetTransColor(*newptr,TexRes_GetTransColor(*ptr))=0:result=0:EndIf
        
        If result=0:TexRes_Free(*newptr):*ptr\CanMakeDynamic=0:ProcedureReturn 0:EndIf
        TexRes_Free(*ptr)
        ProcedureReturn *newptr ; returns the pointer to the new texture
        
      EndIf
      
    Case #TEXRES_STATIC_A8R8G8B8
      
      If *ptr\NumLocks<5 And *ptr\SysmemSurface
        *ptr\SysmemSurface\Release()
        *ptr\SysmemSurface=0
        ProcedureReturn *ptr
      EndIf
      
      
      
      ProcedureReturn 0
  EndSelect
EndProcedure

Procedure TexRes_NeedPS14(*ptr.TexRes)
  If *ptr=0:ProcedureReturn 0:EndIf
  If *ptr\Type=#TEXRES_DYNAMIC_A1R5G5B5_PS14:ProcedureReturn 1:EndIf
EndProcedure


Procedure TexRes_StaticInitLock(*ptr.TexRes,*SurfacePtr.Long,*SurfacePitch.Long)
  ___ReleaseSpriteRT(*ptr)
  If *ptr\TextureSurface\LockRect(lr.D3DLOCKED_RECT,0,0)=0
    *SurfacePtr\l=lr\pBits
    *SurfacePitch\l=lr\Pitch
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure TexRes_StaticInitUnLock(*ptr.TexRes,*SurfacePtr.l,SurfacePitch.l)
  H_SetX1RGB15ToA1RGB15TransColor(*ptr\TransparentColor)
  For y=0 To *ptr\Height-1
    CopyMemory(*SurfacePtr+y*SurfacePitch,*ptr\RTCopy+y*(*ptr\Width*2),*ptr\Width*2)
    H_ConvertX1RGB15ToA1RGB15(*SurfacePtr+y*SurfacePitch,*SurfacePtr+y*SurfacePitch,*ptr\Width)
  Next
  *ptr\TextureSurface\UnLockRect()
  *ptr\TextureUpdateNeeded=0
  *ptr\LockSinceGetRTSurface=0
  *ptr\RTToSysMemCopyNeeded=0
EndProcedure

Procedure TexRes_DisableTransparentColorUpdate(State)
  TexRes_DisableTransparentColorUpdate=State
EndProcedure

Procedure TexRes_GetPitch(*ptr.TexRes)
  If *ptr\Pitch
    ProcedureReturn *ptr\Pitch
  EndIf
  
  If TexRes_Lock(*ptr,#True,@dummy,@pitch)
    TexRes_UnLock(*ptr,#True)
    *ptr\Pitch=pitch
  EndIf
  
  ProcedureReturn pitch
EndProcedure





DataSection
TexRes_VTable:
Data.l @TexRes_Type();0
Data.l @TexRes_Width();4
Data.l @TexRes_Height();8
Data.l @TexRes_Depth();12
Data.l @TexRes_CreateTexture();16
Data.l @TexRes_GetUpdatedTexture();20
Data.l @TexRes_SetTransColor();24
Data.l @TexRes_Lock();28
Data.l @TexRes_UnLock();32
Data.l @TexRes_GetDC();36
Data.l @TexRes_ReleaseDC();40
Data.l @TexRes_GetRTSurface();44
Data.l @TexRes_OnLost();48
Data.l @TexRes_Restore();52
Data.l @TexRes_Free();56
Data.l @TexRes_Optimize();60
Data.l @TexRes_NeedPS14();64
Data.l @TexRes_StaticInitLock();68
Data.l @TexRes_StaticInitUnLock();72
Data.l @TexRes_DisableTransparentColorUpdate();76
Data.l @TexRes_GetPitch();80
EndDataSection




; IDE Options = PureBasic 4.10 Beta 2 (Windows - x86)
; CursorPosition = 664
; FirstLine = 653
; Folding = -------