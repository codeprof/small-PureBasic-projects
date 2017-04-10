

UseJPEGImageDecoder()
UseJPEGImageEncoder()
UsePNGImageEncoder()
UsePNGImageDecoder()

SetCurrentDirectory("D:\my_images")
LoadImage(1,"with_color.jpg")
LoadImage(2,"grayscale.jpg")

Dim col.i(ImageWidth(1),ImageHeight(1))

StartDrawing(ImageOutput(1))
For x=0 To ImageWidth(1)-1
  For y=0 To ImageHeight(1)-1
    col(x,y) =Point(x,y)  
  Next
Next
StopDrawing()


StartDrawing(ImageOutput(2))
For x=0 To ImageWidth(1)-1
  For y=0 To ImageHeight(1)-1
    col = Point(x,y)  
    col2 = col(x,y)
    y1.f = (Red(col)+2.0 * Green(col)+Blue(col))/ 4.0
    y2.f = (Red(col2)+2.0 * Green(col2)+Blue(col2))/ 4.0    
    r1.f = y1 + Red(col2)-y2
    g1.f = y1 + Green(col2)-y2     
    b1.f = y1 + Blue(col2)-y2    
    If r1 > 255:r1= 255:EndIf
    If r1 < 0:r1 = 0:EndIf
    If g1 > 255:g1= 255:EndIf
    If g1 < 0:g1 = 0:EndIf
    If b1 > 255:b1= 255:EndIf
    If b1 < 0:b1 = 0:EndIf    
    Plot(x,y,RGB(r1,g1,b1))
    
  Next
Next
StopDrawing()

SaveImage(2,"out.png",#PB_ImagePlugin_PNG)
