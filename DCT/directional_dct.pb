


Dim dct.f(8,8,8,8)

OpenWindow(1,0,0,700,700,"")

CreateImage(1,9*8,9*8)

StartDrawing(ImageOutput(1))
For y=0 To 7
  For y2 = 0 To 7
    

    For x=0 To 7  
      For x2 = 0 To 7
        
        
         x_=x
         y_=y
         If x > 0        
           If x & 1
             x_= (x+1)/2
           Else
             x_= 8-(x/2)
           EndIf       
         EndIf
         If y > 0        
           If y & 1
             y_= (y+1)/2
           Else
             y_= 8-(y/2)
           EndIf       
         EndIf 
         
        v.f= (Sin(#PI * (x_) * (2 * (x2) + 0.0)/ (8.0) + #PI * (y_) * (2.0 * (y2) + 0.0)/ (8.0)+3.0/4.0*#PI))   
        
        dct(x,x2,y,y2)=v
        v2=127.5*v+127.5
        
        Plot(x*9+x2,y*9+y2,RGB(v2,v2,v2))
      Next
    Next
  Next
Next
StopDrawing()
ResizeImage(1,9*8*4,9*8*4,#PB_Image_Raw)


For x=0 To 7
  For y=0 To 7
    For x_ = 0 To 7
      For y_ = 0 To 7
        
        If x=x_ And y=y_
          
        Else
          dot.f=0
          For y2 = 0 To 7
            For x2 = 0 To 7
              dot.f + dct(x,x2,y,y2)*dct(x_,x2,y_,y2)  
            Next
          Next
          If Abs(dot) > 0.0001
            Debug "BAD:" +StrF(dot)
          Else
            Debug "OK: " +StrF(dot)
          EndIf
          
        EndIf
      Next
    Next
  Next
Next
Repeat
  StartDrawing(WindowOutput(1))
  DrawImage(ImageID(1),0,0)
  StopDrawing()
  
Until WaitWindowEvent()=#PB_Event_CloseWindow

