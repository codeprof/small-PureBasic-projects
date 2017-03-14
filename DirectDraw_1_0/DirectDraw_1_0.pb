

;Use DirectDraw v1.0 for drawing on windows
;******************************************
 
 
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
 
Structure DDSCAPS
  dwCaps.l
EndStructure
 
Structure DDSURFACEDESC
  dwSize.l
  dwFlags.l
  dwHeight.l
  dwWidth.l
  lPitch.l
  dwBackBufferCount.l
  dwMipMapCount.l
  dwAlphaBitDepth.l
  dwReserved.l
  lpSurface.l
  ddckCKDestOverlay.DDCOLORKEY
  ddckCKDestBlt.DDCOLORKEY
  ddckCKSrcOverlay.DDCOLORKEY
  ddckCKSrcBlt.DDCOLORKEY
  ddpfPixelFormat.DDPIXELFORMAT
  ddsCaps.DDSCAPS
EndStructure
 
Structure DXImage
  *DDS.IDirectDrawSurface
  DC.l
  left.l
  top.l
  right.l
  bottom.l
  RealWidth.l
  RealHeight.l
EndStructure
 
#DDSD_WIDTH=4
#DDSD_HEIGHT=2
#DDSD_CAPS=1
#DDSCAPS_3DDEVICE=8192
#DDSCAPS_OFFSCREENPLAIN=64
#DDSCL_NORMAL=8
#DDSCAPS_PRIMARYSURFACE=512
#DDBLT_WAIT=$01000000
#DDBLT_KEYSRC=$0000800
 
Global *DD.IDirectDraw,*Clipper.IDirectDrawClipper,*Prim.IDirectDrawSurface
Global DESC.DDSURFACEDESC
;Global OldWindowID
 
 
Procedure InitDD1()
  DirectDrawCreate_(0,@*DD,0)
 
  *DD\SetCooperativeLevel(0,#DDSCL_NORMAL)
 
  *DD\CreateClipper(0,@*Clipper,0)
  DESC\dwSize=SizeOf(DDSURFACEDESC)
  DESC\dwFlags=#DDSD_CAPS
  DESC\ddsCaps\dwCaps=#DDSCAPS_PRIMARYSURFACE
 
  *DD\CreateSurface(DESC,@*Prim,0)
  *Prim\SetClipper(*Clipper)
EndProcedure

 
Procedure FreeDD1()
  *Clipper\Release()
  *Prim\Release()
  *DD\Release()  
EndProcedure

Procedure CreateDXImage(width,height)
  *Img.DXImage=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,SizeOf(DXImage))
  DESC\dwWidth=width
  DESC\dwHeight=height
  DESC\dwFlags=#DDSD_WIDTH|#DDSD_HEIGHT|#DDSD_CAPS
  DESC\ddsCaps\dwCaps=#DDSCAPS_OFFSCREENPLAIN
  *DD\CreateSurface(DESC,@*DDS.IDirectDrawSurface,0)
 
  *DDS\GetDC(@DC)
  BitBlt_(DC,0,0,width,height,0,0,0,#BLACKNESS)
  *DDS\ReleaseDC(DC)
 
  *Img\DDS=*DDS
  *Img\right=width
  *Img\bottom=height
  *Img\RealWidth=width
  *Img\RealHeight=height
 
  ProcedureReturn *Img
EndProcedure
 
 
Procedure GetDXImageDC(*Img.DXImage)
  *DDS.IDirectDrawSurface=*Img\DDS
  *DDS\GetDC(@DC)
  ProcedureReturn DC
EndProcedure
 
Procedure ReleaseDXImageDC(*Img.DXImage,DC)
  *DDS.IDirectDrawSurface=*Img\DDS
  ProcedureReturn *DDS\ReleaseDC(DC)
EndProcedure
 
Procedure DrawDXImage(WindowID,*Img.DXImage,X,Y,trans)
  *Clipper\SetHwnd(0,WindowID)

  GetWindowRect_(WindowID,@re.rect)
  GetClientRect_(WindowID,@cre.rect)
 
  tmp=((re\right-re\left)-(cre\right-cre\left))/2
  dest.rect\left=tmp+re\left+X
  dest\right=dest\left+*Img\right-*Img\left
  dest\top=((re\bottom-re\top)-(cre\bottom-cre\top))-tmp+re\top+Y
  dest\bottom=dest\top+*Img\bottom-*Img\top
 
  Select trans
    Case 0
      ProcedureReturn *Prim\Blt(dest,*Img\DDS,@*Img\left,#DDBLT_WAIT,0)
    Default
      ProcedureReturn *Prim\Blt(dest,*Img\DDS,@*Img\left,#DDBLT_WAIT|#DDBLT_KEYSRC,0)
  EndSelect
EndProcedure

Procedure FreeDXImage(*Img.DXImage)
  *DDS.IDirectDrawSurface=*Img\DDS
  *DDS\Release()
  GlobalFree_(*DDS)
EndProcedure
 
 
 
 
 
 
 
;Example:
OpenWindow(1,0,0,640,400,"Use DirectDraw v1.0",#PB_Window_SystemMenu|#PB_Window_ScreenCentered  )
 
CreateGadgetList(WindowID(1))
 
ButtonGadget(1,0,0,100,100,"HI")
 
; hRGN=CreateRectRgn_(0,0,800,600)
; GetWindowRgn_(WindowID(1),@hRGN)
; Bytes=GetRegionData_(Hrgn,0,0)
; Global RGN
; RGN=GlobalAlloc_(#GMEM_FIXED,Bytes)
; GetRegionData_(Hrgn,Bytes,RGN)
 
InitDD1()
 
DXImage=CreateDXImage(100,100)
 
DC=GetDXImageDC(DXImage)
 
For X=0 To 99
  For Y=0 To 99
    SetPixelV_(DC,X,Y,RGB(X*2,Y*2,255-X*2))
  Next
Next
 
ReleaseDXImageDC(DXImage,DC)

Repeat
  DrawDXImage(WindowID(1),DXImage,Random(640),Random(400),0)
 
  Delay(10)
Until WindowEvent()=#PB_Event_CloseWindow

FreeDXImage(DXImage)
FreeDD1()
