

Procedure eval(*line, begin, depth, num)
  org_num = num
  pos=begin
  While #True
    
  If pos <= MemoryStringLength(*line)*2-2
    ch.s = PeekS(*line+pos,1,#PB_Unicode)
  Else
    ch.s ="" 
  EndIf  
  pos=pos + 2
  If Len(ch) = 0
    Break
  EndIf
     
  If ch = ")"
    If depth < 1
      Debug "missing begin bracket"
    EndIf
       Debug "append to L"+Str(depth)+"_"+Str(org_num) +" : "+PeekS(*line+begin, (pos-begin)/2-1)   
       
      ProcedureReturn pos
  ElseIf ch =  "("
    lastpos = pos
    
    num=num+1
    pos = eval(*line, pos,depth+1,num)
    Debug "append to L"+Str(depth)+"_"+Str(org_num) +" : "+PeekS(*line+begin, (lastpos-begin)/2-1)  + "L"+Str(depth+1)+"_"+Str(num)

    ;Debug "INSERT stack"+Str(depth+1)
    continueX = 1
   ; CURR$ + "{"+PeekS(*line+lastpos,(pos-lastpos)/2-1)+"}"
    begin=pos
  EndIf
Wend  
  If depth > 0
  Debug "missig end bracket"  
EndIf
  ProcedureReturn pos
EndProcedure



Debug eval(@"(a+b-d*-f+(b*h)+z)*(c-d)/(x)",0, 0,0)
