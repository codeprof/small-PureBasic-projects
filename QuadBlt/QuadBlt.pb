Structure QUADBLT_VERTEX
x.l
y.l
EndStructure

Structure QUADBLT_QUAD
v.QUADBLT_VERTEX[4]
EndStructure

Structure QUADBLT_TRIANGLE
v.QUADBLT_VERTEX[3]
EndStructure

Procedure QuadBlt(hdcDest.l,*points.QUADBLT_QUAD,hdcSrc.l,lXSrc.l,lYSrc.l,lWidth.l,lHeight.l)
  
   
If hdcDest=0 Or *points=0 Or hdcSrc=0
ProcedureReturn #False
EndIf

GetClipBox_(hdcSrc,clipbox.rect)
If lXSrc+lWidth>clipbox\right-clipbox\left Or lYSrc+lHeight>clipbox\bottom-clipbox\top Or lXSrc<0 Or lYSrc<0 Or lWidth<=0 Or lHeight<=0
ProcedureReturn #False
EndIf
rectrgn=CreateRectRgn_(clipbox\left,clipbox\top,clipbox\right,clipbox\bottom)
lResult=GetClipRgn_(hdcDest,rectrgn)
If lResult=-1 Or rectrgn=0
ProcedureReturn #False
EndIf

Triangle2.QUADBLT_TRIANGLE
Triangle2\v[0]\x=*points\v[3]\x
Triangle2\v[0]\y=*points\v[3]\y
Triangle2\v[1]\x=*points\v[2]\x
Triangle2\v[1]\y=*points\v[2]\y
Triangle2\v[2]\x=*points\v[1]\x
Triangle2\v[2]\y=*points\v[1]\y

rgntriangle1=CreatePolygonRgn_(*points,3,1)
rgntriangle2=CreatePolygonRgn_(Triangle2,3,1)

If lResult<>0
CombineRgn_(rgntriangle1,rgntriangle1,rectrgn,#RGN_AND)
CombineRgn_(rgntriangle2,rgntriangle2,rectrgn,#RGN_AND)
EndIf

lOldStretchBltMode=SetStretchBltMode_(hdcDest,#COLORONCOLOR)

SelectClipRgn_(hdcDest,rgntriangle1)
PlgBlt_(hdcDest,*points,hdcSrc,lXSrc,lYSrc,lWidth,lHeight,0,0,0) 

SelectClipRgn_(hdcDest,rgntriangle2)
PlgBlt_(hdcDest,Triangle2,hdcSrc,lWidth+lXSrc,lHeight+lYSrc,-lWidth,-lHeight,0,0,0) 

SetStretchBltMode_(hdcDest,lOldStretchBltMode)

;If lResult=0
SelectClipRgn_(hdcDest,0)
;Else
;SelectClipRgn_(hdcDest,rectrgn)
;EndIf

DeleteObject_(rectrgn)
DeleteObject_(rgntriangle1)
DeleteObject_(rgntriangle2)
EndProcedure



Dim pt.point(3)


OpenWindow(1,0,0,900,900,"TEST")
LoadImage(1,"d:\test.bmp")

MemDC=CreateCompatibleDC_(0)
SelectObject_(MemDC,ImageID(1))

DC=StartDrawing(WindowOutput(1))

pt(0)\x=70
pt(0)\y=300

pt(1)\x=400
pt(1)\y=300

pt(2)\x=400
pt(2)\y=580

pt(3)\x=900
pt(3)\y=700

QuadBlt(DC,@pt(),MemDC,0,0,ImageWidth(1),ImageHeight(1))
StopDrawing()
DeleteDC_(MemDC)

Repeat
Until WindowEvent()=#WM_CLOSE
