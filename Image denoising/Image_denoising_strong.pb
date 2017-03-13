

#DO_DENOISE = #True

#HARD_DENOISE = #True
#MINSZ = 12 ;16

#SHARP_FACTOR = 0.90

#CREATE_DEBUG_IMAGES = #True
 
UseJPEGImageDecoder()
UsePNGImageDecoder()

UseJPEGImageEncoder()
UseJPEG2000ImageDecoder()
UseJPEG2000ImageEncoder()

file_in$=OpenFileRequester("Source Image", "", "JPEG (*.jpg)|*.jpg;*.jpeg|(PNG (*.png)|*.png", 0)

If file_in$ ="":End:EndIf

file_out$=SaveFileRequester("Destination Image", "result.jpg", "JPEG (*.jpg)|*.jpg;*.jpeg", 0)

If file_out$ ="":End:EndIf

LoadImage(1,file_in$)

CopyImage(1,2)

ResizeImage(2, ImageWidth(2)/#MINSZ, ImageHeight(2)/#MINSZ)
ResizeImage(2, ImageWidth(1), ImageHeight(1))

Dim img1_R(ImageWidth(1), ImageHeight(1))
Dim img2_R(ImageWidth(1), ImageHeight(1))
Dim img1_G(ImageWidth(1), ImageHeight(1))
Dim img2_G(ImageWidth(1), ImageHeight(1))
Dim img1_B(ImageWidth(1), ImageHeight(1))
Dim img2_B(ImageWidth(1), ImageHeight(1))


Dim img3_R.f(ImageWidth(1), ImageHeight(1))
Dim img3_G.f(ImageWidth(1), ImageHeight(1))
Dim img3_B.f(ImageWidth(1), ImageHeight(1))


StartDrawing(ImageOutput(1))

width = ImageWidth(1)
height = ImageHeight(1)
For y=0 To height-1
  For x=0 To width-1
    c = Point(x,y)  
    img1_R(x,y) = Red(c)
    img1_G(x,y) = Green(c)
    img1_B(x,y) = Blue(c)    
  Next
Next
StopDrawing()

StartDrawing(ImageOutput(2))

width = ImageWidth(1)
height = ImageHeight(1)
For y=0 To height-1
  For x=0 To width-1
    c = Point(x,y)  
    img2_R(x,y) = Red(c)
    img2_G(x,y) = Green(c)
    img2_B(x,y) = Blue(c)  
  Next
Next
StopDrawing()



For turn = 0 To 1

If turn = 0
StartDrawing(ImageOutput(2))
width = ImageWidth(1)
height = ImageHeight(1)
For y=0 To height-1
  For x=0 To width-1
    
   
    r = 127.5 + (img1_R(x,y) - img2_R(x,y)) 
    If r > 255:r=255:EndIf
    If r <   0:r=0:EndIf
    g = 127.5 + (img1_G(x,y) - img2_G(x,y))
    If g > 255:g=255:EndIf
    If g <   0:g=0:EndIf    
    b = 127.5 + (img1_B(x,y) - img2_B(x,y))
    If b > 255:b=255:EndIf
    If b <   0:b=0:EndIf
    
    Plot(x,y,RGB(r,g,b))
  Next
Next
StopDrawing()

Else
  
StartDrawing(ImageOutput(2))
width = ImageWidth(1)
height = ImageHeight(1)
For y=0 To height-1
  For x=0 To width-1
    
    
    CompilerIf #DO_DENOISE = #True
     r = img2_R(x,y) + (img1_R(x,y) - img2_R(x,y)) * img3_R(x,y) 
     If r > 255:r=255:EndIf
     If r <   0:r=0:EndIf
     g = img2_G(x,y) + (img1_G(x,y) - img2_G(x,y)) * img3_G(x,y)
     If g > 255:g=255:EndIf
     If g <   0:g=0:EndIf    
     b = img2_B(x,y) + (img1_B(x,y) - img2_B(x,y)) * img3_B(x,y)
     If b > 255:b=255:EndIf
     If b <   0:b=0:EndIf
        
    CompilerElse
     r = img2_R(x,y) + (img1_R(x,y) - img2_R(x,y)) * img3_R(x,y) * #SHARP_FACTOR + (img1_R(x,y) - img2_R(x,y)) 
     If r > 255:r=255:EndIf
     If r <   0:r=0:EndIf
     g = img2_G(x,y) + (img1_G(x,y) - img2_G(x,y)) * img3_G(x,y) * #SHARP_FACTOR + (img1_G(x,y) - img2_G(x,y))
     If g > 255:g=255:EndIf
     If g <   0:g=0:EndIf    
     b = img2_B(x,y) + (img1_B(x,y) - img2_B(x,y)) * img3_B(x,y) * #SHARP_FACTOR + (img1_B(x,y) - img2_B(x,y))
     If b > 255:b=255:EndIf
     If b <   0:b=0:EndIf
  CompilerEndIf

    Plot(x,y,RGB(r,g,b))
  Next
Next
StopDrawing()
EndIf  


If turn = 0
    
  tmp$=GetTemporaryDirectory() + "tmp"+Random($FFFF)+".jp2"
  SaveImage(2,tmp$, #PB_ImagePlugin_JPEG2000, 2)
   
  LoadImage(3,tmp$)
  DeleteFile(tmp$)
  
  CompilerIf #CREATE_DEBUG_IMAGES = #True
    tmp$=GetTemporaryDirectory() + "high_freqs.jpg"
    SaveImage(3,tmp$, #PB_ImagePlugin_JPEG, 10)    
  CompilerEndIf    
  
  
  StartDrawing(ImageOutput(3))
    width = ImageWidth(1)
    height = ImageHeight(1)
    
    ges_rf.f=0
    ges_gf.f=0
    ges_bf.f=0
    ;determine ideal scale factor
    For y=0 To height-1
      For x=0 To width-1
        c=Point(x,y)
        
        rf.f = Red(c)
        gf.f = Green(c)
        bf.f = Blue(c)
        ges_rf + Abs((rf - 127.5))
        ges_gf + Abs((gf - 127.5))
        ges_bf + Abs((bf - 127.5))
      Next
    Next    
    ges_rf / (width * height * 128.0)
    ges_gf / (width * height * 128.0)    
    ges_bf / (width * height * 128.0)
    
    
    Debug ges_rf
    Debug ges_gf
    Debug ges_bf
    
    If ges_rf <= 0.01:ges_rf = 0.01:EndIf
    If ges_gf <= 0.01:ges_gf = 0.01:EndIf    
    If ges_bf <= 0.01:ges_bf = 0.01:EndIf
    
    facR.f = 0.5 / ges_rf
    facG.f = 0.5 / ges_gf
    facB.f = 0.5 / ges_bf    
    
    
    For y=0 To height-1
      For x=0 To width-1
        c=Point(x,y)
        
        rf.f = Red(c)
        gf.f = Green(c)
        bf.f = Blue(c)
        rf = Abs((rf - 127.5) * facR)
        If rf > 255:rf=255:EndIf
        gf = Abs((gf - 127.5) * facG)
        If gf > 255:gf=255:EndIf    
        bf = Abs((bf - 127.5) * facB)
        If bf > 255:bf=255:EndIf 
        Plot(x,y,RGB(rf,gf,bf))     
      Next
    Next
    
  
  StopDrawing()
  
  For sz = 1 To #MINSZ
    
    Debug sz
    If sz <> 1
    ResizeImage(3, ImageWidth(3)/sz, ImageHeight(3)/sz)
    ResizeImage(3, ImageWidth(1), ImageHeight(1))
    EndIf
   
    factor.f = Sqr(Sqr(sz));1 / (Sqr(sz))
    StartDrawing(ImageOutput(3))
    width = ImageWidth(1)
    height = ImageHeight(1)
    For y=0 To height-1
      For x=0 To width-1
        
        c=Point(x,y)
        
       
        rf.f = Red(c)/ 255.0
        gf.f = Green(c)/ 255.0
        bf.f = Blue(c)/ 255.0
        
        rf*factor
        gf*factor
        bf*factor
        
        
        If rf > 1.0:rf=1.0:EndIf
        If gf > 1.0:gf=1.0:EndIf    
        If bf > 1.0:bf=1.0:EndIf 
        
        If rf > img3_R(x,y):img3_R(x,y) = rf:EndIf
        If gf > img3_G(x,y):img3_G(x,y) = gf:EndIf        
        If bf > img3_B(x,y):img3_B(x,y) = bf:EndIf      
          
      Next
    Next
    StopDrawing()
  Next
  
  
  For y=0 To height-1
    For x=0 To width-1
      
      rf.f=img3_R(x,y)
      gf.f=img3_G(x,y)
      bf.f=img3_B(x,y)
      
      ycol.f =  (rf + gf + bf.f) /(3)
      
      ;dr.f = 1 + 16*Abs(rf-ycol)
      ;rf = rf / dr
      ;dr.f = 1 + 16*Abs(gf-ycol)
      ;gf = gf / dr      
      ;dr.f = 1 + 16*Abs(bf-ycol)
      ;bf = bf / dr      
      
      If rf > ycol:rf=ycol:EndIf
      If gf > ycol:gf=ycol:EndIf
      If bf > ycol:bf=ycol:EndIf
      
      
      CompilerIf #HARD_DENOISE=#True
      img3_R(x,y) = rf*rf
      img3_G(x,y) = gf*gf
      img3_B(x,y) = bf*bf
    CompilerElse
      img3_R(x,y) = rf
      img3_G(x,y) = gf
      img3_B(x,y) = bf   
      CompilerEndIf
      
    Next
  Next  
  


  CompilerIf #CREATE_DEBUG_IMAGES = #True
    
  StartDrawing(ImageOutput(3))
  width = ImageWidth(1)
  height = ImageHeight(1)
  For y=0 To height-1
    For x=0 To width-1
      
      r = img3_R(x,y)*255
      g = img3_G(x,y)*255
      b = img3_B(x,y)*255    
      Plot(x,y,RGB(r,g,b))
    Next
  Next
  StopDrawing()
  tmp$=GetTemporaryDirectory() + "scale.jpg"  
  SaveImage(3,tmp$, #PB_ImagePlugin_JPEG, 10)     
  CompilerEndIf 
  

Else
   SaveImage(2,file_out$, #PB_ImagePlugin_JPEG, 10) 
EndIf

Next

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 20
; Folding = -
; EnableUnicode
; EnableXP
; Executable = Image_denoising_soft.exe