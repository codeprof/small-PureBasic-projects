;Autor: codeprof
;Licence: Public Domain
Structure BITMAPINFO_RGB
  bmiHeader.BITMAPINFOHEADER
  rgbRed.l
  rgbGreen.l
  rgbBlue.l
EndStructure


Procedure DrawArray(hDC,width,height,*pointer)
  Protected bmi.BITMAPINFO_RGB
  bmi\bmiHeader\biSize       =SizeOf(BITMAPINFOHEADER)
  bmi\bmiHeader\biBitCount = 32
  bmi\bmiHeader\biWidth      = Width
  bmi\bmiHeader\biHeight     =-Height
  bmi\bmiHeader\biPlanes     = 1
  bmi\bmiHeader\biCompression = #BI_bitfields
  
  bmi\rgbBlue = $00FF0000
  bmi\rgbGreen = $0000FF00
  bmi\rgbRed = $000000FF  
  
  ProcedureReturn SetDIBitsToDevice_(hDC,0,0,Width,Height,0,0,0,Height,*pointer,@bmi,#DIB_RGB_COLORS)
EndProcedure



Dim Picture(255,255)

For x=0 To 255
  For y=0 To 255
    Picture(y,x)=RGB(x,x,x)   ;x and y are swapped here
  Next
Next  
    

OpenWindow(1,0,0,1000,500,"DrawArray test",#PB_Window_SystemMenu)

Repeat

  hDC = StartDrawing(WindowOutput(1))
  DrawArray(hDC,256,256,@Picture(0,0))
  StopDrawing()

Until WindowEvent()=#PB_Event_CloseWindow
