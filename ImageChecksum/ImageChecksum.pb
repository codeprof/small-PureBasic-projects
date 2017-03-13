;AUTHOR:  codeprof
;LICENSE: PUBLIC DOMAIN (can be used without any restriction)

Procedure.s ImageChecksum(image)
  Protected Dim v.i(7,7,1,1)
  Protected img, x, y, c, checksum.s = ""
  img = CopyImage(image,#PB_Any)
  If IsImage(img)
    ResizeImage(img, 64, 64, #PB_Image_Smooth)
    
    StartDrawing(ImageOutput(img))
    For x = 0 To 63
      For y = 0 To 63
        c = Point(x,y)
        v(x >> 3,y >> 3, (x >> 2) & 1 , (y >> 2) & 1 ) + (Red(c) * 3) + (Green(c) * 6) + Blue(c)
      Next
    Next
    StopDrawing()
    For x=0 To 7
      For y=0 To 7
        ;+-
        ;+-            
        If (v(x,y,0,0) + v(x,y,0,1)) - (v(x,y,1,0) + v(x,y,1,1)) > 0
          checksum + "1"
        Else
          checksum + "0"
        EndIf    
        ;++
        ;--
        If (v(x,y,0,0) + v(x,y,1,0)) - (v(x,y,0,1) + v(x,y,1,1)) >= 0
          checksum + "1"
        Else
          checksum + "0"
        EndIf        
        ;+-
        ;-+
        If (v(x,y,0,0) + v(x,y,1,1)) - (v(x,y,0,1) + v(x,y,1,0)) >= 0
          checksum + "1"
        Else
          checksum + "0"
        EndIf    
      Next
    Next
    FreeImage(img)
  EndIf    
  ProcedureReturn checksum
EndProcedure  

Procedure ImageChecksumError(checksum1.s, checksum2.s)
  Protected error = 0
  For i = 1 To 192
    If Mid(checksum1, i, 1) <> Mid(checksum2, i, 1):error+1:EndIf
  Next  
  ProcedureReturn error
EndProcedure




;Example:

UseJPEGImageDecoder()


LoadImage(1,"J:\image1.jpg")
LoadImage(2,"J:\image2.jpg")

Debug ImageChecksum(1)
Debug ImageChecksum(2)

If ImageChecksumError(ImageChecksum(1),ImageChecksum(2)) <= 8
  Debug "Pictures are similar"
Else
  Debug "Pictures are not similar"
EndIf  
