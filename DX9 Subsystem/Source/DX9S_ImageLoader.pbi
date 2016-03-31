
; Loads bmp And dib files from memory.
Procedure _DIB_LoadFromMem(Addr.l)  
  Protected *bmfh.BITMAPFILEHEADER, *bminf.BitmapInfo, hBmp.l, MemDC.l, OldhBmp.l, Result.l
  If Addr
    *bmfh.BITMAPFILEHEADER=Addr
    If *bmfh\bfType='MB' ;  seems to be a bitmap (*.bmp or *.dib), so we don't need the size
      ; load bmp or dib from memory, really short ;)
      *bminf.BitmapInfo=*bmfh+SizeOf(BITMAPFILEHEADER)
      hBmp=CreateDIBSection_(0,*bminf,#DIB_RGB_COLORS,0,0,0)
      If hBmp=0:ProcedureReturn 0:EndIf
      
      MemDC=CreateCompatibleDC_(0)
      
      OldhBmp=SelectObject_(MemDC,hBmp)
      Result=SetDIBitsToDevice_(MemDC,0,0,*bminf\BmiHeader\biWidth,*bminf\BmiHeader\biHeight,0,0,0,*bminf\BmiHeader\biHeight,*bmfh\bfOffBits+*bmfh,*bminf,#DIB_RGB_COLORS)
      SelectObject_(MemDC,OldhBmp)
      DeleteDC_(MemDC)
      If Result=0:DeleteObject_(MemDC):ProcedureReturn 0:EndIf
    EndIf
  EndIf
  
  ProcedureReturn hBmp
EndProcedure

; Loads bmp And dib files from file.
Procedure _DIB_LoadFromFile(File.s) 
  ProcedureReturn LoadImage_(0,File.s,#IMAGE_BITMAP,0,0,#LR_LOADFROMFILE|#LR_CREATEDIBSECTION)
EndProcedure

Procedure _DIB_CreateFromDC(SrcDC.l,Width.l,Height.l,Bpp.l)
BmInf.BitmapInfo
BmInf\BmiHeader\biBitCount=Bpp
BmInf\BmiHeader\biCompression=#BI_RGB
BmInf\BmiHeader\biPlanes=1
BmInf\BmiHeader\biSize=SizeOf(BITMAPINFOHEADER)
BmInf\BmiHeader\biWidth=Width
BmInf\BmiHeader\biHeight=Height
hBmp=CreateDIBSection_(0,BmInf,#DIB_RGB_COLORS,0,0,0)

MemDC=CreateCompatibleDC_(0)
If MemDC=0:DeleteObject_(hBmp):ProcedureReturn 0:EndIf
  
OldhBmp=SelectObject_(MemDC,hBmp)
Result=BitBlt_(MemDC,0,0,Width,Height,SrcDC,0,0,#SRCCOPY)
SelectObject_(MemDC,OldhBmp)
DeleteDC_(MemDC)
If Result=0:DeleteObject_(hBmp):ProcedureReturn 0:EndIf
ProcedureReturn hBmp
EndProcedure





Procedure _PB_LoadImage(Addr.l,File.s,bpp.l,*ds.DIBSECTION)

If bpp=8

If Addr=0
hBmp=_DIB_LoadFromFile(File.s) 
Else
hBmp=_DIB_LoadFromMem(Addr.l)
EndIf

If GetObject_(hBmp,SizeOf(DIBSECTION),*ds.DIBSECTION)=0:ProcedureReturn 0:EndIf
    
If *ds\dsBm\bmBits=0 Or *ds\dsBm\bmBitsPixel<>8:ProcedureReturn 0:EndIf

ProcedureReturn hBmp
EndIf
    
If bpp=32 Or bpp=16

If Addr=0
Image=LoadImage(#PB_Any,File,bpp)
Else
Image=CatchImage(#PB_Any,Addr,bpp)
EndIf

ImageID=ImageID(Image)

If GetObjectType_(ImageID)<>#OBJ_BITMAP:FreeImage(Image):ProcedureReturn 0:EndIf ; if we try to load an icon
  
MemDC=CreateCompatibleDC_(0)
OldImageID=SelectObject_(MemDC,ImageID)
hBmp=_DIB_CreateFromDC(MemDC,ImageWidth(Image),ImageHeight(Image),Bpp)
SelectObject_(MemDC,OldImageID)
DeleteDC_(MemDC)
FreeImage(Image)

If GetObject_(hBmp,SizeOf(DIBSECTION),*ds.DIBSECTION)=0:DeleteObject_(hBmp):ProcedureReturn 0:EndIf
ProcedureReturn hBmp
EndIf

EndProcedure
; IDE Options = PureBasic 5.00 Beta 3 (Windows - x86)
; CursorPosition = 76
; FirstLine = 42
; Folding = -