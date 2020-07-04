
#WIDTH=8
#W_MAX = 7

Procedure rev(x)
  x_=x
  If x > 0        
    If x & 1
      x_= (x+1)/2
    Else
      x_= #WIDTH-(x/2)
    EndIf       
  EndIf
  ProcedureReturn x_
EndProcedure


Dim dct.d(#W_MAX*2,#W_MAX,#W_MAX*2,#W_MAX)

OpenWindow(1,0,0,700,900,"")


For y=0 To #W_MAX
  For y2 = 0 To #W_MAX
    
    
    For x=0 To #W_MAX  
      For x2 = 0 To #W_MAX
        
        
        v1.f= #PI * rev(x) * (2 * (x2) + 1.0)/ (#WIDTH * 2.0)
        v2.f= #PI * (y) * (2 * (y2) + 1.0)/ (#WIDTH * 2.0)
        
        
        
        If y=0
          v.f= Cos((v1 ))      
        Else
          v=Cos((v1*2 +v2 )) 
        EndIf
        
        
        If x=7 And y>0
          
          If y=1
            xx=7
            yy=7
          EndIf
          If y=2
            xx=6
            yy=7
          EndIf          
          If y=3
            xx=7
            yy=6
          EndIf  
          If y=4
            xx=7
            yy=5
          EndIf 
          If y=5
            xx=5
            yy=7
          EndIf  
          If y=6
            xx=4
            yy=7
          EndIf            
          If y=7
            xx=7
            yy=4
          EndIf          
          
          v.f= (Sin(#PI*2.0/(#WIDTH) * ( rev(xx)*x2 + rev(yy)*y2) +1.0/4.0*#PI)) 
          
        EndIf
        
        dct(x,x2,y,y2)=v
        
      Next
    Next
  Next
Next


Dim processed(#W_MAX,#W_MAX)

For ya=0 To #W_MAX
  For xa=0 To #W_MAX
    
    processed(xa,ya)=1
    cnt=0
    For y=0 To #W_MAX
      For x=0 To #W_MaX
        
        
        If  processed(x,y)=0 ;And x>0 And y>0
          
          cnt+1
          
          l1.d=0
          l2.d=0
          dot.d=0
          For x2=0 To #W_MAX
            For y2=0 To #W_MAX
              dot.d =dot.d + dct(x,x2,y,y2) * dct(xa,x2,ya,y2)
              l1.d= l1.d + Pow(dct(x,x2,y,y2),2.0) ;+ Pow(dct(x,x2,y,y2),2.0)
              l2.d= l2.d + Pow(dct(xa,x2,ya,y2),2.0) ;+ Pow(dct(xa,x2,ya,y2),2.0)         
            Next
          Next
          l1=Sqr(l1)
          l2=Sqr(l2)
          
          
          
          len_new.d=0
          For x2=0 To #W_MAX
            For y2=0 To #W_MAX     
              dct(x,x2,y,y2) =(dct(x,x2,y,y2)/l1 - dot/(l2*l1) * dct(xa,x2,ya,y2)/l2)
              len_new.d+ dct(x,x2,y,y2)*dct(x,x2,y,y2)
            Next
          Next    
          len_new.d=Sqr(len_new.d)
          For x2=0 To #W_MAX
            For y2=0 To #W_MAX     
              dct(x,x2,y,y2) =dct(x,x2,y,y2)/len_new.d  *3     
            Next
          Next       
          
          
          
          
        EndIf
      Next   
    Next
    
  Next
Next



CreateImage(1,(#WIDTH+1)*#WIDTH,(#WIDTH+1)*#WIDTH,32,#Blue)

StartDrawing(ImageOutput(1))
For y=0 To #W_MAX
  For y2 = 0 To #W_MAX
    
    
    For x=0 To #W_MAX  
      For x2 = 0 To #W_MAX
        v.f=dct(x,x2,y,y2)
        v2=127.5*v+127.5
        
        If v2 < 0:v=0:EndIf
        If v2>255:v=255:EndIf
        
        Plot(x*(#WIDTH+1)+x2,y*(#WIDTH+1)+y2,RGB(v2,v2,v2))
      Next
    Next
  Next
Next
StopDrawing()
ResizeImage(1,(#WIDTH+1)*#WIDTH*8,(#WIDTH+1)*#WIDTH*8,#PB_Image_Raw)
StartDrawing(WindowOutput(1))
DrawImage(ImageID(1),0,0)
StopDrawing()

For x=0 To #W_MAX
  For y=0 To #W_MAX
    For x_ = 0 To #W_MAX
      For y_ = 0 To #W_MAX
        
        If x=x_ And y=y_
          
        Else
          dot.d=0
          For y2 = 0 To #W_MAX
            For x2 = 0 To #W_MAX
              dot.d + dct(x,x2,y,y2)*dct(x_,x2,y_,y2)  
            Next
          Next
          If Abs(dot) > 0.00001
            Debug "BAD:" +StrF(dot) + "  " +Str(x)+","+Str(y) + "  "+Str(x_)+","+Str(y_)
          Else
            ;Debug "OK: " +StrF(dot)
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

SaveImage(1,"/hdd/2.bmp")
