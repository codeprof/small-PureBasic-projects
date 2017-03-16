

;#E: Empty
;#V: possible Variable
;#N: Number
;#F: Function/Array
Global pos = 1
Global line.s = "f1(f2())";".4+4*(6+(i)+(i6)+(-k)+(kg*(p+q-hooo))+6)+'hey(y+o)h'";4+(66*(21+55*A+B-C(a,b,c)))*9"
Global inString
Global inComment
Global layer_index = 0
Global NewMap token.s()
Global NewMap tokensign.s()
Global NewMap operators.s()

Procedure isValidVariable(str.s)
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  If Not FindString("_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", Mid(str, 1,1))
    ProcedureReturn #False
  EndIf
  
  For i = 2 To Len(str)
    If Not FindString("_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", Mid(str, i, 1))
      ProcedureReturn #False
    EndIf  
  Next
  ProcedureReturn #True
EndProcedure

Procedure isValidNumber(str.s)
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  For i = 1 To Len(str)
    ch.s = Mid(str, i, 1)
    If ch = "." And dot = #False
      dot = #True
    Else
      If Not FindString("0123456789", ch)       
      ProcedureReturn #False
     EndIf      
    EndIf      
  Next
  ProcedureReturn #True
EndProcedure

Procedure isValidFunctionInternal(str.s)
  If str = ""
    ProcedureReturn #False
  EndIf  
  
  If CountString(str, "#") <> 1
    ;function does not fit internal Structure name#placeholder, name#placeholder1#placeholder2 is also Not allowed
    ProcedureReturn  #False
  EndIf  
  
  ;just check everything before #. The remaining part should be a vaild placeholder
  name.s = StringField(str, 1, "#")
  If isValidVariable(name)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Procedure.s analyzeOperand(str.s)
  ;Debug "ANALYZE:" +str
  sign.s = ""
  
  If Left(str,1) = "-" ; allow sign
    str = Trim(Right(str,Len(str)-1))
    sign.s = "-"
  EndIf  
  
  If str = ""
     Debug "ERROR: operand is missing" 
  ElseIf FindString(str, " ")
    Debug "ERROR: operator is missing"
  Else
    
    layer_index + 1
    key.s = Str(layer_index)   
    If Left(str, 1) = "#"     
      
    ElseIf isValidNumber(str)
      key.s = "N" + key
      
    ElseIf isValidVariable(str)
      key.s = "V" + key    
      
    ElseIf isValidFunctionInternal(str)
      key.s = "F" + key

    Else
      If FindString(Str, "#")
        Debug "ERROR: invalid operand" ; don't show internals
      Else  
        Debug "ERROR: invalid operand '" + str + "'"
      EndIf  
    EndIf
    token(key) = str
    tokensign(key) = sign   
    ProcedureReturn "#" + key   
    
  EndIf    
EndProcedure

Procedure.s ApplyOperator(str.s, op.s)
  If FindString(str, op)
  operators.s = StringField(str, 1, "#")
  operands.s = Right(str, Len(str) - (Len(operators.s) + 1)) ;also remove the first "#", so we can use the remeaing "#"'s as seperator easyly
  ;Debug operators.s
  ;Debug operands.s

  i = 1
  While FindString(operators.s, op)
    
    i = FindString(operators.s, op)
    layer_index + 1
    key.s = Str(layer_index) 
    token(key) = op.s + "#" + StringField(operands, i, "#") + "#" + StringField(operands, i+1, "#")
    tokensign(key) = "" 
    
    ;Debug "ADD #" +key + " = " +op.s + "#" + StringField(operands, i, "#") + "#" + StringField(operands, i+1, "#")
    
    tmp_operands.s = ""
      
    For k = 1 To Len(operators.s)+1 ; Num operands
      If k = i 
        tmp_operands + key + "#"
      ElseIf k = i  + 1 
        ;do nothing
      Else
        tmp_operands + StringField(operands, k, "#") + "#"
      EndIf  
    Next  
    operators.s = Left(operators.s, i - 1) + Right(operators.s, Len(operators.s) - i) ; remove char at position i
    operands = Left(tmp_operands, Len(tmp_operands)-1)                                ; there is one "#" to much at the end 
    
  Wend
  ProcedureReturn operators.s + "#" + operands
Else
  ProcedureReturn str
EndIf

EndProcedure

Procedure.s ApplyOperators(str.s)
  str = ApplyOperator(str.s, "/")
  str = ApplyOperator(str.s, "*") 
  str = ApplyOperator(str.s, "-") 
  str = ApplyOperator(str.s, "+")  
  ProcedureReturn str
EndProcedure  
  
Procedure.s splitOperators(str.s)
  str = Trim(str)
  If str = ""
    str = "#E"  ;allow () for functions  ;TODO: disallow (), (()), t(())
  EndIf
  
  tmp.s
  res.s = ""
  ops.s = ""
  For i=1 To Len(str)
    ch.s = Mid(str, i, 1)
    If FindString(",+-*/", ch)
      tmp = Trim(tmp)
      If tmp.s <> "" 
        res + analyzeOperand(tmp)       
        tmp = ""
        ;res + ch ;# can be used as seperator here
        ops + ch   ;Add operators to another list
        signadded = #False
      Else
        If ch <> "-" ;allow sign
          Debug "ERROR:left operand missing"
        Else
          tmp + ch
        EndIf  
      EndIf    
    Else
      tmp + ch
    EndIf  
  Next
  tmp = Trim(tmp)  
  If tmp <> ""
    res + analyzeOperand(tmp)  
  Else
    Debug "ERROR:right operand missing"
  EndIf  
  ProcedureReturn ops + res ;first the operators then the operands
EndProcedure

Procedure.s tokenize(layer)
  coll.s = ""
  While pos <= Len(line)    
    ch.s = Mid(line, pos, 1)
    pos+1
    If ch = "(" And (Not inString) And (Not inComment)
      layer_index+1
      coll + tokenize(layer_index)
    ElseIf ch = ")" And (Not inString) And (Not inComment)     
      token(Str(layer)) = ApplyOperators(splitOperators(coll))
      If layer = 0
        Debug "ERROR: bracked was not opened before" 
      Else
        ProcedureReturn "#" + Str(layer)    
      EndIf
      
    ElseIf ch = "'" And Not inComment  
      inString = ~inString
      If inString
        layer_index+1
        coll + tokenize(layer_index)
      Else
        token("S"+Str(layer)) = coll      
        ProcedureReturn "#S" + Str(layer)    
      EndIf
              
    ElseIf ch = "#" And Not inString  
      inComment = #True     
    Else
      If Not inComment
          coll.s + ch  
      EndIf
    EndIf  
  Wend
  If inString Or layer > 0
    Debug "ERROR: bracked not closed"
  Else  
    ProcedureReturn ApplyOperators(splitOperators(coll))
  EndIf  
EndProcedure


Debug tokenize(0)

Debug "======"
  ForEach token()
    Debug  MapKey(token()) + "    =   " + tokensign(MapKey(token())) + "      "  + token()    
  Next 



